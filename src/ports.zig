pub fn inp(port: u16) u16 {
    return asm (
        \\ inw %%dx, %%ax
        : [res] "={ax}" (-> u16),
          // Specify port to read from
        : [_] "{dx}" (@as(u16, port)),
    );
}

pub fn outp(port: u16, al: u8, ah: u8) void {
    return asm volatile (
        \\ outw %%ax, %%dx
        :
        // Specify port to write to
        : [_] "{dx}" (@as(u16, port)),
          // Arguments
          [_] "{al}" (al),
          [_] "{ah}" (ah),
    );
}
