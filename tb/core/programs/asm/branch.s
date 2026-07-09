# Branch Instructions: BEQ, BNE, BGE, BLT, BLTU, BGEU
/*
From previous programs in the same simulation:
    need to clear regs x1-x7
*/

.section .text
.global _start
_start:

    # Clear regs
    addi x1, x0, 0
    addi x2, x0, 0
    addi x3, x0, 0
    addi x4, x0, 0
    addi x5, x0, 0
    addi x6, x0, 0
    addi x7, x0, 0

    addi x1, x0, 5
    addi x2, x0, 3

    # BEQ Not Taken
    beq x1, x2, fail1
    addi x3, x0, 1
    j cont1

fail1:
    addi x3, x0, 0 # skipped

cont1: 
    # BNE branch taken
    bne x1, x2, pass2
    addi x4, x0, 0 # Skipped
    j cont2 # Skipped

pass2:
    addi x4, x0, 1 # x4 = 1

cont2:
    # BLT Branch Taken
    blt x2, x1, pass3
    addi x5, x0, 0 # Skipped 
    j cont3 # Skipped

pass3: 
    addi x5, x0, 1 # x5 = 1

cont3:
    # BGE Branch Taken
    bge x1, x2, pass4
    addi x6, x0, 0 # Skipped
    j cont4 # Skipped

pass4:
    addi x6, x0, 1 # x6 = 1

cont4:
    # BLTU Branch Taken 
    bltu x2, x1, pass5
    addi x7, x0, 0 # Skipped
    j cont5 # Skipped

pass5:
    addi x7, x0, 1 # x7 = 1

cont5:
    # BGEU Branch Taken
    bgeu x1, x2, pass6
    addi x8, x0, 0 # Skipped
    j cont6 # Skipped

pass6:
    addi x8, x0, 1

cont6:


