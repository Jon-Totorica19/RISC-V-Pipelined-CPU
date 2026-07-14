// Program Counter: Holds the current PC value and increments on each clock edge. PC value used to address the instruction memory
module pc (
    input logic clk, rst, stall,
    input logic [31:0] next_pc,
    output logic [31:0] pc_addr
);

    always_ff @(posedge clk) begin
        if (rst) 
        pc_addr <= 0;
        else if (stall)
            pc_addr <= pc_addr;
        else
        pc_addr <= next_pc;
    end

endmodule
