// Top module for RISC-V Pipelined core. Instantiate the core (including the caches) and instr and data memories, and wire together
module riscv_top (
    input logic clk, rst
);

    logic icache_mem_read, dcache_mem_read, dcache_mem_write;
    logic [31:0] instr, mem_read_data, icache_mem_addr, dcache_mem_addr, dcache_mem_write_data;

    riscv_core riscv_core (
        .clk(clk),
        .rst(rst),
        .instr(instr),
        .mem_read_data(mem_read_data),
        .icache_mem_read(icache_mem_read),
        .dcache_mem_read(dcache_mem_read),
        .dcache_mem_write(dcache_mem_write),
        .icache_mem_addr(icache_mem_addr),
        .dcache_mem_addr(dcache_mem_addr),
        .dcache_mem_write_data(dcache_mem_write_data)
    );

    instr_mem instr_mem (
        .clk(clk),
        .read_en(icache_mem_read),
        .addr(icache_mem_addr),
        .instr(instr)
    );

    data_mem data_mem (
        .MemRead(dcache_mem_read),
        .MemWrite(dcache_mem_write),
        .clk(clk),
        .writeData(dcache_mem_write_data),
        .addr(dcache_mem_addr), 
        .readData(mem_read_data)
    );

endmodule
