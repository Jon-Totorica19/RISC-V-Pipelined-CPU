import cocotb
from cocotb.triggers import Timer

def expected_outputs(funct7_5, ALUOp, funct3):
    match ALUOp:
        case 0b00: # Load-Store -- ADD
            alu_ctrl = 0b0010

        case 0b01: # Branch -- SUB
            alu_ctrl = 0b0110

        case 0b10:
            match (funct7_5, funct3):
                case (0b0, 0b000): # ADD
                    alu_ctrl = 0b0010

                case (0b1, 0b000): # SUB
                    alu_ctrl = 0b0110

                case (_, 0b001): # SLL
                    alu_ctrl = 0b0011

                case (_, 0b010): # SLT
                    alu_ctrl = 0b0111

                case (_, 0b011): # SLTU
                    alu_ctrl = 0b1000

                case (_, 0b100): # XOR
                    alu_ctrl = 0b0100

                case (0b0, 0b101): # SRL
                    alu_ctrl = 0b0101

                case (0b1, 0b101): # SRA
                    alu_ctrl = 0b1001

                case (_, 0b110): # OR
                    alu_ctrl = 0b0001

                case (_, 0b111): # AND
                    alu_ctrl = 0b0000

                case (_,_): # Deafult to ADD
                    alu_ctrl = 0b0010

        case _: # Deafult ADD operation
            alu_ctrl = 0b0010
    return alu_ctrl

@cocotb.test()
async def test_inputs(dut):
    ALUOp_vals = [0b00, 0b01, 0b10, 0b11]
    funct7_5_vals = [0b0, 0b1]
    funct3_vals =  [0b000, 0b001, 0b010, 0b011, 0b100, 0b101, 0b110, 0b111]

    for funct7_5_val in funct7_5_vals:
        for ALUOp_val in ALUOp_vals:
            for funct3_val in funct3_vals:
                dut.ALUOp.value = ALUOp_val
                dut.funct7_5.value = funct7_5_val
                dut.funct3.value = funct3_val

                await Timer(1, unit="ns")

                assert dut.alu_ctrl.value == expected_outputs(funct7_5_val, ALUOp_val, funct3_val), f"alu_ctrl failed for ALUOp:{ALUOp_val}, funct7:{funct7_5_val}, funct3:{funct3_val}"

                await Timer(4, unit="ns")
