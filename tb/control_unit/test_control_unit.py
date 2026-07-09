import cocotb
from cocotb.triggers import Timer

def expected_outputs(opcode):
    match opcode:
        case 0b0110011: # R-type
            RegWrite = 1
            ALUSrc = 0
            MemWrite = 0
            MemRead = 0
            MemToReg = 0
            Branch = 0
            Jump = 0
            ALUOp = 0b10

        case 0b0010011: # I-type-ALU
            RegWrite = 1
            ALUSrc = 1
            MemWrite = 0
            MemRead = 0
            MemToReg = 0
            Branch = 0
            Jump = 0
            ALUOp = 0b10

        case 0b0000011: # I-type-load
            RegWrite = 1
            ALUSrc = 1
            MemWrite = 0
            MemRead = 1
            MemToReg = 1
            Branch = 0
            Jump = 0
            ALUOp = 0b00

        case 0b1100111: # I-type-jalr
            RegWrite = 1
            ALUSrc = 1
            MemWrite = 0
            MemRead = 0
            MemToReg = 0
            Branch = 0
            Jump = 1
            ALUOp = 0b00

        case 0b0100011: # S-type
            RegWrite = 0
            ALUSrc = 1
            MemWrite = 1
            MemRead = 0
            MemToReg = 0
            Branch = 0
            Jump = 0
            ALUOp = 0b00

        case 0b1100011: # B-type
            RegWrite = 0
            ALUSrc = 0
            MemWrite = 0
            MemRead = 0
            MemToReg = 0
            Branch = 1
            Jump = 0
            ALUOp = 0b01

        case 0b0110111 | 0b0010111: # U-type
            RegWrite = 1
            ALUSrc = 1
            MemWrite = 0
            MemRead = 0
            MemToReg = 0
            Branch = 0
            Jump = 0
            ALUOp = 0b00

        case 0b1101111: # J-type
            RegWrite = 1
            ALUSrc = 1
            MemWrite = 0
            MemRead = 0
            MemToReg = 0
            Branch = 0
            Jump = 1
            ALUOp = 0b00

        case _: 
            RegWrite = 0
            ALUSrc = 0
            MemWrite = 0
            MemRead = 0
            MemToReg = 0
            Branch = 0
            Jump = 0
            ALUOp = 0b00

    return RegWrite, ALUSrc, MemWrite, MemRead, MemToReg, Branch, Jump, ALUOp

@cocotb.test()
async def test_inputs(dut):
    opcodes = [0b0110011, 0b0010011, 0b0000011, 0b1100111, 0b0100011, 0b1100011, 0b0110111, 0b0010111, 0b1101111]

    # Test deafult case and initialize all signals to 0
    dut.opcode.value = 0
    await Timer(1, unit="ns")

    for opcode in opcodes:
        dut.opcode.value = opcode
        RegWrite, ALUSrc, MemWrite, MemRead, MemToReg, Branch, Jump, ALUOp = expected_outputs(opcode)
        await Timer(1, unit="ns")

        assert dut.RegWrite.value == RegWrite, f"RegWrite signal failed for opcode={bin(opcode)}"

        assert dut.ALUSrc.value == ALUSrc, f"ALUSrc signal failed for opcode={bin(opcode)}"

        assert dut.MemWrite.value == MemWrite, f"MemWrite signal failed for opcode={bin(opcode)}"

        assert dut.MemRead.value == MemRead, f"MemRead signal failed for opcode={bin(opcode)}"

        assert dut.MemToReg.value == MemToReg, f"MemToReg signal failed for opcode={bin(opcode)}"

        assert dut.Branch.value == Branch, f"Branch signal failed for opcode={bin(opcode)}"

        assert dut.Jump.value == Jump, f"Jump signal failed for opcode={bin(opcode)}"

        assert dut.ALUOp.value == ALUOp, f"ALUOp signal failed for opcode={bin(opcode)}"

        await Timer(4, unit="ns")
