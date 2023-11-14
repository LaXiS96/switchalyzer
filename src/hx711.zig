// TODO:
// - 2 gpio: DOUT input, PD_SCK output
// - DOUT is normally high, goes low when data is ready
// - PD_SCK must be clocked 25-27 times (TODO channel/gain), first 24 clocks shift value MSB first on DOUT, 25th clock returns DOUT high
// - PD_SCK waveform high and low times must be >0.2us <50us
// - PD_SCK must be kept low, when high for longer than 60us hx711 will power down until it goes back to low

// Load cell connection to HX711:
// red -> E+
// black -> E-
// white -> A-
// green -> A+

const hal = @import("stm32f1.zig");
const clock = @import("clock.zig");
const trace = @import("trace.zig");

var dout_gpio: hal.Gpio = undefined;
var pd_sclk_gpio: hal.Gpio = undefined;

pub fn init(dout: hal.Gpio, pd_sclk: hal.Gpio) void {
    dout_gpio = dout;
    pd_sclk_gpio = pd_sclk;

    dout_gpio.configure(.input, .{ .input = .pull });
    dout_gpio.set(); // Pull-up
    pd_sclk_gpio.configure(.output_2MHz, .{ .output = .pushpull });
    pd_sclk_gpio.clear();
}

pub fn loop() void {
    // If DOUT is high, data is not ready
    if (dout_gpio.get())
        return;

    var value: u24 = 0;

    for (0..24) |i| {
        pd_sclk_gpio.set();
        clock.delay(1);

        const bit: u24 = if (dout_gpio.get()) 1 else 0;
        value |= bit << @truncate(23 - i); // MSB first

        pd_sclk_gpio.clear();
        clock.delay(1);
    }

    // Last clock to end reading
    // TODO 26 clocks select channel B with gain 32, 27 clocks select channel A with gain 64
    pd_sclk_gpio.set();
    clock.delay(1);
    pd_sclk_gpio.clear();

    const ivalue: i24 = @bitCast(value);
    trace.bufPrint("hx711: {d}\n", .{ivalue});
}
