const _test = @compileLog("test");
const root = @import("root");
const std = @import("std");
const trace = @import("trace.zig");

const main: fn () void = if (@hasDecl(root, "main")) root.main else @compileError("missing main fn in root source file");

// Constants whose address is set by the linker (see linker script)
extern const __stack: usize;
extern const __data: usize;
extern const __data_end: usize;
extern const __data_loadaddr: usize;
extern const __bss: usize;
extern const __bss_end: usize;

const VectorHandler = *const fn () callconv(.C) void;

const VectorTable = extern struct {
    stack_pointer: *usize,
    reset: VectorHandler,
    nmi: VectorHandler,
    hard_fault: VectorHandler,
    mem_manage: VectorHandler,
    bus_fault: VectorHandler,
    usage_fault: VectorHandler,
    _rsvd1: [4]usize = [_]usize{ 0, 0, 0, 0 },
    sv_call: VectorHandler,
    debug_monitor: VectorHandler,
    _rsvd2: usize = 0,
    pend_sv: VectorHandler,
    systick: VectorHandler,
    // TODO irqs
};

export const vector_table: VectorTable linksection(".vector_table") = .{
    .stack_pointer = &__stack,
    .reset = reset_handler,
    .nmi = null_handler,
    .hard_fault = hard_fault_handler,
    .mem_manage = mem_manage_handler,
    .bus_fault = bus_fault_handler,
    .usage_fault = usage_fault_handler,
    .sv_call = null_handler,
    .debug_monitor = null_handler,
    .pend_sv = null_handler,
    .systick = null_handler,
};

export fn reset_handler() void {
    const data_len = (@intFromPtr(&__data_end) - @intFromPtr(&__data)) / @sizeOf(usize);
    const data_load: [*]usize = @ptrCast(&__data_loadaddr);
    const data: [*]usize = @ptrCast(&__data);
    @memcpy(data[0..data_len], data_load);

    const bss_len = (@intFromPtr(&__bss_end) - @intFromPtr(&__bss)) / @sizeOf(usize);
    const bss: [*]usize = @ptrCast(&__bss);
    @memset(bss[0..bss_len], 0);

    main();
}

export fn null_handler() void {
    // Do nothing
}

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
