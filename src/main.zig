const std = @import("std");
const umm = @import("umm");
const cm3 = @import("cm3.zig");
const trace = @import("trace.zig");

const umm_alloc_t = umm.UmmAllocator(.{});
var umm_heap: [5120]u8 = undefined;
var allocator: std.mem.Allocator = undefined;

export fn main() void {
    var umm_alloc = umm_alloc_t.init(&umm_heap) catch unreachable;
    allocator = umm_alloc.allocator();

    cm3.rcc_clock_setup_in_hse_8mhz_out_72mhz();

    cm3.rcc_periph_clock_enable(cm3.RCC_GPIOC);
    cm3.gpio_set_mode(cm3.GPIOC, cm3.GPIO_MODE_OUTPUT_2_MHZ, cm3.GPIO_CNF_OUTPUT_OPENDRAIN, cm3.GPIO13);

    trace.init(72000000, 2000000);

    cm3.systick_set_clocksource(cm3.STK_CSR_CLKSOURCE_AHB_DIV8);
    cm3.systick_set_reload(8999);
    cm3.systick_interrupt_enable();
    cm3.systick_counter_enable();

    while (true) {
        cm3.gpio_toggle(cm3.GPIOC, cm3.GPIO13);
        // trace.print("Hello, World!\n", .{});
        trace.allocPrint(allocator, "Hello, World!\n", .{});
        for (0..4_000_000) |_|
            asm volatile ("nop");
    }
}

var ctr: u32 = 0;
export fn sys_tick_handler() void {
    ctr += 1;
    if (ctr == 1000) {
        trace.allocPrint(allocator, "systick\n", .{});
        ctr = 0;
    }
}
