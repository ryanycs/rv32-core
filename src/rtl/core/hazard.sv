`include "types.svh"

module hazard(
    input logic       [4:0] id_rs1_addr_i,
    input logic       [4:0] id_rs2_addr_i,
    input logic       [4:0] ex_rd_addr_i,
    input resultSrc_e       ex_result_src_i,
    input pcSrc_e           pc_sel_i,

    output logic            stall_pc_o,
    output logic            stall_if_id_o,
    output logic            flush_if_id_o,
    output logic            flush_id_ex_o
);

logic lw_stall;

// Load hazard
assign lw_stall    = (ex_result_src_i == RESULT_SRC_MEM)
                     && ( (id_rs1_addr_i == ex_rd_addr_i) || (id_rs2_addr_i == ex_rd_addr_i) );
assign stall_pc_o    = lw_stall;
assign stall_if_id_o = lw_stall;

// Branch taken or load introduces a bubble
assign flush_if_id_o = (pc_sel_i == PC_SRC_ALU_RESULT);
assign flush_id_ex_o = lw_stall || (pc_sel_i == PC_SRC_ALU_RESULT);

endmodule
