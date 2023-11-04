const std = @import("std");
const umm = @import("umm");
const cm3 = @import("cm3.zig");
const trace = @import("trace.zig");
const clock = @import("clock.zig");
const Gpio = @import("gpio.zig");
const hx711 = @import("hx711.zig");

const umm_alloc_t = umm.UmmAllocator(.{});
var umm_heap: [5120]u8 = undefined;
var allocator: std.mem.Allocator = undefined;

const hx711_dout_gpio = Gpio.create(.A, .IO1);
const hx711_pd_sclk_gpio = Gpio.create(.A, .IO2);

export fn main() void {
    cm3.rcc_clock_setup_in_hse_8mhz_out_72mhz();
    cm3.rcc_periph_clock_enable(cm3.RCC_GPIOA);
    cm3.rcc_periph_clock_enable(cm3.RCC_TIM2);
    cm3.rcc_periph_reset_pulse(cm3.RST_TIM2);

    var umm_alloc = umm_alloc_t.init(&umm_heap) catch unreachable;
    allocator = umm_alloc.allocator();

    clock.init();
    hx711.init(hx711_dout_gpio, hx711_pd_sclk_gpio);

    while (true) {
        // cm3.gpio_toggle(cm3.GPIOC, cm3.GPIO13);
        // trace.allocPrint(allocator, "Hello, World!\n", .{});
        // for (0..4_000_000) |_|
        //     asm volatile ("nop");
        hx711.loop();
    }
}

pub fn panic(msg: []const u8, error_return_trace: ?*std.builtin.StackTrace, ret_addr: ?usize) noreturn {
    _ = ret_addr;
    _ = error_return_trace;

    trace.write("panic: ");
    trace.write(msg);

    while (true) {
        @breakpoint();
    }
}
