// Control Unit: Takes in an instruction opcode and sets all control signals accordingly

/*
  localparam logic [1:0] ALUOP_LOAD_STORE = 2'b00;
  localparam logic [1:0] ALUOP_BRANCH     = 2'b01;
  localparam logic [1:0] ALUOP_RTYPE_ITYPE = 2'b10;
  localparam logic [1:0] ALUOP_DONT_CARE  = 2'b11;
*/

import riscv_pkg::*;

module control_unit (
    input logic [6:0] opcode,
    output logic RegWrite, ALUSrc, MemWrite, MemToReg, MemRead, Branch, Jump,
    output logic [1:0] ALUOp
);

    always_comb begin
        unique case (opcode)
            OPCODE_R_TYPE: begin
                 RegWrite = 1; ALUSrc = 0; MemWrite = 0; MemRead = 0; MemToReg = 0; Branch = 0; Jump = 0; ALUOp = ALUOP_RTYPE;
            end

            OPCODE_I_ALU: begin
                RegWrite = 1; ALUSrc = 1; MemWrite = 0; MemRead = 0; MemToReg = 0; Branch = 0; Jump = 0; ALUOp = ALUOP_ITYPE;
            end

            OPCODE_I_LOAD: begin
                RegWrite = 1; ALUSrc = 1; MemWrite = 0; MemRead = 1; MemToReg = 1; Branch = 0; Jump = 0; ALUOp = ALUOP_LOAD_STORE;
            end

            OPCODE_I_JALR: begin
                RegWrite = 1; ALUSrc = 1; MemWrite = 0; MemRead = 0; MemToReg = 0; Branch = 0; Jump = 1; ALUOp = ALUOP_LOAD_STORE;
            end

            OPCODE_S_TYPE: begin
                RegWrite = 0; ALUSrc = 1; MemWrite = 1; MemRead = 0; MemToReg = 0; Branch = 0; Jump = 0; ALUOp = ALUOP_LOAD_STORE;
            end

            OPCODE_B_TYPE: begin
                RegWrite = 0; ALUSrc = 0; MemWrite = 0; MemRead = 0; MemToReg = 0; Branch = 1; Jump = 0; ALUOp = ALUOP_BRANCH;
            end

            OPCODE_U_LUI, OPCODE_U_AUIPC: begin
                RegWrite = 1; ALUSrc = 1; MemWrite = 0; MemRead = 0; MemToReg = 0; Branch = 0; Jump = 0; ALUOp = ALUOP_LOAD_STORE;
            end

            OPCODE_J_JAL: begin
                RegWrite = 1; ALUSrc = 1; MemWrite = 0; MemRead = 0; MemToReg = 0; Branch = 0; Jump = 1; ALUOp = ALUOP_LOAD_STORE;
            end

            default: {RegWrite, ALUSrc, MemWrite, MemRead, MemToReg, Branch, Jump, ALUOp} = '0;
        endcase

    end

endmodule
