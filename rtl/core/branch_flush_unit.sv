// branch flush for instructions fetched before the branch decision

module branch_flush_unit (
    input logic id_ex_Branch, branch_taken, id_ex_Jump,
    output logic flush
);

    always_comb begin
        flush = 0;
        if ((id_ex_Branch && branch_taken) || id_ex_Jump) begin
            flush = 1;
        end
    end

endmodule
