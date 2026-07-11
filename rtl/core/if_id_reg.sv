// IF/ID Pipeline Reg

module if_id_reg(
    input logic clk, stall, flush, rst,
    input logic [31:0] pc_addr_in, pc_plus4_in, instr_in,
    output logic [31:0] pc_addr, pc_plus4, instr
);

    always_ff @(posedge clk) begin
        if (rst | flush) begin
            pc_addr <= 0;
            pc_plus4 <= 0;
            instr <= 0;
        end
        else if (!stall) begin
            pc_addr <= pc_addr_in;
            pc_plus4 <= pc_plus4_in;
            instr <= instr_in;
        end
    end

endmodule
