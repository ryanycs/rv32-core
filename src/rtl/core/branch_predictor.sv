`include "bht.sv"
`include "btb.sv"

module branch_predictor(
    input  logic        clk,
    input  logic        rst,

    input  logic [31:0] pc_i,

    // Branch signals
    input  logic        jump_i,
    input  logic        jalr_i,
    input  logic        branch_i,
    input  logic [4:0]  rd_addr_i,
    input  logic [4:0]  rs1_addr_i,
    input  logic        branch_taken_i,

    // BTB update signals
    input  logic [31:0] update_pc_i,
    input  logic [31:0] update_target_i,

    // Predict signals
    output logic        predict_taken_o,
    output logic [31:0] target_o
);

typedef enum logic [2:0] {
    BRANCH,
    RET,
    CALL,
    COROUTINE,
    JUMP
} branchType_e;

logic        bht_predict_taken;

logic        btb_update;
logic [31:0] btb_target;
branchType_e btb_branch_type;
logic        btb_hit;

branchType_e branch_type;

logic rd_is_ra, rs1_is_ra, rd_eq_rs1;
assign rd_is_ra  = (rd_addr_i  == 5'd1 || rd_addr_i == 5'd5); // ra or t0
assign rs1_is_ra = jalr_i && (rs1_addr_i == 5'd1 || rs1_addr_i == 5'd5); // ra or t0
assign rd_eq_rs1 = jalr_i && (rd_addr_i == rs1_addr_i);

// Update BTB when jump or branch is taken
assign btb_update = jump_i || (branch_i && branch_taken_i);

// branch type
always_comb begin
    if (branch_i) begin
        branch_type = BRANCH;
    end else begin
        unique casez ({ rd_is_ra, rs1_is_ra, rd_eq_rs1 })
            3'b01?: begin
                branch_type = RET;
            end
            3'b10?, 3'b111: begin
                branch_type = CALL;
            end
            3'b110: begin
                branch_type = COROUTINE;
            end
            default: begin
                branch_type = JUMP;
            end
        endcase
    end
end

// Branch History Table
bht u_bht(
    .clk            (clk),
    .rst            (rst),
    .pc_i           (pc_i),
    .update_i       (branch_i),
    .update_pc_i    (update_pc_i),
    .update_taken_i (branch_taken_i),
    .predict_taken_o(bht_predict_taken)
);

// Branch Target Buffer
btb u_btb(
    .clk            (clk),
    .rst            (rst),
    .flush          (1'b0),
    .pc_i           (pc_i),
    .update_i       (btb_update),
    .update_type_i  (branch_type),
    .update_pc_i    (update_pc_i),
    .update_target_i(update_target_i),
    .target_o       (btb_target),
    .type_o         (btb_branch_type),
    .hit_o          (btb_hit)
);


////////////////////////////////////////////////////////////////////////////////
// Output
////////////////////////////////////////////////////////////////////////////////

// Branch Prediction
always_comb begin
    if (btb_hit) begin
        if (btb_branch_type == BRANCH) begin
            predict_taken_o = bht_predict_taken;
        end else begin
            predict_taken_o = 1'b1;
        end
    end else begin
        predict_taken_o = 1'b0;
    end
end

// Target address
assign target_o = btb_target;

endmodule
