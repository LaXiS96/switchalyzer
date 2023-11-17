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

const hal = @import("stm32f1/_index.zig");
const clock = @import("clock.zig");

var _dout_gpio: hal.Gpio = undefined;
var _pd_sclk_gpio: hal.Gpio = undefined;

pub fn initialize(dout: hal.Gpio, pd_sclk: hal.Gpio) void {
    _dout_gpio = dout;
    _pd_sclk_gpio = pd_sclk;

    _dout_gpio.initialize(.input, .{ .input = .pull });
    _dout_gpio.high(); // Pull-up
    _pd_sclk_gpio.initialize(.output_2MHz, .{ .output = .pushpull });
    _pd_sclk_gpio.low();
}

pub fn read() ?i24 {
    // If DOUT is high, data is not ready
    if (_dout_gpio.read())
        return null;

    var value: u24 = 0;

    for (0..24) |i| {
        _pd_sclk_gpio.high();
        clock.delay(1);

        const bit: u24 = if (_dout_gpio.read()) 1 else 0;
        value |= bit << @truncate(23 - i); // MSB first

        _pd_sclk_gpio.low();
        clock.delay(1);
    }

    // Last clock to end reading
    // TODO 26 clocks select channel B with gain 32, 27 clocks select channel A with gain 64
    _pd_sclk_gpio.high();
    clock.delay(1);
    _pd_sclk_gpio.low();

    const ivalue: i24 = @bitCast(value);
    return ivalue;
}
