# LW and SW Instructions

.section .text
.global _start
_start:

    addi x1, x0, 0
    addi x2, x0, 0

    addi x1, x0, 10 # x1 = 10

    sw x1, 4(x0) # mem[x0 + 4] = x1 = 10

    lw x2, 4(x0) # x2 = mem [x0 + 4] = 10