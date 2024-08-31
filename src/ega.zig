const dpmi = @import("dos").dpmi;

const BIOS_INTERRUPT_VIDEO = 0x10; // The BIOS video interrupt number.
const VIDEO_MODE_EGA_640_350_16 = 0x10; // Video mode EGA 640 x 350, 16 colors.

fn videoInterrupt(registers: dpmi.RealModeRegisters) void {
    var regs = registers;
    dpmi.simulateInterrupt(BIOS_INTERRUPT_VIDEO, &regs);
}

pub fn setVideoMode() void {
    // TODO: Add al/ah and ax registers in union with eax.
    videoInterrupt(.{ .eax = VIDEO_MODE_EGA_640_350_16 });
}

pub fn drawPoint(x: u16, y: u16, color: u8) void {
    videoInterrupt(.{ .eax = 0x0C00 | @as(u32, @intCast(color)), .ecx = x, .edx = y });
}
