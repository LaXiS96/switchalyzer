const RCC = @import("rcc.zig").RCC;

const GPIO_PORTA_ADDR = 0x4001_0800;
const GPIO_PORTB_ADDR = 0x4001_0C00;
const GPIO_PORTC_ADDR = 0x4001_1000;
const GPIO_PORTD_ADDR = 0x4001_1400;
const GPIO_PORTE_ADDR = 0x4001_1800;
const GPIO_PORTF_ADDR = 0x4001_1C00;
const GPIO_PORTG_ADDR = 0x4001_2000;

port: u32,
pin: u4,

pub const Ports = enum(u32) {
    A = GPIO_PORTA_ADDR,
    B = GPIO_PORTB_ADDR,
    C = GPIO_PORTC_ADDR,
    D = GPIO_PORTD_ADDR,
    E = GPIO_PORTE_ADDR,
    F = GPIO_PORTF_ADDR,
    G = GPIO_PORTG_ADDR,
};
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

const GpioRegister = packed struct {
    CRL: u32,
    CRH: u32,
    IDR: u32,
    ODR: u32,
    BSRR: u32,
    BRR: u32,
    LCKR: packed struct(u32) {
        LCK: u16,
        LCKK: u1,
        _rsvd1: u15,
    },
};
inline fn getRegister(port_addr: u32) *volatile GpioRegister {
    return @ptrFromInt(port_addr);
}

pub fn create(port: Ports, pin: u4) @This() {
    return @This(){
        .port = @intFromEnum(port),
        .pin = pin,
    };
}

pub inline fn high(self: @This()) void {
    getRegister(self.port).BSRR = @as(u32, 1) << self.pin;
}

pub fn initialize(self: @This(), mode: Modes, cnf: Cnfs) void {

    // Enable clock for GPIO port
    const port_enum: Ports = @enumFromInt(self.port);
    switch (port_enum) {
        Ports.A => RCC.ENR.IOPAEN = 1,
        Ports.B => RCC.ENR.IOPBEN = 1,
        Ports.C => RCC.ENR.IOPCEN = 1,
        Ports.D => RCC.ENR.IOPDEN = 1,
        Ports.E => RCC.ENR.IOPEEN = 1,
        Ports.F => RCC.ENR.IOPFEN = 1,
        Ports.G => RCC.ENR.IOPGEN = 1,
    }

    var cr: u32 = undefined;
    var offset: u5 = undefined;
    if (self.pin >= 8) {
        cr = getRegister(self.port).CRH;
        offset = (self.pin - 8) * 4;
    } else {
        cr = getRegister(self.port).CRL;
        offset = self.pin * 4;
    }

    const cnf_value: u4 = if (mode == Modes.input)
        @intFromEnum(cnf.input)
    else
        @intFromEnum(cnf.output);

    const pin_values: u32 = @intFromEnum(mode) | (cnf_value << 2);
    const new_cr = cr & ~(@as(u32, 0b1111) << offset) | (pin_values << offset);

    if (self.pin >= 8)
        getRegister(self.port).CRH = new_cr
    else
        getRegister(self.port).CRL = new_cr;
}

pub inline fn low(self: @This()) void {
    getRegister(self.port).BSRR = @as(u32, 1) << (@as(u5, self.pin) + 16);
}

pub inline fn read(self: @This()) bool {
    return getRegister(self.port).IDR & (@as(u32, 1) << self.pin) != 0;
}

pub inline fn toggle(self: @This()) void {
    _ = self;
}
