// ALU Control: Takes ALUOp from the control unit, bit5 of funct7, and funct3 and selectes the ALU operation

import riscv_pkg::*;

module alu_control (
    input logic funct7_5,
    input logic [1:0] ALUOp,
    input logic [2:0] funct3,
    output logic [3:0] alu_ctrl
);

    always_comb begin
        unique case (ALUOp)
            2'b00: // Load_Store -- ADD
                alu_ctrl = ALU_ADD;
            2'b01: begin // Branch -- Decode funct3 
                case (funct3)
                    F3_BEQ, F3_BNE: // SUB
                        alu_ctrl = ALU_SUB;

                    F3_BLT, F3_BGE: // SLT
                        alu_ctrl = ALU_SLT;

                    F3_BLTU, F3_BGEU: // SLTU
                        alu_ctrl = ALU_SLTU;

                    default: // SUB
                        alu_ctrl = ALU_SUB;
                endcase
            end

            2'b10: begin// R-type -- decide by funct7_bit5, funct3
                casez ({funct7_5, funct3}) //casez is used for wildcard matching with the ? dontcare
                    4'b0000: // ADD
                        alu_ctrl = ALU_ADD;

                    4'b1000: // SUB
                        alu_ctrl = ALU_SUB;

                    4'b?001: // SLL
                        alu_ctrl = ALU_SLL;

                    4'b?010: // SLT
                        alu_ctrl = ALU_SLT;

                    4'b?011: // SLTU
                        alu_ctrl = ALU_SLTU;

                    4'b?100: // XOR
                        alu_ctrl = ALU_XOR;

                    4'b0101: // SRL
                        alu_ctrl = ALU_SRL;

                    4'b1101: // SRA
                        alu_ctrl = ALU_SRA;

                    4'b?110: // OR
                        alu_ctrl = ALU_OR;

                    4'b?111: // AND
                        alu_ctrl = ALU_AND;

                    default: // Default to ADD
                        alu_ctrl = ALU_ADD;
                endcase
            end
            2'b11: begin // I-ALU - decide by funct3
                case (funct3)
                    F3_ADD_SUB: // addi - always add, ignore bit 30, no funct7
                        alu_ctrl = ALU_ADD;
                    F3_SLL: // slli
                        alu_ctrl = ALU_SLL;
                    F3_SLT: // slti
                        alu_ctrl = ALU_SLT;
                    F3_SLTU: //sltui
                        alu_ctrl = ALU_SLTU;
                    F3_XOR: // xori
                        alu_ctrl = ALU_XOR;
                    F3_SRL_SRA: //srai vs srli
                        alu_ctrl = funct7_5 ? ALU_SRA : ALU_SRL; // srai vs srli. can use bit 30 since shifts are 5 bits max
                    F3_OR: // ori
                        alu_ctrl = ALU_OR;
                    F3_AND: // andi
                        alu_ctrl = ALU_AND;
                    default:
                        alu_ctrl = ALU_ADD;
                endcase
            end
            default: // Default to ADD
                alu_ctrl = ALU_ADD;
        endcase
    end
endmodule
