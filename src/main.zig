const std = @import("std");
const umm = @import("umm");
const cm3 = @import("cm3.zig");
const hal = @import("stm32f1.zig");
const trace = @import("trace.zig");
const clock = @import("clock.zig");
const hx711 = @import("hx711.zig");

// const umm_alloc_t = umm.UmmAllocator(.{});
// var umm_heap: [5120]u8 = undefined;
// var allocator: std.mem.Allocator = undefined;

const hx711_dout_gpio = hal.Gpio.create(.A, 1);
const hx711_pd_sclk_gpio = hal.Gpio.create(.A, 2);

export fn main() void {
    cm3.rcc_clock_setup_in_hse_8mhz_out_72mhz();
    cm3.rcc_periph_clock_enable(cm3.RCC_TIM2);
    // cm3.rcc_periph_reset_pulse(cm3.RST_TIM2);

    // var umm_alloc = umm_alloc_t.init(&umm_heap) catch unreachable;
    // allocator = umm_alloc.allocator();

    clock.init();
    hx711.init(hx711_dout_gpio, hx711_pd_sclk_gpio);

    while (true) {
        // Note: HX711 has a 10Hz conversion rate, if we miss the DOUT low pulse (~75us) we might need to switch to interrupts
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

// Functions below are vector handlers declared by libopencm3

export fn hard_fault_handler() void {
    trace.write("hard fault");
    while (true) {
        @breakpoint();
    }
}

export fn mem_manage_handler() void {
    trace.write("memory management fault");
    while (true) {
        @breakpoint();
    }
}

export fn bus_fault_handler() void {
    trace.write("bus fault");
    while (true) {
        @breakpoint();
    }
}

export fn usage_fault_handler() void {
    trace.write("usage fault");
    while (true) {
        @breakpoint();
    }
}
