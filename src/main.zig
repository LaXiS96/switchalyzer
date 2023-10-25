const std = @import("std");
const cm3 = @cImport({
    @cDefine("STM32F1", {}); // TODO depend on build.zig config
    @cInclude("libopencm3/stm32/rcc.h");
    @cInclude("libopencm3/stm32/gpio.h");
});

export fn main() void {
    cm3.rcc_clock_setup_in_hse_8mhz_out_72mhz();

    cm3.rcc_periph_clock_enable(cm3.RCC_GPIOC);
    cm3.gpio_set_mode(cm3.GPIOC, cm3.GPIO_MODE_OUTPUT_2_MHZ, cm3.GPIO_CNF_OUTPUT_OPENDRAIN, cm3.GPIO13);

    while (true) {
        cm3.gpio_toggle(cm3.GPIOC, cm3.GPIO13);
        for (0..1_000_000) |_|
            asm volatile ("nop");
    }
}
