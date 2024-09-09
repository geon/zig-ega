const ports = @import("ports.zig");
const inp = ports.inp;
const outp = ports.outp;
const BitplaneStrip = @import("BitplaneStrip.zig");
pub const os = @import("dos");

const BIOS_INTERRUPT_VIDEO = 0x10; // The BIOS video interrupt number.
const SET_CURRENT_VIDEO_MODE = 0x0; // Interrupt service number.
const VIDEO_MODE_EGA_640_350_16 = 0x10; // Video mode EGA 640 x 350, 16 colors.

const bufferBaseAddress: *u8 = @ptrFromInt(0xa0000);

pub fn grantAccess() void {
    const segment = os.dpmi.Segment.create();
    errdefer segment.destroy();

    segment.setBaseAddress(@intFromPtr(bufferBaseAddress));
    segment.setAccessRights(.{
        .type = .data,
        .flags = .{ .data = .{ .writeable = true } },
        .granularity = .page,
    });
    segment.setLimit(0xffff);
}

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

pub fn drawStrip(index: u16, bitplaneStrip: BitplaneStrip, mask: u4) void {
    _ = bitplaneStrip;

    // write modes:
    // 	* 0. Write the latched pixels, combined with CPU data as per register 3. Default is unmodified CPU/latch depending on mask.
    // 	* 1. Write the latched pixels. The byte written by the cpu are irrelevant. (Not sure how this is different from mode 0 with a zeroed out mask.)
    // 	* 2. Write a single color to all 8 pixels.

    const stripAddress: *u8 = @ptrFromInt(@intFromPtr(bufferBaseAddress) + index);
    // uint8_t bitplane0 = bitplaneStrip.planes[0];
    // uint8_t bitplane1 = bitplaneStrip.planes[1];
    // uint8_t bitplane2 = bitplaneStrip.planes[2];
    // uint8_t bitplane3 = bitplaneStrip.planes[3];

    // const uint8_t allBits = BIT_0 | BIT_1 | BIT_2 | BIT_3;

    // Set up write mode.
    outp(
        // 6845 command register
        0x03CE,
        // Specify mode register
        5,
        // Write. Latched data will be used where the mask bits are 0.
        0,
    );
    outp(
        // 6845 command register
        0x03CE,
        // Data Rotate register
        3,
        // No bit rotation, no AND, OR or XOR.
        0,
    );

    // Set the mask.
    outp(
        // 6845 command register
        0x03CE,
        // Specify bit mask register
        8,
        // The mask.
        mask,
    );

    asm volatile (
    // Read existing pixels to EGA latch, so masking works. The result in the AL register is not used.
        \\ movb (%%ebx), %%al
        :
        // Write the stripAddress pointer to the register.
        : [_] "{ebx}" (@as(u32, @intFromPtr(stripAddress))),
    );

    // Enable plane 0.
    outp(
        // 6845 command register
        0x03C4,
        // Specify sequencer register
        2,
        // Bit 0
        0b1,
    );

    // // Draw the strip.
    // asm volatile (
    //     \\ movb %%al, (%%ebx)
    //     :
    //     : [_] "{al}" (bitplaneStrip.planes[0]),
    // );

    // Enable plane 1.
    outp(
        // 6845 command register
        0x03C4,
        // Specify sequencer register
        2,
        // Bit 1
        0b10,
    );

    // // Draw the strip.
    // asm volatile (
    //     \\ movb %%al, (%%ebx)
    //     :
    //     : [_] "{al}" (bitplaneStrip.planes[1]),
    // );

    // Enable plane 0.
    outp(
        // 6845 command register
        0x03C4,
        // Specify sequencer register
        2,
        // Bit 2
        0b100,
    );

    // // Draw the strip.
    // asm volatile (
    //     \\ movb %%al, (%%ebx)
    //     :
    //     : [_] "{al}" (bitplaneStrip.planes[2]),
    // );

    // Enable plane 1.
    outp(
        // 6845 command register
        0x03C4,
        // Specify sequencer register
        2,
        // Bit 3
        0b1000,
    );

    // // Draw the strip.
    // asm volatile (
    //     \\ movb %%al, (%%ebx)
    //     :
    //     : [_] "{al}" (bitplaneStrip.planes[3]),
    // );
}
