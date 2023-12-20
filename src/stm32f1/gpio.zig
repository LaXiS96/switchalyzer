const mz = @import("microzig");

const GpioPort = @TypeOf(mz.chip.peripherals.GPIOA);

// TODO do we really need to have a struct in memory? in most cases gpios are predefined and do not change at runtime

port: GpioPort,
pin: u4,

pub const Modes = enum(u2) {
    input = 0b00,
    output_10MHz = 0b01,
    output_2MHz = 0b10,
    output_50MHz = 0b11,
};
pub const Cnfs = union {
    input: Input,
    output: Output,

    const Input = enum(u2) {
        analog = 0b00,
        float = 0b01,
        pull = 0b10,
    };
    const Output = enum(u2) {
        pushpull = 0b00,
        opendrain = 0b01,
        alternate_pushpull = 0b10,
        alternate_opendrain = 0b11,
    };
};

pub fn create(port: GpioPort, pin: u4) @This() {
    return @This(){
        .port = port,
        .pin = pin,
    };
}

pub inline fn high(self: @This()) void {
    self.port.BSRR.raw = @as(u32, 1) << self.pin;
}

pub fn initialize(self: @This(), mode: Modes, cnf: Cnfs) !void {

    // Enable clock for GPIO port
    const pps = mz.chip.peripherals;
    switch (self.port) {
        pps.GPIOA => pps.RCC.APB2ENR.modify(.{ .IOPAEN = 1 }),
        pps.GPIOB => pps.RCC.APB2ENR.modify(.{ .IOPBEN = 1 }),
        pps.GPIOC => pps.RCC.APB2ENR.modify(.{ .IOPCEN = 1 }),
        pps.GPIOD => pps.RCC.APB2ENR.modify(.{ .IOPDEN = 1 }),
        pps.GPIOE => pps.RCC.APB2ENR.modify(.{ .IOPEEN = 1 }),
        pps.GPIOF => pps.RCC.APB2ENR.modify(.{ .IOPFEN = 1 }),
        pps.GPIOG => pps.RCC.APB2ENR.modify(.{ .IOPGEN = 1 }),
        else => return error.InvalidPort,
    }

    var cr: u32 = undefined;
    var offset: u5 = undefined;
    if (self.pin >= 8) {
        cr = self.port.CRH.raw;
        offset = (self.pin - 8) * 4;
    } else {
        cr = self.port.CRL.raw;
        offset = self.pin * 4;
    }

    const cnf_value: u4 = if (mode == Modes.input)
        @intFromEnum(cnf.input)
    else
        @intFromEnum(cnf.output);

    const pin_values: u32 = @intFromEnum(mode) | (cnf_value << 2);
    const new_cr = cr & ~(@as(u32, 0b1111) << offset) | (pin_values << offset);

    if (self.pin >= 8)
        self.port.CRH.raw = new_cr
    else
        self.port.CRL.raw = new_cr;
}

pub inline fn low(self: @This()) void {
    self.port.BSRR.raw = @as(u32, 1) << (@as(u5, self.pin) + 16);
}

pub inline fn read(self: @This()) bool {
    return self.port.IDR.raw & (@as(u32, 1) << self.pin) != 0;
}

pub inline fn toggle(self: @This()) void {
    self.port.ODR.raw ^= (@as(u32, 1) << self.pin);
}
