# Switchalyzer

Mechanical keyboard switch force curve analyzer.

The plan is to design hardware (3D printed structure) and software (probably on STM32 and hopefully written in Zig).

## Build

### libopencm3

`libopencm3` must be built with GCC arm-none-eabi (though it could be handled by `zig cc`).

https://github.com/libopencm3/libopencm3  
https://developer.arm.com/Tools%20and%20Software/GNU%20Toolchain

- On Windows: https://www.msys2.org/
    - Use UCRT64 environment
    - Install `make`: `pacman -S make`
    - If `python3` is missing, run via `cmd` as Administrator: `mklink "C:\Program Files\Python311\python3.exe" "C:\Program Files\Python311\python.exe"`
    -   ```sh
        export PATH="/c/Program Files/Python311:$PATH"
        export PATH="/e/arm-gnu-toolchain-12.3.rel1-mingw-w64-i686-arm-none-eabi/bin:$PATH"
        export PATH="/e/zig-windows-x86_64-0.12.0-dev.1114+e8f3c4c4b:$PATH"
        ```
-   ```sh
    make -C libopencm3 # TARGETS="stm32/f1"
    ```

### switchalyzer

```sh
zig build
```

## References
- https://maldus512.medium.com/zig-bare-metal-programming-on-stm32f103-booting-up-b0ecdcf0de35
- https://github.com/rbino/zig-stm32-blink
- https://rbino.com/posts/zig-stm32-blink/
- https://ciesie.com/tags/stm32/
- https://andrewkelley.me/post/zig-stack-traces-kernel-panic-bare-bones-os.html
- https://ikrima.dev/dev-notes/zig/zig-build/
