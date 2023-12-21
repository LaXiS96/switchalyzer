const mz = @import("microzig");

const p = mz.chip.peripherals;

pub var ahb_freq: u32 = 8_000_000;
pub var apb1_freq: u32 = 8_000_000;
pub var apb2_freq: u32 = 8_000_000;

pub fn setupClockInHse8Out72() void {
    p.RCC.CR.modify(.{ .HSEON = 1 });
    // TODO mmio could use a bitmask or check fn
    while (p.RCC.CR.raw & (@as(u32, 1) << @bitOffsetOf(@TypeOf(p.RCC.CR).underlying_type, "HSERDY")) == 0)
        asm volatile ("" ::: "memory");

    p.RCC.CFGR.modify(.{
        .HPRE = 0, // AHB = SYSCLK / 1
        .PPRE1 = 0b110, // APB1 = AHB / 2
        .PPRE2 = 0, // APB2 = AHB / 1
        .ADCPRE = 0b10, // ADC = APB2 / 6
        .PLLSRC = 1, // HSE into PLL
        .PLLXTPRE = 0, // HSE / 1
        .PLLMUL = 0b0111, // HSE * 9
    });
    p.FLASH.ACR.modify(.{ .LATENCY = 0b010 }); // 2 flash wait states

    p.RCC.CR.modify(.{ .PLLON = 1 });
    while (p.RCC.CR.raw & (@as(u32, 1) << @bitOffsetOf(@TypeOf(p.RCC.CR).underlying_type, "PLLRDY")) == 0)
        asm volatile ("" ::: "memory");
    p.RCC.CFGR.modify(.{ .SW = 0b10 }); // Switch to PLL as SYSCLK
    // TODO should wait for SWS to confirm switch

    ahb_freq = 72_000_000;
    apb1_freq = 36_000_000;
    apb2_freq = 72_000_000;
}
