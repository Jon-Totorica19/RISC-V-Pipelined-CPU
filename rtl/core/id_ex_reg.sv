// ID/EX Reg

module id_ex_reg (
    input logic clk, flush, rst, stall,
    input logic [31:0] pc_addr_in, pc_plus4_in, rd1_in, rd2_in, imm_in,
    input logic [4:0] rs1_in, rs2_in, rd_in, 
    input logic [2:0] funct3_in,
    input logic funct7_5_in, 
    input logic RegWrite_in, ALUSrc_in, MemRead_in, MemWrite_in, MemToReg_in, Branch_in, Jump_in, is_jalr_in, is_lui_in, is_auipc_in, 
    input logic [1:0] ALUOp_in,
    input logic predicted_taken_in,
    output logic [31:0] pc_addr, pc_plus4, rd1, rd2, imm,
    output logic [4:0] rs1, rs2, rd, 
    output logic [2:0] funct3,
    output logic funct7_5, 
    output logic RegWrite, ALUSrc, MemRead, MemWrite, MemToReg, Branch, Jump, is_jalr, is_lui, is_auipc, 
    output logic [1:0] ALUOp,
    output logic predicted_taken
);

    always_ff @(posedge clk) begin
        if (rst | flush) begin
            pc_addr <= 0;
            pc_plus4 <= 0;
            rd1 <= 0;
            rd2 <= 0;
            imm <= 0;
            rs1 <= 0;
            rs2 <= 0;
            rd <= 0; 
            funct3 <= 0;
            funct7_5 <= 0; 
            RegWrite <= 0;
            ALUSrc <= 0;
            MemRead <= 0;
            MemWrite <= 0;
            MemToReg <= 0;
            Branch <= 0;
            Jump <= 0;
            is_jalr <= 0;
            is_lui <= 0;
            is_auipc <= 0; 
            ALUOp <= 0;
            predicted_taken <= 0;
        end
        else if (stall) begin
            pc_addr <= pc_addr;
            pc_plus4 <= pc_plus4;
            rd1 <= rd1;
            rd2 <= rd2;
            imm <= imm;
            rs1 <= rs1;
            rs2 <= rs2;
            rd <= rd; 
            funct3 <= funct3;
            funct7_5 <= funct7_5; 
            RegWrite <= RegWrite;
            ALUSrc <= ALUSrc;
            MemRead <= MemRead;
            MemWrite <= MemWrite;
            MemToReg <= MemToReg;
            Branch <= Branch;
            Jump <= Jump;
            is_jalr <= is_jalr;
            is_lui <= is_lui;
            is_auipc <= is_auipc; 
            ALUOp <= ALUOp;
            predicted_taken <= predicted_taken;
        end
        else begin
            pc_addr <= pc_addr_in;
            pc_plus4 <= pc_plus4_in;
            rd1 <= rd1_in;
            rd2 <= rd2_in;
            imm <= imm_in;
            rs1 <= rs1_in;
            rs2 <= rs2_in;
            rd <= rd_in; 
            funct3 <= funct3_in;
            funct7_5 <= funct7_5_in; 
            RegWrite <= RegWrite_in;
            ALUSrc <= ALUSrc_in;
            MemRead <= MemRead_in;
            MemWrite <= MemWrite_in;
            MemToReg <= MemToReg_in;
            Branch <= Branch_in;
            Jump <= Jump_in;
            is_jalr <= is_jalr_in;
            is_lui <= is_lui_in;
            is_auipc <= is_auipc_in; 
            ALUOp <= ALUOp_in;
            predicted_taken <= predicted_taken_in;
        end
    end

endmodule
