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
    .asciz "COMMAND : FUNCTION\nhelp : displays a list of commands"

.align 2
commands:
    .word help_command
    .word do_help + 1

    .word 0xDEADBEEF

.text

do_help:
    ldr r4, =help_text 
    bl puts
    b shell

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

    movs r1, $32
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
    