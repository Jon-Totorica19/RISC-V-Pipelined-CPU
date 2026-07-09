// Single Cycle RISC-V Core. Wiring of all modules

import riscv_pkg::*;

module riscv_core (
    input logic clk, rst
);

    logic [31:0] pc_addr, next_pc, pc_plus4, pc_target;
    logic [31:0] instr;
    logic [31:0] rd1, rd2;
    logic [31:0] imm;
    logic [31:0] alu_a, alu_b, alu_result;
    logic        zero;
    logic [31:0] read_data, write_back;
    logic        RegWrite, ALUSrc, MemWrite, MemRead, MemToReg, Branch, Jump;
    logic [1:0]  ALUOp;
    logic [3:0]  alu_ctrl;
    logic is_jalr;
    logic is_lui, is_auipc;
    logic branch_taken;


    pc PC (
        .clk(clk),
        .rst(rst),
        .next_pc(next_pc),
        .pc_addr(pc_addr)
    );

    instr_mem instr_mem (
        .addr(pc_addr),
        .instr(instr)
    );

    control_unit control_unit (
        .opcode(instr[6:0]),
        .RegWrite(RegWrite),
        .ALUSrc(ALUSrc),
        .MemWrite(MemWrite),
        .MemToReg(MemToReg), 
        .MemRead(MemRead),
        .Branch(Branch),
        .Jump(Jump),
        .ALUOp(ALUOp)
    );

    alu_control alu_control (
        .funct7_5(instr[30]),
        .ALUOp(ALUOp),
        .funct3(instr[14:12]),
        .alu_ctrl(alu_ctrl)
    );

    reg_file reg_file (
        .clk(clk),
        .RegWrite(RegWrite),
        .rs1(instr[19:15]),
        .rs2(instr[24:20]),
        .rd(instr[11:7]),
        .WriteData(write_back),
        .rd1(rd1),
        .rd2(rd2)
    );

    imm_gen imm_gen (
        .instr(instr),
        .imm(imm)
    );

    // Decode LUI or AUIPC instr
    assign is_lui = (instr[6:0] == OPCODE_U_LUI);
    assign is_auipc = (instr[6:0] == OPCODE_U_AUIPC);

    // 3:1 MUX - Select ALU Source 1. Accomodate for lui and auipc instr. 
    assign alu_a = is_lui ? 32'd0 : is_auipc ? pc_addr : rd1;

    // 2:1 MUX - Select ALU Source 2. Immediete value or read data memory
    assign alu_b = ALUSrc ? imm : rd2;

    alu alu (
        .a(alu_a),
        .b(alu_b),
        .alu_ctrl(alu_ctrl),
        .result(alu_result),
        .zero(zero)
    );

    data_mem data_mem (
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .clk(clk),
        .writeData(rd2),
        .addr(alu_result), 
        .readData(read_data)
    );

    // 3:1 MUX - Select Writeback Source. JAL/JALR link register, alu_result, or read data memory
    assign write_back = Jump ? pc_plus4 : MemToReg ? read_data : alu_result;

    // Increment PC
    assign pc_plus4 = pc_addr + 4;

    // Branch Target
    assign pc_target = imm + pc_addr;

    // Branch Taken Logic to accomdate BEQ, BNE, BLT, BGE, BLTU, BGEU
    always_comb begin
        case (instr[14:12])
            F3_BEQ: branch_taken = zero;
            F3_BNE: branch_taken = ~zero; 
            F3_BLT, F3_BLTU: branch_taken = alu_result[0];
            F3_BGE, F3_BGEU: branch_taken = ~alu_result[0];
            default: branch_taken = 0;
        endcase
    end


    // Jump Logic. JAL and JALR
    assign is_jalr = (instr[6:0] == 7'b1100111); 

    // 4:1 MUX - Select next_pc. JALR (rs1 + imm), JAL (pc + imm), branch target, increment pc
    assign next_pc = (Jump & is_jalr) ? alu_result : Jump ? pc_target : (Branch & branch_taken) ? pc_target : pc_plus4;


endmodule
