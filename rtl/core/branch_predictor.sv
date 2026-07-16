// Branch Predictor Unit (Branch History Table). Branch decision is made in EX, while the prediction is made in ID. No BTB is needed since the branch target calculation happens in the same stage as the prediction, ID.
// 00: Strongly Not Taken
// 01: Weakly Not Taken
// 10: Weakly Taken
// 11: Strongly Taken

module branch_predictor (
    input clk, rst,
    input logic [31:0] pc_id, // index BHT for prediction
    input logic [31:0] pc_ex, // index pc for update
    input logic is_branch_id, is_branch_ex, // is instr in ID/EX a branch
    input logic branch_taken, // actual outcome from EX
    output logic predict_taken // prediction result
);

    // BHT to hold predictions
    logic [1:0] bht [15:0];

    // Prediction in ID
    always_comb begin
        predict_taken = 1'b0;
        if (is_branch_id) begin
            predict_taken = bht[pc_id[5:2]][1];
        end
    end

    // Update BHT in EX
    always_ff @(posedge clk) begin
        if (rst) begin
            for (int i = 0; i < 16; i++) 
            bht[i] <= 2'b01; // Reset to weakly not taken
        end
        else if (is_branch_ex) begin
            if (branch_taken) begin
                if (bht[pc_ex[5:2]] != 2'b11) 
                    bht[pc_ex[5:2]] <= bht[pc_ex[5:2]] + 1'b1;
            end
            else begin
                if (bht[pc_ex[5:2]] != 2'b00)
                    bht[pc_ex[5:2]] <= bht[pc_ex[5:2]] - 1'b1;
            end
        end
    end



endmodule
