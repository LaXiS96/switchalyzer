# Switchalyzer

Mechanical keyboard switch force curve analyzer.

The plan is to design hardware (3D printed structure) and software (probably on STM32 and hopefully written in Zig).

## Build

Requirements:
- ARM GCC toolchain: https://developer.arm.com/Tools%20and%20Software/GNU%20Toolchain  
    for building `libopencm3` and debugging
- Zig: https://ziglang.org/download
- OpenOCD: https://github.com/openocd-org/openocd/releases  
    for flashing and debugging
- Python 3.x  
    for linker script generation (from `libopencm3`)

### libopencm3

`libopencm3` must be built with GCC arm-none-eabi (though in the future it might be handled by `zig cc`).

https://github.com/libopencm3/libopencm3

- On Windows: https://www.msys2.org/
    - Use UCRT64 environment
    - Install `make`: `pacman -S make`
    - If `python3` is missing, run via `cmd` as Administrator: `mklink "C:\Program Files\Python311\python3.exe" "C:\Program Files\Python311\python.exe"`
    -   ```sh
        . env.sh
        ```
-   ```sh
    make -C libopencm3 # TARGETS="stm32/f1"
    ```

### switchalyzer

1. 
```sh
zig build
```

## Flash

```sh
zig build flash
```

## Debug

1. Install Cortex-Debug VSCode extension (https://github.com/Marus/cortex-debug)
1. Set `cortex-debug.armToolchainPath` in VSCode `settings.json` to the `bin` directory of your `arm-none-eabi` toolchain
1. Set `cortex-debug.JLinkGDBServerPath` to `JLinkGDBServerCL.exe`, and/or set `cortex-debug.openocdPath` to `openocd.exe`
1. Launch the included debug configuration

## References

- https://ziglang.org/documentation/master
- https://ziglang.org/documentation/master/std
- https://maldus512.medium.com/zig-bare-metal-programming-on-stm32f103-booting-up-b0ecdcf0de35
- https://github.com/rbino/zig-stm32-blink
- https://rbino.com/posts/zig-stm32-blink/
- https://ciesie.com/tags/stm32/
- https://andrewkelley.me/post/zig-stack-traces-kernel-panic-bare-bones-os.html
- https://ikrima.dev/dev-notes/zig/zig-build/
