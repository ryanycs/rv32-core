`include "types.svh"

module reg_id_ex(
    input  logic        clk,
    input  logic        rst,
    input  logic        flush,

    input  logic        rf_wen_i,
    input  logic        fp_rf_wen_i,
    input  rfSel_e      rs1_sel_i,
    input  rfSel_e      rs2_sel_i,
    input  logic        mem_ceb_i,
    input  logic        mem_wen_i,
    input  logic        jump_i,
    input  logic        jalr_i,
    input  logic        branch_i,
    input  branchCtrl_e branch_ctrl_i,
    input  aluCtrl_e    alu_ctrl_i,
    input  aluSrc1_e    alu_src1_i,
    input  aluSrc2_e    alu_src2_i,
    input  fpuCtrl_e    fpu_ctrl_i,
    input  lsuCtrl_e    lsu_ctrl_i,
    input  resultSrc_e  result_src_i,
    input  logic [31:0] pc_i,
    input  logic [31:0] pc_plus_4_i,
    input  logic [31:0] rs1_data_i,
    input  logic [31:0] rs2_data_i,
    input  logic [31:0] imm_i,
    input  logic [4:0]  rs1_addr_i,
    input  logic [4:0]  rs2_addr_i,
    input  logic [4:0]  rd_addr_i,
    input  logic        csr_instret_inc_i,
    input  logic [11:0] csr_addr_i,
    input  logic        predict_taken_i,
    input  logic [31:0] predict_addr_i,

    output logic        rf_wen_o,
    output logic        fp_rf_wen_o,
    output rfSel_e      rs1_sel_o,
    output rfSel_e      rs2_sel_o,
    output logic        mem_ceb_o,
    output logic        mem_wen_o,
    output logic        jump_o,
    output logic        jalr_o,
    output logic        branch_o,
    output branchCtrl_e branch_ctrl_o,
    output aluCtrl_e    alu_ctrl_o,
    output aluSrc1_e    alu_src1_o,
    output aluSrc2_e    alu_src2_o,
    output fpuCtrl_e    fpu_ctrl_o,
    output lsuCtrl_e    lsu_ctrl_o,
    output resultSrc_e  result_src_o,
    output logic [31:0] pc_o,
    output logic [31:0] pc_plus_4_o,
    output logic [31:0] rs1_data_o,
    output logic [31:0] rs2_data_o,
    output logic [31:0] imm_o,
    output logic [4:0]  rs1_addr_o,
    output logic [4:0]  rs2_addr_o,
    output logic [4:0]  rd_addr_o,
    output logic        csr_instret_inc_o,
    output logic [11:0] csr_addr_o,
    output logic        predict_taken_o,
    output logic [31:0] predict_addr_o
);

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        rf_wen_o          <= 1'b0;
        fp_rf_wen_o       <= 1'b0;
        rs1_sel_o         <= RF_SEL_INT;
        rs2_sel_o         <= RF_SEL_INT;
        mem_ceb_o         <= 1'b0;
        mem_wen_o         <= 1'b0;
        jump_o            <= 1'b0;
        jalr_o            <= 1'b0;
        branch_o          <= 1'b0;
        branch_ctrl_o     <= BRANCH_NOP;
        alu_ctrl_o        <= ALU_NOP;
        alu_src1_o        <= ALU_SRC1_RS1;
        alu_src2_o        <= ALU_SRC2_RS2;
        fpu_ctrl_o        <= FPU_NOP;
        lsu_ctrl_o        <= LSU_NOP;
        result_src_o      <= RESULT_SRC_ALU;
        pc_o              <= 32'd0;
        pc_plus_4_o       <= 32'd0;
        rs1_data_o        <= 32'd0;
        rs2_data_o        <= 32'd0;
        imm_o             <= 32'd0;
        rs1_addr_o        <= 5'd0;
        rs2_addr_o        <= 5'd0;
        rd_addr_o         <= 5'd0;
        csr_instret_inc_o <= 1'b0;
        csr_addr_o        <= 32'd0;
        predict_taken_o   <= 1'b0;
        predict_addr_o    <= 32'd0;
    end else if (flush) begin
        rf_wen_o          <= 1'b0;
        fp_rf_wen_o       <= 1'b0;
        rs1_sel_o         <= RF_SEL_INT;
        rs2_sel_o         <= RF_SEL_INT;
        mem_ceb_o         <= 1'b0;
        mem_wen_o         <= 1'b0;
        jump_o            <= 1'b0;
        jalr_o            <= 1'b0;
        branch_o          <= 1'b0;
        branch_ctrl_o     <= BRANCH_NOP;
        alu_ctrl_o        <= ALU_NOP;
        alu_src1_o        <= ALU_SRC1_RS1;
        alu_src2_o        <= ALU_SRC2_RS2;
        fpu_ctrl_o        <= FPU_NOP;
        lsu_ctrl_o        <= LSU_NOP;
        result_src_o      <= RESULT_SRC_ALU;
        pc_o              <= 32'd0;
        pc_plus_4_o       <= 32'd0;
        rs1_data_o        <= 32'd0;
        rs2_data_o        <= 32'd0;
        imm_o             <= 32'd0;
        rs1_addr_o        <= 5'd0;
        rs2_addr_o        <= 5'd0;
        rd_addr_o         <= 5'd0;
        csr_instret_inc_o <= 1'b0;
        csr_addr_o        <= 32'd0;
        predict_taken_o   <= 1'b0;
        predict_addr_o    <= 32'd0;
    end else begin
        rf_wen_o          <= rf_wen_i;
        fp_rf_wen_o       <= fp_rf_wen_i;
        rs1_sel_o         <= rs1_sel_i;
        rs2_sel_o         <= rs2_sel_i;
        mem_ceb_o         <= mem_ceb_i;
        mem_wen_o         <= mem_wen_i;
        jump_o            <= jump_i;
        jalr_o            <= jalr_i;
        branch_o          <= branch_i;
        branch_ctrl_o     <= branch_ctrl_i;
        alu_ctrl_o        <= alu_ctrl_i;
        alu_src1_o        <= alu_src1_i;
        alu_src2_o        <= alu_src2_i;
        fpu_ctrl_o        <= fpu_ctrl_i;
        lsu_ctrl_o        <= lsu_ctrl_i;
        result_src_o      <= result_src_i;
        pc_o              <= pc_i;
        pc_plus_4_o       <= pc_plus_4_i;
        rs1_data_o        <= rs1_data_i;
        rs2_data_o        <= rs2_data_i;
        imm_o             <= imm_i;
        rs1_addr_o        <= rs1_addr_i;
        rs2_addr_o        <= rs2_addr_i;
        rd_addr_o         <= rd_addr_i;
        csr_instret_inc_o <= csr_instret_inc_i;
        csr_addr_o        <= csr_addr_i;
        predict_taken_o   <= predict_taken_i;
        predict_addr_o    <= predict_addr_i;
    end
end

endmodule
