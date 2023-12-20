const std = @import("std");
const stm32 = @import("stmicro-stm32/build.zig");

pub fn build(b: *std.Build) !void {
    const microzig = @import("microzig").init(b, "microzig");

    const optimize = b.standardOptimizeOption(.{});

    const firmware = microzig.addFirmware(b, .{
        .name = "firmware",
        .source_file = .{ .path = "src/main.zig" },
        .target = stm32.chips.stm32f103x8,
        .optimize = optimize,
    });
    microzig.installFirmware(b, firmware, .{});

    const flash = b.addSystemCommand(&[_][]const u8{ "openocd", "-f", "openocd.cfg", "-c", "program zig-out/firmware/firmware.elf verify reset exit" });
    flash.step.dependOn(b.getInstallStep());

    const flash_cmd = b.step("flash", "Flash firmware to device");
    flash_cmd.dependOn(&flash.step);
}
