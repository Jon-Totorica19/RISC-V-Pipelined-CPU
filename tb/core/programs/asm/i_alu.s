# I-ALU Instructions: ADDI and SRAI

.section .text
.global _start
_start:

    # Set regs used in previous program to 0
    addi x1, x0, 0
    addi x2, x0, 0
    addi x3, x0, 0
    addi x4, x0, 0

    addi x1, x0, 10
    
    srai x2, x1, 2 # x2 = 20 >> 2 = 101 = 5

    