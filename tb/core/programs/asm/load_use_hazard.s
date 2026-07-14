# Load-use hazard test
# Hazard detection unit inserts 1 stall, MEM/WB forwarding completes the path

.section .text
.global _start

_start:
    addi x1, x0, 20     # x1 = 20
    addi x2, x0, 5      # x2 = 5
    sw   x1, 0(x0)      # mem[0] = 20
    sw   x2, 4(x0)      # mem[4] = 5, gap 1 for sw, mem[0]

    lw   x3, 0(x0)      # x3 = 20
    add  x4, x3, x2     # LOAD-USE rs1: stall inserted, x4 = 25

    lw   x5, 4(x0)      # x5 = 5
    add  x6, x1, x5     # LOAD-USE rs2: stall inserted, x6 = 25

    lw   x7, 0(x0)      # x7 = 20
    add  x8, x7, x7     # LOAD-USE both rs1 and rs2: stall inserted, x8 = 40