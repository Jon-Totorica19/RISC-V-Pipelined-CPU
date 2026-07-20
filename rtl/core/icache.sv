// 256 byte instruction memeory cache. One word per block
// 256 bytes / 1 word (4 bytes) per block -> 64 entries.
// log2(64) = 6 index bits. log2(4) = 2 offset bits. 32 - 6 - 2 = 24 tag bits
// [31:8] tag | [7:2] index | [1:0] block offset (00)
// flush signal to handle edge case: branch instruction in ID or EX during a cache miss, could exit the miss penalty early and ctr needs to be reset 

module icache (
    input logic clk, rst, read_en, flush,
    input logic [31:0] addr, mem_data,
    output logic stall, mem_read,
    output logic [31:0] instr, mem_addr
);

    // Internal instr cache
    logic valid [63:0];
    logic [23:0] tag [63:0];
    logic [31:0] data [63:0];
    logic [3:0] ctr;
 
    // Miss Penalty Counter and Cache update/fill
    always_ff @(posedge clk) begin
        if (rst) begin
            ctr <= 0;
            for (int i = 0; i < 64; i++) begin
                valid[i] <= 1'd0;
                tag[i] <= 24'd0;
                data[i] <= 32'd0;
            end
        end
        else if (flush)
            ctr <= 0;
        else if (read_en) begin
            if (!(valid[addr[7:2]] && tag[addr[7:2]] == addr[31:8]))  begin // miss. 10 cycle miss penalty, then update cache entry
                if (ctr == 'd9) begin
                    data[addr[7:2]] <= mem_data;
                    valid[addr[7:2]] <= 1'b1;
                    tag[addr[7:2]] <= addr[31:8];
                    ctr <= 0;
                end
                else
                    ctr <= ctr + 1;
            end
        end
    end

    always_comb begin
        stall = 1'b0;
        mem_read = 1'b0;
        mem_addr = 32'd0;
        instr = 32'd0;
        if (read_en) begin
            if (valid[addr[7:2]] && tag[addr[7:2]] == addr[31:8])  begin // hit
                instr = data[addr[7:2]];
            end
            else begin  // miss
                stall = 1'b1;
                mem_read = 1'b1;
                mem_addr = addr;
             end
        end
    end

endmodule
