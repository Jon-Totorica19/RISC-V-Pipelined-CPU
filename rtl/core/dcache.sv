// 256 bytes / 1 word (4 bytes) per block -> 64 entries.
// log2(64) = 6 index bits. log2(4) = 2 offset bits. 32 - 6 - 2 = 24 tag bits
// [31:8] tag | [7:2] index | [1:0] block offset (00)

module dcache (
    input logic clk, rst, read_en, write_en,
    input logic [31:0] addr, mem_data, write_data,
    output logic stall, mem_read, mem_write,
    output logic [31:0] mem_addr, read_data, mem_write_data
);

// Internal data cache state
    logic valid [63:0];
    logic dirty [63:0];
    logic [23:0] tag [63:0];
    logic [31:0] data [63:0];
    logic [3:0] ctr;
    logic writeback_pending; // hold if the write back is complete on a dirty eviction

    always_ff @(posedge clk) begin
        if (rst) begin
            ctr <= 0;
            writeback_pending <= 1'd0;
            for (int i = 0; i < 64; i++) begin
                valid[i] <= 1'd0;
                dirty[i] <= 1'd0;
                tag[i] <= 24'd0;
                data[i] <= 32'd0;
            end
        end
        else if (writeback_pending) begin // write dirty back to DRAM
             writeback_pending <= 1'b0;
             dirty[addr[7:2]] <= 1'b0;
        end
        else if (read_en || write_en) begin // a mem access instr
            if (valid[addr[7:2]] && tag[addr[7:2]] == addr[31:8]) begin // hit
                // stores: write/update cache entry, set dirty bit
                // loads: handle on combinational
                if (write_en) begin
                    valid[addr[7:2]] <= 1'd1;
                    dirty[addr[7:2]] <= 1'd1;
                    tag[addr[7:2]] <= addr[31:8];
                    data[addr[7:2]] <= write_data;
                end
            end
            else begin // miss
                if (ctr == 9)  begin // miss penalty complete, update cache, set valid, for writes: write data, set dirty
                    valid[addr[7:2]] <= 1'd1;
                    tag[addr[7:2]] <= addr[31:8];
                    dirty[addr[7:2]] <= write_en ? 1'd1 : 1'd0;
                    data[addr[7:2]] <= write_en ? write_data : mem_data;
                    ctr <= 0;
                end
                else if (ctr == 0 && dirty[addr[7:2]]) begin // dirty eviction
                    writeback_pending <= 1'b1;
                end
                else // mid miss
                    ctr <= ctr + 1;
            end
        end
    end

    always_comb begin
        stall = 1'b0;
        mem_read = 1'b0;
        mem_write = 1'b0;
        mem_addr = 32'd0;
        read_data = 32'd0;
        mem_write_data = 32'd0;

        if (writeback_pending) begin // in dirty bit writeback to DRAM
                stall = 1'b1;
                mem_write = 1'b1;
                mem_addr = {tag[addr[7:2]], addr[7:2], 2'b00}; // reconstructed address from within the cache
                mem_write_data = data[addr[7:2]];
        end
        else if (read_en || write_en) begin // on a mem access instr
            if (valid[addr[7:2]] && tag[addr[7:2]] == addr[31:8]) begin // hit
                read_data = data[addr[7:2]];
            end
            else begin // miss
                stall = 1'b1;
                mem_read = 1'b1;
                mem_addr = addr;
            end
        end
    end

endmodule