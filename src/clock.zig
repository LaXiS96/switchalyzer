const std = @import("std");
const hal = @import("stm32f1/_index.zig");

var _timer: hal.Timer = undefined;
var _one_us_ticks: u16 = 0;

pub fn initialize(timer: hal.Timer.Timers, clk_freq: u32) void {
    _timer = hal.Timer.create(timer);
    _timer.initialize();
    // TODO defaults are already: no divider, upcounting
    _timer.oneshot(true);

    // TODO const freq = cm3.rcc_get_timer_clk_freq(cm3.TIM2);
    _one_us_ticks = @intCast(clk_freq / 1_000_000);
}

/// In Debug builds, small delays are not guaranteed to be accurate
pub fn delay(microseconds: u16) void {
    const period = std.math.mul(u16, microseconds, _one_us_ticks) catch 65535;
    _timer.setPeriod(period);

    _timer.clearFlag(.UIF);
    _timer.start();
    while (!_timer.hasFlag(.UIF)) {}
}
