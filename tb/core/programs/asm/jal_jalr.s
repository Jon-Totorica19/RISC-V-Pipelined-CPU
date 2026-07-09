# JAL and JALR
/*
From previous programs in the same simulation:
    x5 = 0xBEEFF000
    x6 = 0x0000100C
    mem[1] = 10
*/

.section .text
.global _start
_start:
    # JAL: jump to label, save return address in x1
    jal x1, jal_target # x1 = pc + 4 = 4, jump to target
    addi x10, x0, 1 # skipped

jal_target:
    addi x2, x0, 1 # x2 = 1

    # Get address of jalr_target label
    auipc x3, 0 # x3 = pc
    addi x3, x3, 16 # x3 = pc + 16 (address of jalr_target)

    # JALR: jump to label with register relative addressing
    jalr x4, x3, 0 # jump to address in x3 (jalr_target), x4 = = pc + 4 = 24
    addi x11, x0, 1 # Skipped

jalr_target:
    addi x7, x0, 1 # x7 = 1
