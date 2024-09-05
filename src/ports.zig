pub fn inp(port: u16) u16 {
    return asm (
    // https://c9x.me/x86/html/file_module_x86_id_139.html
        \\ inw %%dx, %%ax
        : [res] "={ax}" (-> u16),
          // Specify port to read from
        : [_] "{dx}" (@as(u16, port)),
    );
}
