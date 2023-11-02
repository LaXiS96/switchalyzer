const std = @import("std");
const cm3 = @import("cm3.zig");

pub fn init(cpu_clock: u32, trace_clock: u32) void {
    cm3.DBGMCU_CR_ptr.* |= cm3.DBGMCU_CR_TRACE_IOEN | cm3.DBGMCU_CR_TRACE_MODE_ASYNC; // STM32: enable trace pins for SWO
    cm3.SCS_DEMCR_ptr.* |= cm3.SCS_DEMCR_TRCENA; // Enable ITM and DWT
    cm3.TPIU_SPPR_ptr.* = cm3.TPIU_SPPR_ASYNC_NRZ; // Use SWO in NRZ (UART) mode
    cm3.TPIU_ACPR_ptr.* = cpu_clock / trace_clock - 1;
    cm3.TPIU_FFCR_ptr.* &= ~@as(u32, cm3.TPIU_FFCR_ENFCONT); // Disable formatter (discards ETM data)
    cm3.ITM_LAR_ptr.* = 0xc5acce55; // Unlock ITM control register
    cm3.ITM_TCR_ptr.* &= ~@as(u32, cm3.ITM_TCR_TRACE_BUS_ID_MASK); // Set TraceBusID to 0
    cm3.ITM_TCR_ptr.* |= cm3.ITM_TCR_ITMENA; // Enable ITM
    cm3.ITM_TER_ptr[0] = 0xffffffff; // Enable first 32 stimulus ports
}

pub fn allocPrint(allocator: std.mem.Allocator, comptime fmt: []const u8, args: anytype) void {
    const slice = std.fmt.allocPrint(allocator, fmt, args) catch return;
    defer allocator.free(slice);
    for (slice) |c| putChar(c);
}

pub fn bufPrint(comptime fmt: []const u8, args: anytype) void {
    var buf: [256]u8 = undefined;
    const slice = std.fmt.bufPrint(&buf, fmt, args) catch return;
    for (slice) |c| putChar(c);
}

fn putChar(c: u8) void {
    while (cm3.ITM_STIM8_ptr(0).* & cm3.ITM_STIM_FIFOREADY != 1) {}
    cm3.ITM_STIM8_ptr(0).* = c;
}
