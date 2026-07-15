# Pipeline integration test
# Covers: LUI, AUIPC, EX/MEM forward, MEM/WB forward, regfile bypass (gap=2),
#         store/load, load-use stall (x2), branch loop (taken x3 + not-taken x1),
#         JAL + JALR function call/return

.section .text
.global _start

_start:

    # Phase 1: LUI / AUIPC
    lui   x1, 1             # x1 = 0x00001000
    auipc x2, 0             # x2 = 0x04 (PC of this instruction)

    # Phase 2: ALU forwarding chain
    addi  x3, x0, 10       # x3 = 10
    addi  x4, x0, 20       # x4 = 20
    add   x5, x3, x4       # x5 = 30  (x4: EX/MEM, x3: MEM/WB)
    add   x6, x5, x3       # x6 = 40  (x5: EX/MEM, x3: regfile bypass gap=2)
    sub   x7, x6, x4       # x7 = 20  (x6: EX/MEM, x4: regfile bypass gap=2)

    # Phase 3: Store/Load + two load-use stalls
    sw    x5, 0(x0)         # mem[0] = 30
    sw    x7, 4(x0)         # mem[4] = 20
    lw    x8, 0(x0)         # x8 = 30
    add   x9, x8, x7       # LOAD-USE. one stall: x9 = 30 + 20 = 50
    lw    x10, 4(x0)        # x10 = 20
    add   x11, x10, x9     # LOAD-USE. one stall: x11 = 20 + 50 = 70

    # Phase 4: Loop — sums 1+2+3+4 = 10
    addi  x12, x0, 0       # x12 = 0  (sum)
    addi  x13, x0, 1       # x13 = 1  (counter)
    addi  x14, x0, 4       # x14 = 4  (limit)
loop:
    add   x12, x12, x13    # sum += counter  (x13: EX/MEM from prev addi)
    addi  x13, x13, 1      # counter++
    bge   x14, x13, loop   # branch if limit >= counter (taken 3x, not-taken 1x)
                            # x13 fwd to bge via EX/MEM (gap=0)

    # Phase 5: JAL/JALR function call
    jal   x15, func         # x15 = 0x50, jump to func (flushes 0x50 + 0x54)
    addi  x16, x0, 42      # flushed on call — re-executes on return
    addi  x17, x0, 99      # flushed on call — re-executes on return
    addi  x18, x0, 55       # post-return sentinel

halt:
    jal   x0, halt          # infinite loop — stops sequential runoff into func

func:                        # 0x60
    addi  x19, x0, 77      # x19 = 77
    jalr  x0, x15, 0       # return to 0x50 (flushes 0x64 + 0x68)
    addi  x0, x0, 0        # flushed
    addi  x0, x0, 0        # flushed