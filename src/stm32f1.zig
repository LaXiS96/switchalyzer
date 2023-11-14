const RCC_ADDR = 0x4002_1000;
const RCC: *volatile RccRegister = @ptrFromInt(RCC_ADDR);
const RccRegister = packed struct {
    CR: packed struct(u32) {
        HSION: u1,
        HSIRDY: u1,
        _rsvd1: u1,
        HSITRIM: u5,
        HSICAL: u8,
        HSEON: u1,
        HSERDY: u1,
        HSEBYP: u1,
        CSSON: u1,
        _rsvd2: u4,
        PLLON: u1,
        PLLRDY: u1,
        _rsvd3: u6,
    },
    CFGR: packed struct(u32) {
        SW: u2,
        SWS: u2,
        HPRE: u4,
        PPRE1: u3,
        PPRE2: u3,
        ADCPRE: u2,
        PLLSRC: u1,
        PLLXTPRE: u1,
        PLLMUL: u4,
        USBPRE: u1,
        _rsvd1: u1,
        MCO: u3,
        _rsvd2: u5,
    },
    CIR: u32, // TODO
    APB2RSTR: u32, // TODO
    APB1RSTR: u32, // TODO
    ENR: packed struct {
        // AHBENR
        DMA1EN: u1,
        DMA2EN: u1,
        SRAMEN: u1,
        _rsvd1: u1,
        FLITFEN: u1,
        _rsvd2: u1,
        CRCEN: u1,
        _rsvd3: u1,
        FSMCEN: u1,
        _rsvd4: u1,
        SDIOEN: u1,
        _rsvd5: u21,

        // APB2ENR
        AFIOEN: u1,
        _rsvd6: u1,
        IOPAEN: u1,
        IOPBEN: u1,
        IOPCEN: u1,
        IOPDEN: u1,
        IOPEEN: u1,
        IOPFEN: u1,
        IOPGEN: u1,
        ADC1EN: u1,
        ADC2EN: u1,
        TIM1EN: u1,
        SPI1EN: u1,
        TIM8EN: u1,
        USART1EN: u1,
        ADC3EN: u1,
        _rsvd7: u3,
        TIM9EN: u1,
        TIM10EN: u1,
        TIM11EN: u1,
        _rsvd8: u10,

        // APB1ENR
        TIM2EN: u1,
        TIM3EN: u1,
        TIM4EN: u1,
        TIM5EN: u1,
        TIM6EN: u1,
        TIM7EN: u1,
        TIM12EN: u1,
        TIM13EN: u1,
        TIM14EN: u1,
        _rsvd9: u2,
        WWDGEN: u1,
        _rsvd10: u2,
        SPI2EN: u1,
        SPI3EN: u1,
        _rsvd11: u1,
        USART2EN: u1,
        USART3EN: u1,
        UART4EN: u1,
        UART5EN: u1,
        I2C1EN: u1,
        I2C2EN: u1,
        USBEN: u1,
        _rsvd12: u1,
        CANEN: u1,
        _rsvd13: u1,
        BKPEN: u1,
        PWREN: u1,
        DACEN: u1,
        _rsvd14: u2,
    },
    BDCR: u32, // TODO
    CSR: u32, // TODO
};

const GPIO_PORTA_ADDR = 0x4001_0800;
const GPIO_PORTB_ADDR = 0x4001_0C00;
const GPIO_PORTC_ADDR = 0x4001_1000;
const GPIO_PORTD_ADDR = 0x4001_1400;
const GPIO_PORTE_ADDR = 0x4001_1800;
const GPIO_PORTF_ADDR = 0x4001_1C00;
const GPIO_PORTG_ADDR = 0x4001_2000;

