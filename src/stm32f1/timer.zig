const std = @import("std");
const mz = @import("microzig");

pub const TimerT = @TypeOf(mz.chip.peripherals.TIM2); // TODO how to accept different timer types, with subset of required functionality?
pub const StatusFlags = std.meta.FieldEnum(@TypeOf(mz.chip.peripherals.TIM2.SR).underlying_type);

timer: TimerT,

pub fn create(timer: TimerT) @This() {
    return @This(){
        .timer = timer,
    };
}

pub fn initialize(self: @This()) !void {
    // TODO should reset via rcc
    const pps = mz.chip.peripherals;
    switch (self.timer) { // TODO ENR bitfields change between STM32 families (different buses architecture), this is not flexible
        // pps.TIM1 => pps.RCC.APB2ENR.modify(.{ .TIM1EN = 1 }),
        pps.TIM2 => pps.RCC.APB1ENR.modify(.{ .TIM2EN = 1 }),
        pps.TIM3 => pps.RCC.APB1ENR.modify(.{ .TIM3EN = 1 }),
        pps.TIM4 => pps.RCC.APB1ENR.modify(.{ .TIM4EN = 1 }),
        pps.TIM5 => pps.RCC.APB1ENR.modify(.{ .TIM5EN = 1 }),
        // pps.TIM6 => pps.RCC.APB1ENR.modify(.{ .TIM6EN = 1 }),
        // pps.TIM7 => pps.RCC.APB1ENR.modify(.{ .TIM7EN = 1 }),
        // pps.TIM8 => pps.RCC.APB2ENR.modify(.{ .TIM8EN = 1 }),
        // pps.TIM9 => pps.RCC.APB2ENR.modify(.{ .TIM9EN = 1 }),
        // pps.TIM10 => pps.RCC.APB2ENR.modify(.{ .TIM10EN = 1 }),
        // pps.TIM11 => pps.RCC.APB2ENR.modify(.{ .TIM11EN = 1 }),
        // pps.TIM12 => pps.RCC.APB1ENR.modify(.{ .TIM12EN = 1 }),
        // pps.TIM13 => pps.RCC.APB1ENR.modify(.{ .TIM13EN = 1 }),
        // pps.TIM14 => pps.RCC.APB1ENR.modify(.{ .TIM14EN = 1 }),
        else => return error.InvalidTimer,
    }
}

pub inline fn clearFlag(self: @This(), comptime flag: StatusFlags) void {
    var reg = self.timer.SR.read();
    @field(reg, @tagName(flag)) = 0;
    self.timer.SR.write(reg);
}

pub inline fn hasFlag(self: @This(), comptime flag: StatusFlags) bool {
    const reg = self.timer.SR.read();
    return @field(reg, @tagName(flag)) != 0;
}

pub inline fn oneshot(self: @This(), enable: bool) void {
    self.timer.CR1.modify(.{ .OPM = if (enable) 1 else 0 });
}

pub inline fn setPeriod(self: @This(), period: u16) void {
    self.timer.ARR.write(.{ .ARR = period, .padding = 0 });
}

pub inline fn start(self: @This()) void {
    self.timer.CR1.modify(.{ .CEN = 1 });
}

pub inline fn stop(self: @This()) void {
    self.timer.CR1.modify(.{ .CEN = 0 });
}
