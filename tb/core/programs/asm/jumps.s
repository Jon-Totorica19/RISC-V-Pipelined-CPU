# JAL and JALR test
# Verifies: jump executes target, 2 poison instructions flushed, rd = PC+4

.section .text
.global _start

_start:
    addi x1, x0, 0      # x1 = 0 (confirms JAL overwrites it)

    # JAL: PC-relative forward jump
    jal  x1, jal_t      # x1 = 0x08 (PC+4), jump to jal_t
    addi x10, x0, 99    # flushed
    addi x10, x0, 99    # flushed

jal_t:                   # 0x10
    addi x10, x0, 1     # x10 = 1

    # JALR: register-relative jump, also exercises EX/MEM forwarding on rs1
    addi x2, x0, 36     # x2 = 0x24 (address of jalr_t)
    jalr x3, x2, 0      # x3 = 0x1C = 28 (PC+4), jump to x2
    addi x11, x0, 99    # flushed
    addi x11, x0, 99    # flushed

jalr_t:                  # 0x24
    addi x11, x0, 2     # x11 = 2