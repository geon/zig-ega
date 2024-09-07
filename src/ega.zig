const ports = @import("ports.zig");
const inp = ports.inp;
const outp = ports.outp;

const BIOS_INTERRUPT_VIDEO = 0x10; // The BIOS video interrupt number.
const SET_CURRENT_VIDEO_MODE = 0x0; // Interrupt service number.
const VIDEO_MODE_EGA_640_350_16 = 0x10; // Video mode EGA 640 x 350, 16 colors.

pub fn setVideoMode() void {
    // 0x10 = BIOS_INTERRUPT_VIDEO
    asm volatile (
        \\ int $0x10
        :
        : [_] "{ah}" (@as(u8, SET_CURRENT_VIDEO_MODE)),
          [_] "{al}" (@as(u8, VIDEO_MODE_EGA_640_350_16)),
    );
}

pub fn waitForFrame() void {
    // The address of the input status register and crt controller.
    const videoIsr = 0x03da;
    // Wait for a vertical retrace.
    while ((inp(videoIsr) & 8) == 0) {}
    // Wait for horizontal or vertical retrace.
    while ((inp(videoIsr) & 1) != 0) {}
}

pub fn drawPoint(x: u16, y: u16, color: u8) void {
    // 0x10 = BIOS_INTERRUPT_VIDEO
    asm volatile (
        \\ int $0x10
        :
        : [_] "{ah}" (@as(u8, 0x0C)),
          [_] "{al}" (color),
          [_] "{cx}" (x),
          [_] "{dx}" (y),
    );
}
