const cm3 = @import("cm3.zig");

var one_us_mult: u32 = 0;

pub fn init() void {
    // TODO defaults are already: no divider, upcounting
    cm3.timer_one_shot_mode(cm3.TIM2);

    const freq = cm3.rcc_get_timer_clk_freq(cm3.TIM2);
    one_us_mult = freq / 1_000_000;
}

/// In Debug mode, small delays are not guaranteed to be accurate
pub fn delay(microseconds: u16) void {
    const period = microseconds * one_us_mult;
    cm3.timer_set_period(cm3.TIM2, period);
    cm3.timer_clear_flag(cm3.TIM2, cm3.TIM_SR_UIF);
    cm3.timer_enable_counter(cm3.TIM2);
    while (!cm3.timer_get_flag(cm3.TIM2, cm3.TIM_SR_UIF)) {}
}
