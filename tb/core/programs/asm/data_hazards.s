# Forwarding unit test, intentional data hazards

.section .text
.global _start

_start:
    addi x1, x0, 5      # x1 = 5
    addi x2, x0, 10     # x2 = 10
    add  x3, x1, x2     # x3 = 15  (x1: MEM/WB fwd, x2: EX/MEM fwd)

    addi x4, x0, 3      # x4 = 3
    add  x5, x4, x3     # x5 = 18  (x4: EX/MEM fwd, x3: MEM/WB fwd)

    add  x6, x5, x5     # x6 = 36  (x5 forwarded to both rs1 and rs2 from EX/MEM)

    add x7, x5, x5      # x7 = 36 (x5 forwarded to both rs1 and rs2 from MEM/WB)

    addi x8, x0, 5
    addi x8, x0, 10   # overwrites x8
    add  x9, x8, x0   # must get x9=10 from EX/MEM, not x9=5 from MEM/WB