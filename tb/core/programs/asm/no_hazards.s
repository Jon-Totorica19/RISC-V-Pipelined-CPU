# Pipeline CPU test program with no hazards. 
# ALU Instr result done cycle 5 WB
# Use of the result in cycle 2 ID
# Need a three instr gapwithout any additional hardware
# For load use, need a 3 instr gap as well

.section .text
.global _start

_start:
    addi x1, x0, 5         # x1 = 5
    addi x2, x0, 10        # x2 = 10
    addi x4, x0, 3         # x4 = 3, gap 1
    addi x8, x0, 100       # x8 = 100, gap 2
    nop                    # gap 3 for x2 
    add  x3, x1, x2        # x3 = 15      (x1,x2 safe: 3 instr back) (reg cannot be written to and read from in the same cycle until further hardware is implemented. (Write first half cycle, read second hald cycle)

    addi x9, x0, 50        # x9 = 50, gap 1
    addi x10, x0, 7        # x10 = 7, gap 2

    nop                    # gap3 for x3
    sub  x5, x3, x4        # x5 = 12, (x3,x4 safe)
    addi x11, x0, 1        # x11 = 1, gap 1
    addi x12, x0, 2        # x12 = 2, gap 2
    nop                    # gap3 for x5
    sw   x5, 0(x0)         # mem[0] = 12

    addi x13, x0, 9        # x13 = 9, gap 1
    addi x14, x0, 8        # x14 = 8, gap 2
    lw   x6, 0(x0)         # x6 = 12, gap 3 for sw (no gap needed, since sw has no consumer)
    nop                    # gap 1
    nop                    # gap 2
    nop                    # gap 3
    add x15, x9, x6       # x15 = 62
