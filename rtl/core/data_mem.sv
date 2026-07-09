// Data Memory. On MemRead, output the value at input address. On MemWrite, write the input value at the input address

module data_mem(
    input logic MemRead, MemWrite, clk,
    input logic [31:0] writeData, addr, 
    output logic [31:0] readData
);

    // Internal Storage: 256 words -- 1 KiB
    logic [31:0] mem [0:255] /* verilator public */;

    // Asynchronous Reads
    assign readData = mem[addr[9:2]]; // Index mem based on size and word offset

    // Synchronous Writes
    always_ff @(posedge clk) begin
        if (MemWrite) begin
            mem[addr[9:2]] <= writeData;
        end
    end



endmodule
