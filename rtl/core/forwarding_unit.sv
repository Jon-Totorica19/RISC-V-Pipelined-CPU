// Forwarding unit to reduce stalls between data hazards

module forwarding_unit (
    input logic ex_mem_RegWrite, mem_wb_RegWrite,
    input logic [4:0] ex_mem_rd, mem_wb_rd, id_ex_rs1, id_ex_rs2,
    output logic [1:0] forward_a, forward_b // MUX Select signals for MUX feeding into MUX ALU inputs A and B
    // 00: use reg file value (id_ex_rd1/rd2), 01: forward from MEM/WB, 10: forward from EX/MEM
);

    always_comb begin
        // Defaults to avoid latch
        forward_a = 2'b00;
        forward_b = 2'b00;

        // Forward path to rs1 from EX/MEM
        if (ex_mem_RegWrite && ex_mem_rd != 0 && ex_mem_rd == id_ex_rs1) begin
            forward_a = 2'b10;
        end
        // Forward path to rs1 from MEM/WB
        else if (mem_wb_RegWrite && mem_wb_rd != 0 && mem_wb_rd == id_ex_rs1) begin
            forward_a = 2'b01;
        end 

        // Forward path to rs2 from EX/MEM
        if (ex_mem_RegWrite && ex_mem_rd != 0 && ex_mem_rd == id_ex_rs2) begin
            forward_b = 2'b10;
        end
        // Forward path to rs2 from MEM/WB
        else if (mem_wb_RegWrite && mem_wb_rd != 0 && mem_wb_rd == id_ex_rs2) begin
            forward_b = 2'b01;
        end 
    end

endmodule
