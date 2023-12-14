ENTRY(reset_handler)

MEMORY
{
    flash (rx) : ORIGIN = 0x08000000, LENGTH = 64K
    ram (rwx) : ORIGIN = 0x20000000, LENGTH = 20K
}

SECTIONS
{
    .text : {
        KEEP(*(.vector_table))
        *(.text*)
        . = ALIGN(4);
        *(.rodata*)
    } >flash

    .ARM.exidx : {
        . = ALIGN(4);
        *(.ARM.exidx*)
    } >flash

    .data : {
        . = ALIGN(4);
        __data = .;
        *(.data*)
        . = ALIGN(4);
        __data_end = .;
    } >ram AT >flash
    __data_loadaddr = LOADADDR(.data);

    .bss : {
        . = ALIGN(4);
        __bss = .;
        *(.bss*)
        *(COMMON)
        . = ALIGN(4);
        __bss_end = .;
    } >ram
}

PROVIDE(__stack = ORIGIN(ram) + LENGTH(ram));
