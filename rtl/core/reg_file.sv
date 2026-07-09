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

    // Asynchrnous Register Reads
    always_comb begin
        rd1 = (rs1 != 5'd0) ? regs[rs1] : 32'd0;
        rd2 = (rs2 != 5'd0) ? regs[rs2] : 32'd0;
    end

    // Synchrnous Register Writes
    always_ff @(posedge clk) begin 
        if (RegWrite && rd != 5'd0) begin
            regs[rd] <= WriteData;
        end
    end

endmodule
