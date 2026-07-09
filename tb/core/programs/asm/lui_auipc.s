# LUI and AUIPC Instructions
/*
From previous programs in the same simulation:
    x1, x2 = 10
    mem[1] = 10
*/
.section .text
.global _start
_start:

    # Clear regs
    addi x1, x0, 0
    addi x2, x0, 0

    lui x5, 0xBEEFF # x5 = 0xBEEFF000 (rd = imm << 12)

    auipc x6, 0x1 # x6 = pc + (imm << 12) = 12 + (1 << 12 (0x1000)  = 0x100C 

    