const RCC = @import("rcc.zig").RCC;

const TIMER_TIM2_ADDR = 0x4000_0000;
const TIMER_TIM3_ADDR = 0x4000_0400;
const TIMER_TIM4_ADDR = 0x4000_0800;
const TIMER_TIM5_ADDR = 0x4000_0C00;
const TIMER_TIM6_ADDR = 0x4000_1000;
const TIMER_TIM7_ADDR = 0x4000_1400;
const TIMER_TIM12_ADDR = 0x4000_1800;
const TIMER_TIM13_ADDR = 0x4000_1C00;
const TIMER_TIM14_ADDR = 0x4000_2000;
const TIMER_TIM1_ADDR = 0x4001_2C00;
const TIMER_TIM8_ADDR = 0x4001_3400;
const TIMER_TIM9_ADDR = 0x4001_4C00;
const TIMER_TIM10_ADDR = 0x4001_5000;
const TIMER_TIM11_ADDR = 0x4001_5400;

timer: u32,

pub const Timers = enum(u32) {
    TIM1 = TIMER_TIM1_ADDR,
    TIM2 = TIMER_TIM2_ADDR,
    TIM3 = TIMER_TIM3_ADDR,
    TIM4 = TIMER_TIM4_ADDR,
    TIM5 = TIMER_TIM5_ADDR,
    TIM6 = TIMER_TIM6_ADDR,
    TIM7 = TIMER_TIM7_ADDR,
    TIM8 = TIMER_TIM8_ADDR,
    TIM9 = TIMER_TIM9_ADDR,
    TIM10 = TIMER_TIM10_ADDR,
    TIM11 = TIMER_TIM11_ADDR,
    TIM12 = TIMER_TIM12_ADDR,
    TIM13 = TIMER_TIM13_ADDR,
    TIM14 = TIMER_TIM14_ADDR,
};
pub const StatusFlags = enum(u32) {
    UIF = 1 << 0,
    CC1IF = 1 << 1,
    CC2IF = 1 << 2,
    CC3IF = 1 << 3,
    CC4IF = 1 << 4,
    TIF = 1 << 6,
    CC1OF = 1 << 9,
    CC2OF = 1 << 10,
    CC3OF = 1 << 11,
    CC4OF = 1 << 12,
};

const TimerRegister = packed struct {
    CR1: packed struct(u16) {
        CEN: u1,
        UDIS: u1,
        URS: u1,
        OPM: u1,
        DIR: u1,
        CMS: u2,
        ARPE: u1,
        CKD: u2,
        _rsvd1: u6,
    },
    _rsvd1: u16,
    CR2: packed struct(u16) {
        _rsvd1: u3,
        CCDS: u1,
        MMS: u3,
        TI1S: u1,
        _rsvd2: u8,
    },
    _rsvd2: u16,
    SMCR: u32,
    DIER: u32,
    SR: u32,
    EGR: u32,
    CCMR1: u32,
    CCMR2: u32,
    CCER: u32,
    CNT: u32,
    PSC: u32,
    ARR: u32,
    _rsvd3: u32,
    CCR1: u32,
    CCR2: u32,
    CCR3: u32,
    CCR4: u32,
    _rsvd4: u32,
    DCR: u32,
    DMAR: u32,
};
inline fn getRegister(timer_addr: u32) *volatile TimerRegister {
    return @ptrFromInt(timer_addr);
}

pub fn initialize(self: @This()) void {
    // TODO consider using options struct as input, or create init functions with predefined settings
    const timer_enum: Timers = @enumFromInt(self.timer);
    switch (timer_enum) {
        Timers.TIM1 => RCC.ENR.TIM1EN = 1,
        Timers.TIM2 => RCC.ENR.TIM2EN = 1,
        Timers.TIM3 => RCC.ENR.TIM3EN = 1,
        Timers.TIM4 => RCC.ENR.TIM4EN = 1,
        Timers.TIM5 => RCC.ENR.TIM5EN = 1,
        Timers.TIM6 => RCC.ENR.TIM6EN = 1,
        Timers.TIM7 => RCC.ENR.TIM7EN = 1,
        Timers.TIM8 => RCC.ENR.TIM8EN = 1,
        Timers.TIM9 => RCC.ENR.TIM9EN = 1,
        Timers.TIM10 => RCC.ENR.TIM10EN = 1,
        Timers.TIM11 => RCC.ENR.TIM11EN = 1,
        Timers.TIM12 => RCC.ENR.TIM12EN = 1,
        Timers.TIM13 => RCC.ENR.TIM13EN = 1,
        Timers.TIM14 => RCC.ENR.TIM14EN = 1,
    }
}

pub fn create(timer: Timers) @This() {
    return @This(){
        .timer = @intFromEnum(timer),
    };
}

pub inline fn clearFlag(self: @This(), flag: StatusFlags) void {
    getRegister(self.timer).SR = ~@intFromEnum(flag);
}

pub inline fn hasFlag(self: @This(), flag: StatusFlags) bool {
    return getRegister(self.timer).SR & @intFromEnum(flag) != 0;
}

pub inline fn oneshot(self: @This(), enable: bool) void {
    getRegister(self.timer).CR1.OPM = if (enable) 1 else 0;
}

pub inline fn setPeriod(self: @This(), period: u16) void {
    getRegister(self.timer).ARR = period;
}

pub inline fn start(self: @This()) void {
    getRegister(self.timer).CR1.CEN = 1;
}

pub inline fn stop(self: @This()) void {
    getRegister(self.timer).CR1.CEN = 0;
}

// TODO
