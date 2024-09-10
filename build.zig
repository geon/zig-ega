const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    // const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "zig-ega.exe",
        .target = .{
            .cpu_arch = .x86,
            .cpu_model = .{ .explicit = std.Target.Cpu.Model.generic(.x86) },
            .os_tag = .other,
        },
        .optimize = optimize,
        .root_source_file = .{ .path = "src/main.zig" },
        .single_threaded = true,
    });

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(exe);

    const run_in_dosbox = b.addSystemCommand(&[_][]const u8{"DOSbox"});
    run_in_dosbox.step.dependOn(b.getInstallStep());
    // run_in_dosbox.addFileArg(.{ .cwd_relative = "DOS4GW.EXE" });
    run_in_dosbox.addFileArg(exe.getEmittedBin());

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_in_dosbox.step);
}
