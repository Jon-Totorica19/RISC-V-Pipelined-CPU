// Functional Unit: Arithmetic Logic Unit (ALU)
// ALU is purely combinational, need to accommodate for all different instructions/operations

import riscv_pkg::*;

module alu (
    input logic [31:0] a, b,
    input logic [3:0] alu_ctrl,
    output logic [31:0] result, 
    output logic zero
);
    always_comb begin
        unique case (alu_ctrl)
            ALU_ADD: result = a + b;
            ALU_SUB: result = a - b;
            ALU_AND: result = a & b;
            ALU_OR: result = a | b;
            ALU_XOR: result = a ^ b;
            ALU_SLL: result = a << b[4:0]; // fill with zeros
            ALU_SRL: result = a >> b[4:0]; // fill with zeros
            ALU_SRA: result = $signed(a) >>> b[4:0]; // fill with sign bit
            ALU_SLT: result = $signed(a) < $signed(b) ? 32'd1 : 32'd0;
            ALU_SLTU: result = a < b ? 32'd1 : 32'd0;
            default: result = 32'd0;
        endcase
    end

    // zero bit for branch logic
    assign zero = (result == 32'd0);
    
endmodule
