# L1 Instruction Cache
# Tests: Cold miss

.section .text
.global _start

_start:
    addi x1, x0, 3 # Cold miss, x1 =3

loop:
    addi x1, x1, -1 # Cold miss iteration 1, hit iterations 2-3
    bne x1, x0, loop # Cold miss iter. 1, predict_taken during miss on iter 2, hit iter 3

    addi x2, x0, 5 # cold miss, x2 = 5
    bne x2, x0, skip # cold miss
    addi x10, x0, 0xFF # flsuhedi s

skip:
    addi x3, x0, 42 # branch target, x3 = 42
    jal x0, conflict_b

.org 0x100
conflict_b:
    addi x4, x0, 1 # cold miss, then conflicts with 0x00 addr
    addi x5, x0, 2 # cold miss, then conflict
    jal x0, halt
halt:
    jal x0, halt