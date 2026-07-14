// Hazard detection unit to detect load use hazards and insert stalls

module hazard_detection_unit (
    input logic id_ex_MemRead,
    input logic [4:0] id_ex_rd, if_id_rs1, if_id_rs2,
    output logic stall, flush_id_ex // stall goes to both PC and IF/ID reg to freeze them. flush goes to ID/EX reg to zero the control signal and insert a nop
);

    always_comb begin
        stall = 0;
        flush_id_ex = 0;
        if (id_ex_MemRead && (id_ex_rd == if_id_rs1 || id_ex_rd == if_id_rs2)) begin
            stall = 1;
            flush_id_ex = 1;
        end
    end

endmodule
