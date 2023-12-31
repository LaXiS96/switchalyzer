const std = @import("std");
const mz = @import("microzig");
const hal = @import("stm32f1/_index.zig");
const clock = @import("stm32f1/clock.zig");
const trace = @import("trace.zig");
const time = @import("time.zig");
const hx711 = @import("hx711.zig");

const hx711_dout_gpio = hal.Gpio.create(mz.chip.peripherals.GPIOA, 1);
const hx711_pd_sclk_gpio = hal.Gpio.create(mz.chip.peripherals.GPIOA, 2);

pub fn main() !void {
    clock.setupClockInHse8Out72();
    // cm3.rcc_periph_reset_pulse(cm3.RST_TIM2);

    try time.initialize(mz.chip.peripherals.TIM2, 72_000_000);
    try hx711.initialize(hx711_dout_gpio, hx711_pd_sclk_gpio);

    while (true) {
        // Note: HX711 has a 10Hz conversion rate, if we miss the DOUT low pulse (~75us) we might need to switch to interrupts
        const reading = hx711.read();
        if (reading) |read|
            std.log.info("hx711: {d}\n", .{read});
    }
}

pub const std_options = struct {
    pub fn logFn(comptime message_level: std.log.Level, comptime scope: @Type(.EnumLiteral), comptime format: []const u8, args: anytype) void {
        _ = message_level;
        _ = scope;
        trace.bufPrint(format, args);
    }
};

pub const microzig_options = struct {
    pub const interrupts = struct {
        pub fn NMI() void {
            trace.bufPrint("NMI", .{});
        }
        pub fn HardFault() void {
            @panic("HardFault");
        }
        pub fn MemManageFault() void {
            @panic("MemManageFault");
        }
        pub fn BusFault() void {
            @panic("BusFault");
        }
        pub fn UsageFault() void {
            @panic("UsageFault");
        }
    };
};
