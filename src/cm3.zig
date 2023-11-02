const c = @cImport({
    @cDefine("STM32F1", {}); // TODO depend on build.zig config
    @cInclude("libopencm3/cm3/scs.h");
    @cInclude("libopencm3/cm3/tpiu.h");
    @cInclude("libopencm3/cm3/itm.h");
    @cInclude("libopencm3/cm3/systick.h");
    @cInclude("libopencm3/stm32/rcc.h");
    @cInclude("libopencm3/stm32/gpio.h");
    @cInclude("libopencm3/stm32/dbgmcu.h");
});
pub usingnamespace c;

// These MMIO addresses are manually translated since Zig cannot yet translate MMIO C macros
// https://github.com/ziglang/zig/issues/17778

pub const SCS_DEMCR_ptr: *volatile u32 = @ptrFromInt(c.SCS_BASE + 0xDFC);

pub const TPIU_ACPR_ptr: *volatile u32 = @ptrFromInt(c.TPIU_BASE + 0x010);
pub const TPIU_SPPR_ptr: *volatile u32 = @ptrFromInt(c.TPIU_BASE + 0x0F0);
pub const TPIU_FFCR_ptr: *volatile u32 = @ptrFromInt(c.TPIU_BASE + 0x304);

pub const DBGMCU_CR_ptr: *volatile u32 = @ptrFromInt(c.DBGMCU_BASE + 0x04);

pub const ITM_TER_ptr: [*]volatile u32 = @ptrFromInt(c.ITM_BASE + 0xE00);
pub const ITM_TCR_ptr: *volatile u32 = @ptrFromInt(c.ITM_BASE + 0xE80);
pub const ITM_LAR_ptr: *volatile u32 = @ptrFromInt(c.ITM_BASE + c.CORESIGHT_LAR_OFFSET);
pub inline fn ITM_STIM8_ptr(stim_port: u8) *volatile u8 {
    return @ptrFromInt(c.ITM_BASE + stim_port * 4);
}
