const cm3 = @import("cm3.zig");

port: u32,
pin: u16,

pub fn create(port: cm3.gpio.ports, pin: cm3.gpio.pins) @This() {
    return .{
        .port = @intFromEnum(port),
        .pin = @intFromEnum(pin),
    };
}

pub inline fn clear(self: @This()) void {
    // cm3.gpio_clear(self.port, self.pin);
    cm3.gpio.BSRR(self.port).* = @as(u32, self.pin) << 16;
}

pub inline fn get(self: @This()) bool {
    // return cm3.gpio_get(self.port, self.pin) != 0;
    return cm3.gpio.IDR(self.port).* & self.pin != 0;
}

pub inline fn set(self: @This()) void {
    // cm3.gpio_set(self.port, self.pin);
    cm3.gpio.BSRR(self.port).* = self.pin;
}

pub inline fn setupInputFloating(self: @This()) void {
    cm3.gpio_set_mode(self.port, cm3.GPIO_MODE_INPUT, cm3.GPIO_CNF_INPUT_FLOAT, self.pin);
}

pub inline fn setupOutput(self: @This()) void {
    cm3.gpio_set_mode(self.port, cm3.GPIO_MODE_OUTPUT_2_MHZ, cm3.GPIO_CNF_OUTPUT_PUSHPULL, self.pin);
}
