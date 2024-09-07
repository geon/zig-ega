const std = @import("std");
const ega = @import("ega.zig");
const BitplaneStrip = @import("BitplaneStrip.zig");

pub const os = @import("dos");
// This is necessary to pull in the start code with Zig 0.11.
comptime {
    _ = @import("dos");
}

pub fn main() !void {
    std.debug.print("Setting EGA mode.\r\n", .{});

    ega.setVideoMode();

    for (0..100) |y| {
        // for (0..100) |x| {
        // ega.drawPoint(@intCast(x), @intCast(y), 5);
        ega.drawStrip(@intCast(y * 80 + 0), BitplaneStrip.fromPixels(.{ 0, 1, 2, 3, 4, 5, 6, 7 }), 0b1111);
        ega.drawStrip(@intCast(y * 80 + 1), BitplaneStrip.fromPixels(.{ 8, 9, 10, 11, 12, 13, 14, 15 }), 0b1111);
        ega.waitForFrame();
        // }
    }
}
