// Generate a 32 bit immediete. Depends on the type of instruction.
/*
R-type: No immediate

I-type: Contigous bits
instr[31:20] -> imm[11:0]
sign extend bit 31

S-type: Split across two fields
instr[31:25] -> imm[11:5]
instr[11:7] -> imm[4:0]
sign extend bit 31

B-type: Shuffled
instr[31] -> imm[12]
instr[7] -> imm[11]
instr[30:25] -> imm[10:5]
instr[11:8] -> imm[4:1]
imm[0] = 0 (branches always target even addresses. 1 byte offset)
sign extend bit 31

U-type: Upper-imm only
instr[31:12] -> imm[31:12]
imm[11:0] = 0
no sign extend. zero extend 

J-type: Shuffled
instr[31] -> imm[20]
instr[19:12] -> imm[19:12]
instr[20] -> imm[11]
instr[30:21] -> imm[10:1]
imm[0] = 0
sign-extend bit 31

*/

import riscv_pkg::*;

module imm_gen (
    input logic [31:0] instr,
    output logic [31:0] imm
);

    always_comb begin
        unique case (instr[6:0])
            OPCODE_I_ALU, OPCODE_I_LOAD, OPCODE_I_JALR: imm = {{20{instr[31]}}, instr[31:20]};
            OPCODE_S_TYPE: imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            OPCODE_B_TYPE: imm = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
            OPCODE_U_LUI, OPCODE_U_AUIPC: imm = {instr[31:12], 12'b0};
            OPCODE_J_JAL: imm = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:25], instr[24:21], 1'b0};
            default: imm = 32'b0;
        endcase
    end

endmodule
