// 5 Stage Pipelined RISC-V Core. Wiring of all modules

import riscv_pkg::*;

module riscv_core (
    input logic clk, rst
);
    // Single Cycle Wires
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

    // IF/ID Wires
    logic [31:0] if_id_pc_addr, if_id_pc_plus4, if_id_instr;

    // ID/EX Wires
    logic [31:0] id_ex_pc_addr, id_ex_pc_plus4, id_ex_rd1, id_ex_rd2, id_ex_imm;
    logic [4:0] id_ex_rs1, id_ex_rs2, id_ex_rd;
    logic [2:0] id_ex_funct3;
    logic id_ex_funct7_5;
    logic id_ex_RegWrite, id_ex_ALUSrc, id_ex_MemRead, id_ex_MemWrite, id_ex_MemToReg, id_ex_Branch, id_ex_Jump, id_ex_is_jalr, id_ex_is_lui, id_ex_is_auipc;
    logic [1:0] id_ex_ALUOp;
    logic id_ex_predicted_taken;

    // EX/MEM Wires
    logic [31:0] ex_mem_pc_plus4, ex_mem_alu_result, ex_mem_rd2;
    logic [4:0] ex_mem_rd;
    logic ex_mem_RegWrite, ex_mem_MemRead, ex_mem_MemWrite, ex_mem_MemToReg, ex_mem_Jump;

    // MEM/WB Wires
    logic [31:0] mem_wb_pc_plus4, mem_wb_alu_result, mem_wb_read_data;
    logic [4:0] mem_wb_rd;
    logic mem_wb_RegWrite, mem_wb_MemToReg, mem_wb_Jump;

    // Forwarding Unit Wires
    logic [1:0] forward_a, forward_b; // MUX Control signals
    logic [31:0] fwd_a, fwd_b; // ALU Source Data Values

    // Hazard Detection Unit Wires
    logic stall, flush_id_ex, branch_flush;

    // Branch Prediction Wire
    logic predict_taken;
    logic [31:0] id_prediction_target;


    // IF Stage: pc, instr_mem, pc+4 (Adder)
    pc PC (
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .next_pc(next_pc),
        .pc_addr(pc_addr)
    );

    instr_mem instr_mem (
        .addr(pc_addr),
        .instr(instr)
    );

    // Increment PC
    assign pc_plus4 = pc_addr + 4;

    // IF/ID Pipeline Register
    if_id_reg if_id_reg (
        .clk(clk),
        .stall(stall),
        .flush(branch_flush | predict_taken),
        .rst(rst),
        .pc_addr_in(pc_addr),
        .pc_plus4_in(pc_plus4),
        .instr_in(instr),
        .pc_addr(if_id_pc_addr),
        .pc_plus4(if_id_pc_plus4),
        .instr(if_id_instr)
    );

    // ID Stage: lui/auipc decode, branch preictor, branch prediction target address, hazard detection unit, id_ex_flsuh decision, control_unit, reg_file, imm_gen, jump instr signal

    // Decode LUI or AUIPC instr
    assign is_lui = (if_id_instr[6:0] == OPCODE_U_LUI);
    assign is_auipc = (if_id_instr[6:0] == OPCODE_U_AUIPC);

    // Jump instr signal. JAL and JALR
    assign is_jalr = (if_id_instr[6:0] == 7'b1100111); 

    branch_predictor branch_predictor (
        .clk(clk),
        .rst(rst),
        .pc_id(if_id_pc_addr),
        .pc_ex(id_ex_pc_addr),
        .is_branch_id(Branch),
        .is_branch_ex(id_ex_Branch),
        .branch_taken(branch_taken),
        .predict_taken(predict_taken)
    );

    assign id_prediction_target = if_id_pc_addr + imm;

    hazard_detection_unit hazard_detection_unit (
        .id_ex_MemRead(id_ex_MemRead),
        .id_ex_rd(id_ex_rd),
        .if_id_rs1(if_id_instr[19:15]),
        .if_id_rs2(if_id_instr[24:20]),
        .stall(stall),
        .flush_id_ex(flush_id_ex)
    );

    control_unit control_unit (
        .opcode(if_id_instr[6:0]),
        .RegWrite(RegWrite),
        .ALUSrc(ALUSrc),
        .MemWrite(MemWrite),
        .MemToReg(MemToReg), 
        .MemRead(MemRead),
        .Branch(Branch),
        .Jump(Jump),
        .ALUOp(ALUOp)
    );

    reg_file reg_file (
        .clk(clk),
        .RegWrite(mem_wb_RegWrite),
        .rs1(if_id_instr[19:15]),
        .rs2(if_id_instr[24:20]),
        .rd(mem_wb_rd),
        .WriteData(write_back),
        .rd1(rd1),
        .rd2(rd2)
    );

    imm_gen imm_gen (
        .instr(if_id_instr),
        .imm(imm)
    );

    // ID/EX Pipeline Register
    id_ex_reg id_ex_reg (
        .clk(clk),
        .flush(flush_id_ex | branch_flush),
        .rst(rst),
        .pc_addr_in(if_id_pc_addr),
        .pc_plus4_in(if_id_pc_plus4),
        .rd1_in(rd1),
        .rd2_in(rd2),
        .imm_in(imm),
        .rs1_in(if_id_instr[19:15]),
        .rs2_in(if_id_instr[24:20]),
        .rd_in(if_id_instr[11:7]),
        .funct3_in(if_id_instr[14:12]),
        .funct7_5_in(if_id_instr[30]),
        .RegWrite_in(RegWrite),
        .ALUSrc_in(ALUSrc),
        .MemRead_in(MemRead),
        .MemWrite_in(MemWrite),
        .MemToReg_in(MemToReg),
        .Branch_in(Branch),
        .Jump_in(Jump),
        .is_jalr_in(is_jalr),
        .is_lui_in(is_lui),
        .is_auipc_in(is_auipc),
        .ALUOp_in(ALUOp),
        .predicted_taken_in(predict_taken),
        .pc_addr(id_ex_pc_addr),
        .pc_plus4(id_ex_pc_plus4),
        .rd1(id_ex_rd1),
        .rd2(id_ex_rd2),
        .imm(id_ex_imm),
        .rs1(id_ex_rs1),
        .rs2(id_ex_rs2),
        .rd(id_ex_rd),
        .funct3(id_ex_funct3),
        .funct7_5(id_ex_funct7_5),
        .RegWrite(id_ex_RegWrite),
        .ALUSrc(id_ex_ALUSrc),
        .MemRead(id_ex_MemRead),
        .MemWrite(id_ex_MemWrite),
        .MemToReg(id_ex_MemToReg),
        .Branch(id_ex_Branch),
        .Jump(id_ex_Jump),
        .is_jalr(id_ex_is_jalr),
        .is_lui(id_ex_is_lui),
        .is_auipc(id_ex_is_auipc),
        .ALUOp(id_ex_ALUOp),
        .predicted_taken(id_ex_predicted_taken)
    );

    // EX Stage: alu_control, forwarding unit, branch flsuh unit, ALU source 1 and 2 MUXs, brach target address (Adder), ALU
    alu_control alu_control (
        .funct7_5(id_ex_funct7_5),
        .ALUOp(id_ex_ALUOp),
        .funct3(id_ex_funct3),
        .alu_ctrl(alu_ctrl)
    );

    forwarding_unit forwarding_unit (
        .ex_mem_RegWrite(ex_mem_RegWrite),
        .mem_wb_RegWrite(mem_wb_RegWrite),
        .ex_mem_rd(ex_mem_rd),
        .mem_wb_rd(mem_wb_rd),
        .id_ex_rs1(id_ex_rs1),
        .id_ex_rs2(id_ex_rs2),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );

    branch_flush_unit branch_flush_unit (
        .id_ex_Branch(id_ex_Branch),
        .branch_taken(branch_taken),
        .id_ex_Jump(id_ex_Jump),
        .id_ex_predicted_taken(id_ex_predicted_taken),
        .flush(branch_flush)
    );

    // 3:1 MUX - Select rd1 source for ALU Input a
    always_comb begin
        case (forward_a)
            2'b10: fwd_a = ex_mem_alu_result;  
            2'b01: fwd_a = write_back;
            default: fwd_a = id_ex_rd1;
        endcase
    end

    // 3:1 MUX - Select ALU Source 1. Accomodate for lui and auipc instr. 
    assign alu_a = id_ex_is_lui ? 32'd0 : id_ex_is_auipc ? id_ex_pc_addr : fwd_a;

    // 3:1 MUX - Select rd2 source for ALU Input b
    always_comb begin
        case (forward_b)
            2'b10: fwd_b = ex_mem_alu_result;  
            2'b01: fwd_b = write_back;
            default: fwd_b = id_ex_rd2;
        endcase
    end

    // 2:1 MUX - Select ALU Source 2. Immediete value or read data memory
    assign alu_b = id_ex_ALUSrc ? id_ex_imm : fwd_b;

    alu alu (
        .a(alu_a),
        .b(alu_b),
        .alu_ctrl(alu_ctrl),
        .result(alu_result),
        .zero(zero)
    );

    // Branch Target Address (Adder)
    assign pc_target = id_ex_imm + id_ex_pc_addr;

    // Branch Taken Logic to accomdate BEQ, BNE, BLT, BGE, BLTU, BGEU
    always_comb begin
        case (id_ex_funct3)
            F3_BEQ: branch_taken = zero;
            F3_BNE: branch_taken = ~zero; 
            F3_BLT, F3_BLTU: branch_taken = alu_result[0];
            F3_BGE, F3_BGEU: branch_taken = ~alu_result[0];
            default: branch_taken = 0;
        endcase
    end

    // 4:1 MUX - Select next_pc. JALR (rs1 + imm), JAL (pc + imm), branch target (prediction included), increment pc. EX Stage for branches, ID for jump, IF for pc+4

     assign next_pc = (id_ex_Jump & id_ex_is_jalr) ? alu_result : id_ex_Jump ? pc_target : (id_ex_Branch & branch_taken & ~id_ex_predicted_taken) ? pc_target : (id_ex_Branch & ~branch_taken & id_ex_predicted_taken) ? id_ex_pc_plus4 : predict_taken ? id_prediction_target : pc_plus4;

    // EX/MEM Pipeline Register
    ex_mem_reg ex_mem_reg (
        .clk(clk),
        .rst(rst),
        .pc_plus4_in(id_ex_pc_plus4),
        .alu_result_in(alu_result),
        .rd2_in(fwd_b),
        .rd_in(id_ex_rd),
        .RegWrite_in(id_ex_RegWrite),
        .MemRead_in(id_ex_MemRead),
        .MemWrite_in(id_ex_MemWrite),
        .MemToReg_in(id_ex_MemToReg),
        .Jump_in(id_ex_Jump),
        .pc_plus4(ex_mem_pc_plus4),
        .alu_result(ex_mem_alu_result),
        .rd2(ex_mem_rd2),
        .rd(ex_mem_rd),
        .RegWrite(ex_mem_RegWrite),
        .MemRead(ex_mem_MemRead),
        .MemWrite(ex_mem_MemWrite),
        .MemToReg(ex_mem_MemToReg),
        .Jump(ex_mem_Jump)
    );

    // Mem Stage: data_mem
    data_mem data_mem (
        .MemRead(ex_mem_MemRead),
        .MemWrite(ex_mem_MemWrite),
        .clk(clk),
        .writeData(ex_mem_rd2),
        .addr(ex_mem_alu_result), 
        .readData(read_data)
    );

    // MEM/WB Pipeline Reg
    mem_wb_reg mem_wb_reg (
        .clk(clk),
        .rst(rst),
        .pc_plus4_in(ex_mem_pc_plus4),
        .alu_result_in(ex_mem_alu_result),
        .read_data_in(read_data),
        .rd_in(ex_mem_rd),
        .RegWrite_in(ex_mem_RegWrite),
        .MemToReg_in(ex_mem_MemToReg),
        .Jump_in(ex_mem_Jump),
        .pc_plus4(mem_wb_pc_plus4),
        .alu_result(mem_wb_alu_result),
        .read_data(mem_wb_read_data),
        .rd(mem_wb_rd),
        .RegWrite(mem_wb_RegWrite),
        .MemToReg(mem_wb_MemToReg),
        .Jump(mem_wb_Jump)
    );

    // 3:1 MUX - Select Writeback Source. JAL/JALR link register, alu_result, or read data memory
    assign write_back = mem_wb_Jump ? mem_wb_pc_plus4 : mem_wb_MemToReg ? mem_wb_read_data : mem_wb_alu_result;


endmodule
