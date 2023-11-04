const c = @cImport({
    @cDefine("STM32F1", {}); // TODO depend on build.zig config
    @cInclude("libopencm3/cm3/itm.h");
    @cInclude("libopencm3/cm3/systick.h");
    @cInclude("libopencm3/stm32/dbgmcu.h");
    @cInclude("libopencm3/stm32/rcc.h");
    @cInclude("libopencm3/stm32/gpio.h");
    @cInclude("libopencm3/stm32/timer.h");
});
pub usingnamespace c;

// TODO microzig exposes register definitions based on SVDs (but microzig is currently unusable with the stm32 package)

// Zig cannot yet translate MMIO C macros: https://github.com/ziglang/zig/issues/17778
// Note: offsets used below may change between different STM32 families, but here I'm using values for STM32F1 (from libopencm3)

pub const ITM_TER_mmio: [*]volatile u32 = @ptrFromInt(c.ITM_BASE + 0xE00);
pub inline fn ITM_STIM8_mmio(stim_port: u8) *volatile u8 {
    return @ptrFromInt(c.ITM_BASE + stim_port * 4);
}

pub const gpio = struct {
    pub const ports = enum(u32) {
        A = c.GPIOA,
        B = c.GPIOB,
        C = c.GPIOC,
    };
    pub const pins = enum(u16) {
        IO0 = 1 << 0,
        IO1 = 1 << 1,
        IO2 = 1 << 2,
        IO3 = 1 << 3,
        IO4 = 1 << 4,
        IO5 = 1 << 5,
        IO6 = 1 << 6,
        IO7 = 1 << 7,
        IO8 = 1 << 8,
        IO9 = 1 << 9,
        IO10 = 1 << 10,
        IO11 = 1 << 11,
        IO12 = 1 << 12,
        IO13 = 1 << 13,
        IO14 = 1 << 14,
        IO15 = 1 << 15,
    };

    pub inline fn BSRR(port: u32) *volatile u32 {
        return @ptrFromInt(port + 0x10);
    }
    pub inline fn IDR(port: u32) *volatile u32 {
        return @ptrFromInt(port + 0x08);
    }
};
