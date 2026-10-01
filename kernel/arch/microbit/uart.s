.syntax unified
.cpu cortex-m0
.thumb

.section .text
.global init
.global putc

.thumb_func
init:
	@ Enable UART
	ldr r0, =0x40002500
	movs r1, #4
	str r1, [r0]

	@ Set baud rate to 115200
	ldr r0, =0x40002524
	ldr r1, =0x01D7E000
	str r1, [r0]

	@ Start transmitter
	ldr r0, =0x40002008
	movs r1, #1
	str r1, [r0]

	@ Start receiver
	ldr r0, =0x40002000
	movs r1, #1
	str r1, [r0]
	
	bx lr

.thumb_func	
putc:
    ldr r1, =0x4000251C
    str r0, [r1]

putc_loop:
    ldr r2, =0x4000211C
    ldr r3, [r2]
    cmp r3, #0
    beq putc_loop

    bx lr