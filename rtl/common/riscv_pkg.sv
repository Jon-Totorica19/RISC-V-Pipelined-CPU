//=============================================================================
// riscv_pkg.sv

// Shared constants for the RV32I base integer instruction set.
// Source for opcode / funct3 / funct7 encodings so that control_unit.sv, alu_control.sv, imm_gen.sv, etc. never hardcode raw bit patterns.
// Values taken directly from the RISC-V ISA Manual, Chapter 2 (RV32I Base Integer Instruction Set).
// Widths are RV32I: 32-bit instructions, 32-bit registers/ALU/immediates.
// =============================================================================

package riscv_pkg;

  // ---------------------------------------------------------------------------
  // Opcodes (instr[6:0])
  // ---------------------------------------------------------------------------
  localparam logic [6:0] OPCODE_R_TYPE     = 7'b0110011; // add, sub, sll, slt, sltu, xor, srl, sra, or, and
  localparam logic [6:0] OPCODE_I_ALU      = 7'b0010011; // addi, slti, sltiu, xori, ori, andi, slli, srli, srai
  localparam logic [6:0] OPCODE_I_LOAD     = 7'b0000011; // lb, lh, lw, lbu, lhu
  localparam logic [6:0] OPCODE_I_JALR     = 7'b1100111; // jalr
  localparam logic [6:0] OPCODE_S_TYPE     = 7'b0100011; // sb, sh, sw
  localparam logic [6:0] OPCODE_B_TYPE     = 7'b1100011; // beq, bne, blt, bge, bltu, bgeu
  localparam logic [6:0] OPCODE_U_LUI      = 7'b0110111; // lui
  localparam logic [6:0] OPCODE_U_AUIPC    = 7'b0010111; // auipc
  localparam logic [6:0] OPCODE_J_JAL      = 7'b1101111; // jal

  // ---------------------------------------------------------------------------
  // funct3 (instr[14:12]) -- R-type
  // ---------------------------------------------------------------------------
  localparam logic [2:0] F3_ADD_SUB = 3'b000;
  localparam logic [2:0] F3_SLL     = 3'b001;
  localparam logic [2:0] F3_SLT     = 3'b010;
  localparam logic [2:0] F3_SLTU    = 3'b011;
  localparam logic [2:0] F3_XOR     = 3'b100;
  localparam logic [2:0] F3_SRL_SRA = 3'b101;
  localparam logic [2:0] F3_OR      = 3'b110;
  localparam logic [2:0] F3_AND     = 3'b111;

  // funct7 (instr[31:25]) -- R-type / shift-immediate disambiguation
  localparam logic [6:0] F7_NORMAL  = 7'b0000000; // add, srl, slli, srli, and all others w/o alt form
  localparam logic [6:0] F7_ALT     = 7'b0100000; // sub, sra, srai  (funct7[5] = 1)

  // ---------------------------------------------------------------------------
  // funct3 (instr[14:12]) -- I-type ALU-immediate
  // (shares encodings with R-type funct3 above: addi/slti/etc. reuse F3_* names)
  // slli/srli/srai use F3_SLL / F3_SRL_SRA plus F7_NORMAL / F7_ALT on funct7[5]
  // (only bit 5 of funct7 is architecturally defined for immediate shifts
  //  bits [6] and [4:0] of the funct7 field are reserved/shamt in RV32I)
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  // funct3 (instr[14:12]) -- I-type loads
  // ---------------------------------------------------------------------------
  localparam logic [2:0] F3_LB  = 3'b000;
  localparam logic [2:0] F3_LH  = 3'b001;
  localparam logic [2:0] F3_LW  = 3'b010;
  localparam logic [2:0] F3_LBU = 3'b100;
  localparam logic [2:0] F3_LHU = 3'b101;

  // ---------------------------------------------------------------------------
  // funct3 (instr[14:12]) -- S-type stores
  // ---------------------------------------------------------------------------
  localparam logic [2:0] F3_SB = 3'b000;
  localparam logic [2:0] F3_SH = 3'b001;
  localparam logic [2:0] F3_SW = 3'b010;

  // ---------------------------------------------------------------------------
  // funct3 (instr[14:12]) -- B-type branches
  // ---------------------------------------------------------------------------
  localparam logic [2:0] F3_BEQ  = 3'b000;
  localparam logic [2:0] F3_BNE  = 3'b001;
  localparam logic [2:0] F3_BLT  = 3'b100;
  localparam logic [2:0] F3_BGE  = 3'b101;
  localparam logic [2:0] F3_BLTU = 3'b110;
  localparam logic [2:0] F3_BGEU = 3'b111;

  // funct3 for jalr (I-type jump) -- architecturally fixed to 000
  localparam logic [2:0] F3_JALR = 3'b000;

  // ---------------------------------------------------------------------------
  // ALUOp -- main control unit output (Stage 1 of two-stage ALU decode).
  // Tells alu_control.sv how much work it needs to do:
  //   00 -> force ADD        (loads / stores: address = rs1 + imm)
  //   01 -> force SUB        (branches: compare via subtraction)
  //   10 -> decode from funct3/funct7[5] (R-type)
  //   11 -> decode from funct3 (I-ALU-type)
  // ---------------------------------------------------------------------------
  localparam logic [1:0] ALUOP_LOAD_STORE = 2'b00;
  localparam logic [1:0] ALUOP_BRANCH     = 2'b01;
  localparam logic [1:0] ALUOP_RTYPE = 2'b10;
  localparam logic [1:0] ALUOP_ITYPE = 2'b11;

  // ---------------------------------------------------------------------------
  // ALU control select -- Stage 2 output, drives the ALU's operation mux.
  // 4 bits: 10 distinct R-type/I-type-ALU operations
  // ---------------------------------------------------------------------------
  localparam logic [3:0] ALU_AND  = 4'b0000;
  localparam logic [3:0] ALU_OR   = 4'b0001;
  localparam logic [3:0] ALU_ADD  = 4'b0010;
  localparam logic [3:0] ALU_SLL  = 4'b0011;
  localparam logic [3:0] ALU_XOR  = 4'b0100;
  localparam logic [3:0] ALU_SRL  = 4'b0101;
  localparam logic [3:0] ALU_SUB  = 4'b0110;
  localparam logic [3:0] ALU_SLT  = 4'b0111;
  localparam logic [3:0] ALU_SLTU = 4'b1000;
  localparam logic [3:0] ALU_SRA  = 4'b1001;

  // ---------------------------------------------------------------------------
  // Common widths
  // ---------------------------------------------------------------------------
  localparam int XLEN = 32; // RV32I data/address width

endpackage : riscv_pkg
