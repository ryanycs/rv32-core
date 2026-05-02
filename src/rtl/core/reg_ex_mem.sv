`include "types.svh"

module reg_ex_mem(
    input  logic        clk,
    input  logic        rst,

    input  logic        reg_wen_i,
    input  logic        mem_wen_i,
    input  lsuCtrl_e    lsu_ctrl_i,
    input  resultSrc_e  result_src_i,
    input  logic [31:0] alu_result_i,
    input  logic [31:0] pc_plus_4_i,
    input  logic [31:0] rs2_data_i,
    input  logic [4:0]  rd_addr_i,
    input  logic [31:0] csr_rdata_i,

    output logic        reg_wen_o,
    output logic        mem_wen_o,
    output lsuCtrl_e    lsu_ctrl_o,
    output resultSrc_e  result_src_o,
    output logic [31:0] alu_result_o,
    output logic [31:0] pc_plus_4_o,
    output logic [31:0] rs2_data_o,
    output logic [4:0]  rd_addr_o,
    output logic [31:0] csr_rdata_o
);

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        reg_wen_o   <= 1'b0;
        mem_wen_o   <= 1'b0;
        lsu_ctrl_o    <= LSU_NOP;
        result_src_o  <= RESULT_SRC_ALU;
        alu_result_o  <= 32'd0;
        pc_plus_4_o   <= 32'd0;
        rs2_data_o    <= 32'd0;
        rd_addr_o     <= 5'd0;
        csr_rdata_o <= 32'd0;
    end else begin
        reg_wen_o   <= reg_wen_i;
        mem_wen_o   <= mem_wen_i;
        lsu_ctrl_o    <= lsu_ctrl_i;
        result_src_o  <= result_src_i;
        alu_result_o  <= alu_result_i;
        pc_plus_4_o   <= pc_plus_4_i;
        rs2_data_o    <= rs2_data_i;
        rd_addr_o     <= rd_addr_i;
        csr_rdata_o <= csr_rdata_i;
    end
end

endmodule
