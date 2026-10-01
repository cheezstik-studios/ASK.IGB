.syntax unified
.cpu cortex-m0
.thumb

.section .vectors,"a"

.word 0x20004000
.word _start + 1

.section .text
.global _start
.thumb_func

_start:
	bl kernel_main

halt:
    b halt