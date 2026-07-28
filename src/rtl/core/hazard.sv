`include "types.svh"

module hazard(
    input  logic [4:0]  id_rs1_addr_i,
    input  logic [4:0]  id_rs2_addr_i,
    input  logic [4:0]  ex_rd_addr_i,
    input  resultSrc_e  ex_result_src_i,
    input  logic        branch_i,
    input  logic        jump_i,
    input  logic        branch_taken_i,
    input  logic [31:0] alu_result_i,
    input  logic        predict_taken_i,
    input  logic [31:0] predict_addr_i,

    output logic        jump_mispredict_o,

    output logic        stall_pc_o,
    output logic        stall_if_id_o,
    output logic        flush_if_id_o,
    output logic        flush_id_ex_o
);

logic lw_stall;
logic branch_mispredict;
logic jump_mispredict;

// Branch misprediction
assign branch_mispredict = branch_i && (branch_taken_i ^ predict_taken_i);
assign jump_mispredict = jump_i && (!predict_taken_i || (predict_addr_i != alu_result_i));

// Load hazard
assign lw_stall    = (ex_result_src_i == RESULT_SRC_MEM)
                     && ( (id_rs1_addr_i == ex_rd_addr_i) || (id_rs2_addr_i == ex_rd_addr_i) );

assign jump_mispredict_o = jump_mispredict;

assign stall_pc_o    = lw_stall;
assign stall_if_id_o = lw_stall;

assign flush_if_id_o = branch_mispredict || jump_mispredict;
assign flush_id_ex_o = lw_stall || branch_mispredict || jump_mispredict;

endmodule
