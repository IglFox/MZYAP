.text
.global _start

_start:
    LDR r0, =0xFF200000

main_loop:
    LDR r1, [r0, #0x50]
    TST r1, #1
    BNE progA
    TST r1, #2
    BNE progDATA

    MOVW r2, #0x4949
    STR r2, [r0, #0x20]
    LDR r3, =0x0A000000
delay_pause:
    SUBS r3, r3, #1
    BNE delay_pause
    B main_loop

progA:
   // PUSH {LR}
    //LDR r0, =BASE_ADDR
    MOV R1,#3
    MOV r4, #0

a_outer:
    MOVW r5, #0x7700
    MOV r3, #2
a_right_shift:
    STR r5, [r0, #0x30]
    LSR r5, #8
    LDR r2, =0x10000000
a_delay1:
    SUBS r2, #1
    BNE a_delay1
    SUBS r3, #1
    BNE a_right_shift

    STR r4, [r0, #0x30]

    MOV r3, #4
    MOV r5, #0
    MOVT r5, #0x7700
a_left_shift:
    STR r5, [r0,#0x20]
    LSR r5, #8
    LDR r2, =0x10000000
a_delay2:
    SUBS r2, #1
    BNE a_delay2
    SUBS r3, #1
    BNE a_left_shift

    STR r4, [r0,#0x20]

    SUBS r1, #1
    BNE a_outer

    //POP {LR}
    B main_loop

progDATA:
    //PUSH {LR}
    //LDR r0, =BASE_ADDR
    MOV r8, #5

data_main_loop:
    LDR r6, =PD
    LDR r7, =TY
    MOV r3, #16

data_loop:
    LDR r4, [r6], #4
    LDR r5, [r7], #4
    STR r4, [r0,#0x20]
    STR r5, [r0, #0x30]
    LDR r2, =0x10000000
data_delay:
    SUBS r2, #1
    BNE data_delay
    SUBS r3, #1
    BNE data_loop

    SUBS r8, #1
    BNE data_main_loop

   // POP {LR}
    B main_loop

BASE_ADDR: .word 0xFF200000
A_CYCLES:  .word 3

PD: .word 0x0000005B, 0x00005B7D, 0x005B7D08, 0x5B7D083F, 0x7D083F4F, 0x083F4F08, 0x3F4F085B, 0x4F085B3F, 0x085B3F5B, 0x5B3F5B6D, 0x3F5B6D00, 0x5B6D0000, 0x6D000000, 0x0, 0x0, 0x0
TY: .word 0x0, 0x0, 0x0, 0x0, 0x5B, 0x5B7D, 0x7D06, 0x083F, 0x3F4F, 0x4F08, 0x085B, 0x5B3F, 0x3F5B, 0x5B6D, 0x6D00, 0x0
