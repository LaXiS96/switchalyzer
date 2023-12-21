const std = @import("std");
const hal = @import("stm32f1/_index.zig");

var _timer: hal.Timer = undefined;
var _one_us_ticks: u16 = 0;

pub fn initialize(timer: hal.Timer.TimerT, clk_freq: u32) !void {
    _timer = hal.Timer.create(timer);
    try _timer.initialize();
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
    while (!_timer.hasFlag(.UIF))
        asm volatile ("" ::: "memory"); // TODO needed because of compiler bug in 0.11.0, fixed as of 0.12.0-dev.1830+779b8e259
}
