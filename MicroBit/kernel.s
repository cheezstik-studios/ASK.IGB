.syntax unified
.cpu cortex-m0
.thumb

.global reset_handler

.section .vectors,"a"
.word 0x20004000
.word reset_handler + 1

.section .rodata

message:
    .asciz "--- ASK.IGB ---\n-- BBC Micro:Bit --\n- Version 0.1.0 -\nType 'help' for a list of commands"

cnf_text:
    .asciz "' is not the name of an operable command"

help_command:
    .asciz "help"

help_text:
    .asciz "COMMAND       : FUNCTION\nhelp          : Displays a list of commands.\necho <string> : Prints <string> to the terminal.\nshutdown      : Prepares the system for power loss. The shell will lock until power is restored."

echo_command:
	.asciz "echo"

shutdown_command:
	.asciz "shutdown"
	
shutdown_text: 
	.asciz "ARE YOU SURE YOU WOULD LIKE TO SHUT DOWN (Y/N) "
	.asciz "\nSystem ready for power removal."

.align 2
commands:
    .word help_command
    .word do_help + 1
    .word echo_command
    .word do_echo + 1
	.word shutdown_command
	.word do_shutdown + 1

    .word 0xDEADBEEF

.text

do_help:
    ldr r4, =help_text 
    bl puts
    b shell

do_echo:
    adds r4, #1
    bl puts
    b shell
	
do_shutdown:
	ldr r4, =shutdown_text
	bl puts
	bl getc
	cmp r1, #89
	beq shutdown_y
	cmp r1, #121
	beq shutdown_y
	bl putc
	b shell
shutdown_y:
	bl putc
	adds r4, #1
	bl puts
	

str_eq:
    ldrb r0, [r4]
    ldrb r1, [r6]

    cmp r0, r1
    bne not_equal

    cmp r0, #0
    beq equal

    adds r4, #1
    adds r6, #1
    b str_eq

equal:
    movs r0, #1
    bx lr

not_equal:
    movs r0, #0
    bx lr

getc:
    ldr r0, =0x40002108

wait_rx:
    ldr r2, [r0]
    cmp r2, #0
    beq wait_rx

    ldr r0, =0x40002518
    ldrb r1, [r0]

    ldr r0, =0x40002108
    movs r2, #0
    str r2, [r0]

    bx lr

putc:
    @ r1 contains character

    ldr r0, =0x4000251C
    str r1, [r0]

wait_tx:
    ldr r2, =0x4000211C
    ldr r3, [r2]
    cmp r3, #0
    beq wait_tx

    bx lr

puts:
    ldrb r1, [r4]

    cmp r1, #0
    beq return

    push {lr}
    bl putc
    pop {r5}
    mov lr, r5

    adds r4, #1

    b puts

return:
    bx lr
	
halt:
	b halt
	
reset_handler:
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

    ldr r4, =message
    bl puts

   ldr r4, =0x20000000

shell:
   ldr r4, =0x20000000

    movs r1, #10
    bl putc

    movs r1, #62
    bl putc

    movs r1, #32
    bl putc

type:
    bl getc 
    
    cmp r1, #13
    beq execute

    
    cmp r1, #127
    beq backspace    

    strb r1, [r4]
    bl putc

    adds r4, #1

    b type

execute:
    movs r1, #0
    strb r1, [r4]

    movs r1, #10
    bl putc

    ldr r4, =0x20000000
    b filter

prepare_find:
    ldr r4, =0x20000000
    ldr r5, =commands

find_command:
    ldr r6, [r5]          @ load command string address

    ldr r0, =0xDEADBEEF
    cmp r6, r0
    beq command_not_found @ reached the end

    ldr r7, [r5, #4]      @ load function address

    bl str_eq
    cmp r0, #1
    bne continue
    bx r7

continue:
    adds r5, #8           @ move to next command entry
    b find_command

filter:
    ldrb r1, [r4]
    adds r4, #1
    cmp r1, #0
    beq prepare_find
    cmp r1, #32
    bne filter
    subs r4, #1
    movs r1, #0
    strb r1, [r4]
    b prepare_find

command_not_found:
    movs r1, #39
    bl putc
    ldr r4, =0x20000000
    bl puts
    ldr r4, =cnf_text
    bl puts
    b shell

backspace:
    ldr r5, =0x20000000
    cmp r4, r5
    beq type

    subs r4, #1

    movs r1, #0
    strb r1, [r4]

    movs r1, #8
    bl putc

    movs r1, #32
    bl putc

    movs r1, #8
    bl putc

    b type
    
