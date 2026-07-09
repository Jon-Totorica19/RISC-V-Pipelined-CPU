// Instruction Memory: Takes an address as input from PC and outputs the next instrction of the program

module instr_mem (
    input logic [31:0] addr,
    output logic [31:0] instr
);

    // Internal Storage: 256 words -- 1KiB
    logic [31:0] mem [0:255];

    // Initial blocks run exactly once at time zero when sim starts
    // Load mem from a hex file. $readmemh reads line by line and loads each value into mem[0], mem[1]....
    // A hex file is a plain text file where each line is a 32 bit instruction

    /*
    Instructions are loaded in from python files instead
    initial begin
        $readmemh("program.hex", mem);
    end
    */

    assign instr = mem[addr[9:2]];

endmodule
