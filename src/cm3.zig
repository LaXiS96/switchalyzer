// const c = @cImport({
//     @cDefine("STM32F1", {}); // TODO depend on build.zig config
//     @cInclude("libopencm3/stm32/dbgmcu.h");
//     @cInclude("libopencm3/stm32/rcc.h");
//     @cInclude("libopencm3/stm32/gpio.h");
//     @cInclude("libopencm3/stm32/timer.h");
// });
// pub usingnamespace c;

// // TODO microzig exposes register definitions based on SVDs (but microzig is currently unusable with the stm32 package)

// // Zig cannot yet translate MMIO C macros: https://github.com/ziglang/zig/issues/17778
// // Note: offsets used below may change between different STM32 families, but here I'm using values for STM32F1 (from libopencm3)
