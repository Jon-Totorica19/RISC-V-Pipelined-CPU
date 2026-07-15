// 32 general purpose register file
module reg_file (
    input logic clk,
    input logic RegWrite,
    input logic [4:0] rs1, rs2, rd,
    input logic [31:0] WriteData,
    output logic [31:0] rd1, rd2
);
    // Internal Storage. 32 regs 32 bits each
    logic [31:0] regs [31:0];

    // Asynchrnous Register Reads. Accomodate for writes and reads in the same cycle. Write first, read second, using MUX
    always_comb begin
        rd1 = (RegWrite && rd != 5'd0 && rd == rs1) ? WriteData : regs[rs1];
        rd2 = (RegWrite && rd != 5'd0 && rd == rs2) ? WriteData : regs[rs2];
    end

    // Synchrnous Register Writes
    always_ff @(posedge clk) begin 
        if (RegWrite && rd != 5'd0) begin
            regs[rd] <= WriteData;
        end
    end

endmodule
