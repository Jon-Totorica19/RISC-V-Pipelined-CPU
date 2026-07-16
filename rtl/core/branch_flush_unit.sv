// branch flush for instructions fetched before the branch decision

module branch_flush_unit (
    input logic id_ex_Branch, branch_taken, id_ex_Jump, id_ex_predicted_taken,
    output logic flush
);

    always_comb begin
        flush = 0;
        // Fire on mispredictions for branches, and jumps
        if ((id_ex_Branch && (branch_taken ^ id_ex_predicted_taken)) || id_ex_Jump) begin
            flush = 1;
        end
    end

endmodule
