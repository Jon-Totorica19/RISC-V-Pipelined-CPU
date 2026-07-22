// EX/MEM Reg

module ex_mem_reg (
    input logic clk, rst, stall,
    input logic [31:0] pc_plus4_in, alu_result_in, rd2_in, // rd2 is forwarded store data
    input logic [4:0] rd_in,
    input logic RegWrite_in, MemRead_in, MemWrite_in, MemToReg_in, Jump_in,
    output logic [31:0] pc_plus4, alu_result, rd2,
    output logic [4:0] rd,
    output logic RegWrite, MemRead, MemWrite, MemToReg, Jump
);

    always_ff @(posedge clk) begin
        if (rst) begin
            pc_plus4 <= 0;
            alu_result <= 0;
            rd2 <= 0;
            rd <= 0;
            RegWrite <= 0;
            MemRead <= 0;
            MemWrite <= 0;
            MemToReg <= 0;
            Jump <= 0;
        end
        else if (stall) begin
            pc_plus4 <= pc_plus4;
            alu_result <= alu_result;
            rd2 <= rd2;
            rd <= rd;
            RegWrite <= RegWrite;
            MemRead <= MemRead;
            MemWrite <= MemWrite;
            MemToReg <= MemToReg;
            Jump <= Jump;
        end
        else begin
            pc_plus4 <= pc_plus4_in;
            alu_result <= alu_result_in;
            rd2 <= rd2_in;
            rd <= rd_in;
            RegWrite <= RegWrite_in;
            MemRead <= MemRead_in;
            MemWrite <= MemWrite_in;
            MemToReg <= MemToReg_in;
            Jump <= Jump_in;
        end
    end

endmodule
