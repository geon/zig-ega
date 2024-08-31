const std = @import("std");
const ega = @import("ega.zig");

pub const os = @import("dos");
// This is necessary to pull in the start code with Zig 0.11.
comptime {
    _ = @import("dos");
}

pub fn main() !void {
    std.debug.print("Setting EGA mode.\r\n", .{});

    ega.setVideoMode();

    for (0..100) |y| {
        for (0..100) |x| {
            ega.drawPoint(@intCast(x), @intCast(y), 5);
        }
    }
}