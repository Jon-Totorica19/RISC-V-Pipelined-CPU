// MEM/WB

module mem_wb_reg (
    input logic clk, rst,
    input logic [31:0] pc_plus4_in, alu_result_in, read_data_in,
    input logic [4:0] rd_in, 
    input logic RegWrite_in, MemToReg_in, Jump_in,
    output logic [31:0] pc_plus4, alu_result, read_data,
    output logic [4:0] rd, 
    output logic RegWrite, MemToReg, Jump
);

    always_ff @(posedge clk) begin
        if (rst) begin
            pc_plus4 <= 0;
            alu_result <= 0;
            read_data <= 0;
            rd <= 0; 
            RegWrite <= 0;
            MemToReg <= 0;
            Jump <= 0;
        end
        else begin
            pc_plus4 <= pc_plus4_in;
            alu_result <= alu_result_in;
            read_data <= read_data_in;
            rd <= rd_in; 
            RegWrite <= RegWrite_in;
            MemToReg <= MemToReg_in;
            Jump <= Jump_in;
        end
    end

endmodule
