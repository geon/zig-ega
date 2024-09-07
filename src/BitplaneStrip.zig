const Self = @This();

const BIT_0: u4 = 0b1;
const BIT_1: u4 = 0b10;
const BIT_2: u4 = 0b100;
const BIT_3: u4 = 0b1000;

planes: [4]u8 = undefined,

// Turn an array of 8 4-bit colors into 4 bit-planes, each 8-bit wide.
pub fn fromPixels(pixels: [8]u4) Self {
    return Self{ .planes = .{
        (@as(u8, pixels[0]) & BIT_0) << 7 | (@as(u8, pixels[1]) & BIT_0) << 6 | (@as(u8, pixels[2]) & BIT_0) << 5 | (@as(u8, pixels[3]) & BIT_0) << 4 | (@as(u8, pixels[4]) & BIT_0) << 3 | (@as(u8, pixels[5]) & BIT_0) << 2 | (@as(u8, pixels[6]) & BIT_0) << 1 | (@as(u8, pixels[7]) & BIT_0) << 0,
        (@as(u8, pixels[0]) & BIT_1) << 6 | (@as(u8, pixels[1]) & BIT_1) << 5 | (@as(u8, pixels[2]) & BIT_1) << 4 | (@as(u8, pixels[3]) & BIT_1) << 3 | (@as(u8, pixels[4]) & BIT_1) << 2 | (@as(u8, pixels[5]) & BIT_1) << 1 | (@as(u8, pixels[6]) & BIT_1) << 0 | (@as(u8, pixels[7]) & BIT_1) >> 1,
        (@as(u8, pixels[0]) & BIT_2) << 5 | (@as(u8, pixels[1]) & BIT_2) << 4 | (@as(u8, pixels[2]) & BIT_2) << 3 | (@as(u8, pixels[3]) & BIT_2) << 2 | (@as(u8, pixels[4]) & BIT_2) << 1 | (@as(u8, pixels[5]) & BIT_2) << 0 | (@as(u8, pixels[6]) & BIT_2) >> 1 | (@as(u8, pixels[7]) & BIT_2) >> 2,
        (@as(u8, pixels[0]) & BIT_3) << 4 | (@as(u8, pixels[1]) & BIT_3) << 3 | (@as(u8, pixels[2]) & BIT_3) << 2 | (@as(u8, pixels[3]) & BIT_3) << 1 | (@as(u8, pixels[4]) & BIT_3) << 0 | (@as(u8, pixels[5]) & BIT_3) >> 1 | (@as(u8, pixels[6]) & BIT_3) >> 2 | (@as(u8, pixels[7]) & BIT_3) >> 3,
    } };
}

// Turn 8 4-bit nibbles into bit planes.
pub fn fromU32(nibbleStrip: u32) Self {
    return fromPixels(.{
        (nibbleStrip >> (4 * 7)) & 0b1111,
        (nibbleStrip >> (4 * 6)) & 0b1111,
        (nibbleStrip >> (4 * 5)) & 0b1111,
        (nibbleStrip >> (4 * 4)) & 0b1111,
        (nibbleStrip >> (4 * 3)) & 0b1111,
        (nibbleStrip >> (4 * 2)) & 0b1111,
        (nibbleStrip >> (4 * 1)) & 0b1111,
        (nibbleStrip >> (4 * 0)) & 0b1111,
    });
}
