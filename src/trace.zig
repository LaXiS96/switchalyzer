const std = @import("std");
const cm3 = @import("cm3.zig");

pub fn allocPrint(allocator: std.mem.Allocator, comptime fmt: []const u8, args: anytype) void {
    if (!isStimEnabled(0))
        return;

    const slice = std.fmt.allocPrint(allocator, fmt, args) catch return;
    defer allocator.free(slice);
    for (slice) |c|
        send8_blocking(0, c);
}

pub fn bufPrint(comptime fmt: []const u8, args: anytype) void {
    if (!isStimEnabled(0))
        return;

    var buf: [256]u8 = undefined;
    const slice = std.fmt.bufPrint(&buf, fmt, args) catch return;
    for (slice) |c|
        send8_blocking(0, c);
}

inline fn isStimEnabled(stim_port: u8) bool {
    const ter = stim_port / 32;
    const port: u5 = @truncate(stim_port % 32);
    return cm3.ITM_TER_ptr[ter] & (@as(u32, 1) << port) != 0;
}

fn send8_blocking(stim_port: u8, c: u8) void {
    if (!isStimEnabled(stim_port))
        return;

    while (cm3.ITM_STIM8_ptr(stim_port).* & cm3.ITM_STIM_FIFOREADY == 0) {}
    cm3.ITM_STIM8_ptr(stim_port).* = c;
}
