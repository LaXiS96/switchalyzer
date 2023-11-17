const ITM_BASE_ADDR = 0xe000_0000;

pub const STIM_FIFOREADY: u32 = 1 << 0;

pub const TER: *volatile [8]u32 = @ptrFromInt(ITM_BASE_ADDR + 0xe00);

pub inline fn STIM8(stim_port: u8) *volatile u8 {
    return @ptrFromInt(ITM_BASE_ADDR + @as(u32, stim_port) * 4);
}
