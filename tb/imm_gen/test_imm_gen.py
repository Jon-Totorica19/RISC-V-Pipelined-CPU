import cocotb
from cocotb.triggers import RisingEdge, Timer

def expected_outputs(instr):
    opcode = instr & 0x7F # Extract the bottom 7 bits
    match opcode:
        case 0b0010011 | 0b0000011 | 0b1100111: # I_type
            imm = (instr >> 20) & 0xFFF # Extract instr[31:20]

            if imm & 0x800: #Check if sign bit (11) is set
                imm |= 0xFFFFF000 # Fill upper 20 bits with 1s
        case 0b0100011: # S_type
            bits11_5 = (instr >> 25) & 0x7F
            bits4_0 = (instr >> 7) & 0x1F
            imm = (bits11_5 << 5) | (bits4_0)

            if imm & 0x800:
                imm |= 0xFFFFF000
        case 0b1100011: # B_format
            bit12 = (instr >> 31) & 0x1
            bit11 = (instr >> 7) & 0x1
            bits10_5 = (instr >> 25) & 0x3F
            bits4_1 = (instr >> 8) & 0xF
            bit0 = 0
            imm = (bit12 << 12) | (bit11 << 11) | (bits10_5 << 5) | (bits4_1 << 1) | bit0

            if imm & 0x1000: # Sign extend bit 12
                imm |= 0xFFFFE000
        case 0b0110111 | 0b0010111: # U_format
            bits31_12 = (instr >> 12) & 0xFFFFF
            imm = bits31_12 << 12
        case 0b1101111: # J_format
            bit20 = (instr >> 31) & 0x1
            bits19_12 = (instr >> 12) & 0xFF
            bit11 = (instr >> 20) & 0x1
            bits10_1 = (instr >> 21) & 0x3FF

            imm = (bit20 << 20) | (bits19_12 << 12) | (bit11 << 11) | (bits10_1 << 1)

            if imm & 0x100000: # Sign extend bit 20
                imm |= 0xFFF00000
        case _:
            imm = 0

    return imm & 0xFFFFFFFF # Constrain to 32 bits

@cocotb.test()
async def test_inputs(dut):
    # Initilize instr to 0
    dut.instr.value = 0
    await Timer(1, unit="ns")

    # Test: I format negative immediate

    # Put together LW instruction
    imm = 0xBEE
    rs1 = 0b00110
    funct3 = 0b010
    rd = 0b00001
    opcode = 0b0000011

    instr = (imm << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode

    dut.instr.value = instr
    await Timer(1, unit="ns")
    assert dut.imm.value == expected_outputs(instr), f"I-type failed: instr={hex(instr)}"

    await Timer(4, unit="ns")

    # Test: I format positive immediate

    # Put together LW instruction
    imm = 0x005
    rs1 = 0b00110
    funct3 = 0b010
    rd = 0b00001
    opcode = 0b0000011

    instr = (imm << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode

    dut.instr.value = instr
    await Timer(1, unit="ns")
    assert dut.imm.value == expected_outputs(instr), f"I-type failed: instr={hex(instr)}"

    await Timer(4, unit="ns")

    # Test: S format negative immediate

    # Put together SW instruction
    imm11_5 = 0x7B
    rs2 = 0b00111
    rs1 = 0b00110
    funct3 = 0b010
    imm4_0 = 0x0F
    opcode = 0b0100011

    instr = (imm11_5 << 25) | (rs2 << 20) | (rs1 << 15) |(funct3 << 12) | (imm4_0 << 7) | opcode

    dut.instr.value = instr
    await Timer(1, unit="ns")
    assert dut.imm.value == expected_outputs(instr), f"S-type failed: instr={hex(instr)}"

    await Timer(4, unit="ns")

    # Test: S format positive immediate

    # Put together SW instruction
    imm11_5 = 0x3B
    rs2 = 0b00111
    rs1 = 0b00110
    funct3 = 0b010
    imm4_0 = 0x0F
    opcode = 0b0100011

    instr = (imm11_5 << 25) | (rs2 << 20) | (rs1 << 15) |(funct3 << 12) | (imm4_0 << 7) | opcode

    dut.instr.value = instr
    await Timer(1, unit="ns")
    assert dut.imm.value == expected_outputs(instr), f"S-type failed: instr={hex(instr)}"

    await Timer(4, unit="ns")

    # Test: B format negative immediate

    # Put together BEQ instruction
    imm12_10_5 = 0x7B
    rs2 = 0b00111
    rs1 = 0b00110
    funct3 = 0b000
    imm4_1_11 = 0x0F
    opcode = 0b1100011

    instr = (imm12_10_5 << 25) | (rs2 << 20) | (rs1 << 15) |(funct3 << 12) | (imm4_1_11 << 7) | opcode

    dut.instr.value = instr
    await Timer(1, unit="ns")
    assert dut.imm.value == expected_outputs(instr), f"B-type failed: instr={hex(instr)}"

    await Timer(4, unit="ns")

    # Test: B format positive immediate

    # Put together BEQ instruction
    imm12_10_5 = 0x3B
    rs2 = 0b00111
    rs1 = 0b00110
    funct3 = 0b000
    imm4_1_11 = 0x0F
    opcode = 0b1100011

    instr = (imm12_10_5 << 25) | (rs2 << 20) | (rs1 << 15) |(funct3 << 12) | (imm4_1_11 << 7) | opcode

    dut.instr.value = instr
    await Timer(1, unit="ns")
    assert dut.imm.value == expected_outputs(instr), f"B-type failed: instr={hex(instr)}"

    await Timer(4, unit="ns")

    # Test: U format negative immediate

    # Put together AUIPC instruction
    imm31_12 = 0x8AAAA
    rd = 0b00110
    opcode = 0b0010111

    instr = (imm31_12 << 12) | (rd << 7) | opcode

    dut.instr.value = instr
    await Timer(1, unit="ns")
    assert dut.imm.value == expected_outputs(instr), f"U-type failed: instr={hex(instr)} gave imm: {hex(dut.imm.value)}, but should be {hex(expected_outputs(instr))}"

    await Timer(4, unit="ns")

    # Test: U format positive immediate

    # Put together AUIPC instruction
    imm31_12 = 0x7AAAA
    rd = 0b00110
    opcode = 0b0010111

    instr = (imm31_12 << 12) | (rd << 7) | opcode

    dut.instr.value = instr
    await Timer(1, unit="ns")
    assert dut.imm.value == expected_outputs(instr), f"U-type failed: instr={hex(instr)}"

    await Timer(4, unit="ns")

    # Test: J format negative immediate

    # Put together JAL instruction
    imm31_12 = 0x8AAAA
    rd = 0b00110
    opcode = 0b1101111

    instr = (imm31_12 << 12) | (rd << 7) | opcode

    dut.instr.value = instr
    await Timer(1, unit="ns")
    assert dut.imm.value == expected_outputs(instr), f"J-type failed: instr={hex(instr)}"

    await Timer(4, unit="ns")

    # Test: J format positive immediate

    # Put together JAL instruction
    imm31_12 = 0x7AAAA
    rd = 0b00110
    opcode = 0b1101111

    instr = (imm31_12 << 12) | (rd << 7) | opcode

    dut.instr.value = instr
    await Timer(1, unit="ns")
    assert dut.imm.value == expected_outputs(instr), f"J-type failed: instr={hex(instr)}"

    await Timer(4, unit="ns")



           

        
        
