# Branch flush test
# Each taken branch has 2 poison instructions after it that must be flushed
# Final BEQ tests not-taken: instructions after must execute normally

.section .text
.global _start

_start:
    addi x2, x0, 5      # x2 = 5
    addi x1, x0, 5      # x1 = 5
    addi x3, x0, 10     # x3 = 10
    addi x4, x0, 3      # x4 = 3
    addi x0, x0, 0      # nop, gap instr

    # BEQ taken: 5 == 5
    beq  x1, x2, beq_t
    addi x10, x0, 99    # flushed
    addi x10, x0, 99    # flushed

beq_t:
    addi x10, x0, 1     # x10 = 1

    # BNE taken: 5 != 10
    bne  x1, x3, bne_t
    addi x11, x0, 99
    addi x11, x0, 99

bne_t:
    addi x11, x0, 2     # x11 = 2

    # BLT taken: 3 < 5 (signed)
    blt  x4, x1, blt_t
    addi x12, x0, 99
    addi x12, x0, 99

blt_t:
    addi x12, x0, 3     # x12 = 3

    # BGE taken: 5 >= 3 (signed)
    bge  x1, x4, bge_t
    addi x13, x0, 99
    addi x13, x0, 99

bge_t:
    addi x13, x0, 4     # x13 = 4

    # BLTU taken: 3 < 5 (unsigned)
    bltu x4, x1, bltu_t
    addi x14, x0, 99
    addi x14, x0, 99

bltu_t:
    addi x14, x0, 5     # x14 = 5

    # BGEU taken: 5 >= 3 (unsigned)
    bgeu x1, x4, bgeu_t
    addi x15, x0, 99
    addi x15, x0, 99

bgeu_t:
    addi x15, x0, 6     # x15 = 6

    # BEQ not taken: 5 != 10 — instructions after must execute
    beq  x1, x3, nt_skip
    addi x16, x0, 7     # x16 = 7 (executes if not-taken flush is correct)

nt_skip: