.section .text
.global _start
_start:
    addi x1, x0, 10 # x1 = 10
    addi x2, x0, 5 # x2 = 5
    add x3, x1, x2 # x3 = x1 + x2 = 15

    sub x4, x3, x1 # x4 = x3 - x1 = 15-10=5