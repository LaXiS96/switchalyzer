const std = @import("std");

const config = struct {
    const opencm3_dir: []const u8 = "libopencm3";
    const device: []const u8 = "stm32f103x8";
    const family: []const u8 = "STM32F1";
    const mcpu: []const u8 = "cortex_m3";
    const ldscript: []const u8 = "generated.stm32f103x8.ld";
    const libname: []const u8 = "opencm3_stm32f1";
};

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{
        .default_target = std.zig.CrossTarget.parse(.{
            .arch_os_abi = "thumb-freestanding-none",
            .cpu_features = config.mcpu,
        }) catch unreachable,
    });

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const umm_zig = b.addModule("umm", .{ .source_file = .{ .path = "umm-zig/src/lib.zig" } });

    const ldscript_gen = b.addSystemCommand(&[_][]const u8{ "make", "-f", "Makefile.ldscript" });
    ldscript_gen.addArg("OPENCM3_DIR=" ++ config.opencm3_dir);
    ldscript_gen.addArg("DEVICE=" ++ config.device);

    const ldscript_cmd = b.step("ldscript", "Generate linker script for device");
    ldscript_cmd.dependOn(&ldscript_gen.step);

    const elf = b.addExecutable(.{
        .name = "firmware.elf",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
        .single_threaded = true,
    });

    elf.addModule("umm", umm_zig);

    elf.addIncludePath(.{ .path = config.opencm3_dir ++ "/include" });
    elf.defineCMacro(config.family, null);

    elf.addLibraryPath(.{ .path = config.opencm3_dir ++ "/lib" });
    elf.linkSystemLibrary(config.libname);

    // elf.step.dependOn(&ldscript_gen.step);
    elf.setLinkerScript(.{ .path = config.ldscript });

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(elf);

    const objcopy = b.addObjCopy(elf.getEmittedBin(), .{ .format = .bin });
    objcopy.step.dependOn(&elf.step);

    const bin_install = b.addInstallBinFile(objcopy.getOutput(), "firmware.bin");
    b.getInstallStep().dependOn(&bin_install.step);

    const flash = b.addSystemCommand(&[_][]const u8{ "openocd", "-f", "openocd.cfg", "-c", "program zig-out/bin/firmware.elf verify reset exit" });
    // flash.step.dependOn(&elf.step);

    const flash_cmd = b.step("flash", "Flash firmware to device");
    flash_cmd.dependOn(b.getInstallStep());
    flash_cmd.dependOn(&flash.step);

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(elf);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
