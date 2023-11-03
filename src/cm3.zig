const c = @cImport({
    @cDefine("STM32F1", {}); // TODO depend on build.zig config
    @cInclude("libopencm3/cm3/itm.h");
    @cInclude("libopencm3/cm3/systick.h");
    @cInclude("libopencm3/stm32/rcc.h");
    @cInclude("libopencm3/stm32/gpio.h");
    @cInclude("libopencm3/stm32/dbgmcu.h");
});
pub usingnamespace c;

// Zig cannot yet translate MMIO C macros: https://github.com/ziglang/zig/issues/17778
pub const ITM_TER_ptr: [*]volatile u32 = @ptrFromInt(c.ITM_BASE + 0xE00);
pub inline fn ITM_STIM8_ptr(stim_port: u8) *volatile u8 {
    return @ptrFromInt(c.ITM_BASE + stim_port * 4);
}
