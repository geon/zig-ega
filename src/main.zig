const ega = @import("ega.zig");
const BitplaneStrip = @import("BitplaneStrip.zig");

pub fn main() !void {
    ega.setVideoMode();
    ega.drawPoint(@intCast(100), @intCast(100), 5);
}
