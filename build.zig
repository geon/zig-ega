const std = @import("std");
const Build = std.Build;
const Cpu = std.Target.Cpu;

const FileRecipeStep = @import("dos.zig/src/build/FileRecipeStep.zig");

pub fn build(b: *Build) !void {
    const optimize = switch (b.standardOptimizeOption(.{})) {
        .Debug => .ReleaseSafe, // TODO: Support debug builds.
        else => |opt| opt,
    };

    const main_coff = b.addExecutable(.{
        .name = "main",
        .target = .{
            .cpu_arch = .x86,
            .cpu_model = .{ .explicit = Cpu.Model.generic(.x86) },
            .os_tag = .other,
        },
        .optimize = optimize,
        .root_source_file = .{ .path = "src/main.zig" },
        .single_threaded = true,
    });

    main_coff.addModule("dos", b.addModule("dos", .{
        .source_file = .{ .path = "dos.zig/src/dos.zig" },
    }));

    main_coff.setLinkerScriptPath(.{ .path = "dos.zig/src/djcoff.ld" });
    main_coff.disable_stack_probing = true;
    main_coff.strip = true;

    const main_exe_inputs = [_]Build.LazyPath{
        .{ .path = "dos.zig/deps/cwsdpmi/bin/CWSDSTUB.EXE" },
        main_coff.addObjCopy(.{ .format = .bin }).getOutput(),
    };
    const main_exe = FileRecipeStep.create(b, concatFiles, &main_exe_inputs, .bin, "main.exe");

    const installed_main = b.addInstallBinFile(main_exe.getOutput(), "main.exe");
    b.getInstallStep().dependOn(&installed_main.step);

    const run_in_dosbox = b.addSystemCommand(&[_][]const u8{"DOSbox"});
    run_in_dosbox.addFileArg(installed_main.source);

    const run = b.step("run", "Run the executable in DOSBox");
    run.dependOn(&run_in_dosbox.step);
}

fn concatFiles(_: *Build, inputs: []std.fs.File, output: std.fs.File) !void {
    for (inputs) |input| try output.writeFileAll(input, .{});
}
