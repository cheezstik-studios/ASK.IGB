ENTRY(reset_handler)

SECTIONS
{
    . = 0x00000000;

    .vectors 0x00000000 :
    {
        KEEP(*(.vectors))
    }

    .text 0x00000008 :
    {
        *(.text*)
    }

    .rodata :
    {
        *(.rodata*)
    }
}