// Instruction Memory: Takes an address as input from PC and outputs the next instrction of the program

// Updated Instr Mem: Only reads on a miss from icache and sends cache back the instruction

module instr_mem (
    input logic clk, read_en,
    input logic [31:0] addr,
    output logic [31:0] instr
);

    // Internal Storage: 256 words -- 1KiB
    logic [31:0] mem [0:255];

    always_ff @(posedge clk) begin
        if (read_en)
            instr <= mem[addr[9:2]];
    end

endmodule