pub const Gpio = struct {
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
        // Note: these registers only accept word-size accesses
        CRL: u32,
        CRH: u32,
        IDR: u32,
        ODR: u32,
        BSRR: u32,
        BRR: u32,
        LCKR: packed struct {
            LCK: u16,
            LCKK: u1,
            _rsvd1: u15,
        },
    };
    inline fn portRegister(port_addr: u32) *volatile GpioRegister {
        return @ptrFromInt(port_addr);
    }

    pub inline fn clear(self: @This()) void {
        portRegister(self.port).BSRR = @as(u32, 1) << (@as(u5, self.pin) + 16);
    }

    pub fn configure(self: @This(), mode: Modes, cnf: Cnfs) void {

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
            cr = portRegister(self.port).CRH;
            offset = (self.pin - 8) * 4;
        } else {
            cr = portRegister(self.port).CRL;
            offset = self.pin * 4;
        }

        const cnf_value: u4 = if (mode == Modes.input)
            @intFromEnum(cnf.input)
        else
            @intFromEnum(cnf.output);

        const pin_values: u32 = @intFromEnum(mode) | (cnf_value << 2);
        const new_cr = cr & ~(@as(u32, 0b1111) << offset) | (pin_values << offset);

        if (self.pin >= 8)
            portRegister(self.port).CRH = new_cr
        else
            portRegister(self.port).CRL = new_cr;
    }

    pub fn create(port: Ports, pin: u4) @This() {
        return .{
            .port = @intFromEnum(port),
            .pin = pin,
        };
    }

    pub inline fn get(self: @This()) bool {
        return portRegister(self.port).IDR & (@as(u32, 1) << self.pin) != 0;
    }

    pub inline fn set(self: @This()) void {
        portRegister(self.port).BSRR = @as(u32, 1) << self.pin;
    }
};

const TIMER_TIM2_ADDR = 0x4000_0000;
const TIMER_TIM3_ADDR = 0x4000_0400;
const TIMER_TIM4_ADDR = 0x4000_0800;
const TIMER_TIM5_ADDR = 0x4000_0C00;
const TIMER_TIM6_ADDR = 0x4000_1000;
const TIMER_TIM7_ADDR = 0x4000_1400;
const TIMER_TIM12_ADDR = 0x4000_1800;
const TIMER_TIM13_ADDR = 0x4000_1C00;
const TIMER_TIM14_ADDR = 0x4000_2000;
const TIMER_TIM1_ADDR = 0x4001_2C00;
const TIMER_TIM8_ADDR = 0x4001_3400;
const TIMER_TIM9_ADDR = 0x4001_4C00;
const TIMER_TIM10_ADDR = 0x4001_5000;
const TIMER_TIM11_ADDR = 0x4001_5400;

pub const Timer = struct {
    pub const Timers = enum(u32) {
        TIM1 = TIMER_TIM1_ADDR,
        TIM2 = TIMER_TIM2_ADDR,
        TIM3 = TIMER_TIM3_ADDR,
        TIM4 = TIMER_TIM4_ADDR,
        TIM5 = TIMER_TIM5_ADDR,
        TIM6 = TIMER_TIM6_ADDR,
        TIM7 = TIMER_TIM7_ADDR,
        TIM8 = TIMER_TIM8_ADDR,
        TIM9 = TIMER_TIM9_ADDR,
        TIM10 = TIMER_TIM10_ADDR,
        TIM11 = TIMER_TIM11_ADDR,
        TIM12 = TIMER_TIM12_ADDR,
        TIM13 = TIMER_TIM13_ADDR,
        TIM14 = TIMER_TIM14_ADDR,
    };

    // TODO
};

pub const Itm = struct {
    const ITM_BASE_ADDR = 0xe000_0000;

    pub const STIM_FIFOREADY: u32 = 1 << 0;

    pub const TER: *volatile [8]u32 = @ptrFromInt(ITM_BASE_ADDR + 0xe00);

    pub inline fn STIM8(stim_port: u8) *volatile u8 {
        return @ptrFromInt(ITM_BASE_ADDR + @as(u32, stim_port) * 4);
    }
};
