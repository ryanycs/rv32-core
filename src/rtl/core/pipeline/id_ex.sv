`include "types.svh"

module id_ex(
    input  logic  clk,
    input  logic  rst,
    input  logic  clear,

    // Control signals
    input  logic         reg_wr_en_in,
    input  logic         mem_wr_en_in,
    input  logic         jump_in,
    input  logic         branch_in,
    input  branchCtrl_e  branch_ctrl_in,
    input  aluCtrl_e     alu_ctrl_in,
    input  aluSrc1_e     alu_src1_in,
    input  aluSrc2_e     alu_src2_in,
    input  lsuCtrl_e     lsu_ctrl_in,
    input  resultSrc_e   result_src_in,

    // Data signals
    input  logic [31:0]  pc_in,
    input  logic [31:0]  pc_plus_4_in,
    input  logic [31:0]  rs1_data_in,
    input  logic [31:0]  rs2_data_in,
    input  logic [31:0]  imm_in,
    input  logic [4:0]   rs1_in,
    input  logic [4:0]   rs2_in,
    input  logic [4:0]   rd_in,

    output logic         reg_wr_en_out,
    output logic         mem_wr_en_out,
    output logic         jump_out,
    output logic         branch_out,
    output branchCtrl_e  branch_ctrl_out,
    output aluCtrl_e     alu_ctrl_out,
    output aluSrc1_e     alu_src1_out,
    output aluSrc2_e     alu_src2_out,
    output lsuCtrl_e     lsu_ctrl_out,
    output resultSrc_e   result_src_out,

    output logic [31:0]  pc_out,
    output logic [31:0]  pc_plus_4_out,
    output logic [31:0]  rs1_data_out,
    output logic [31:0]  rs2_data_out,
    output logic [31:0]  imm_out,
    output logic [4:0]   rs1_out,
    output logic [4:0]   rs2_out,
    output logic [4:0]   rd_out

    `ifdef Zicsr_EXT
    ,
    input  logic         csr_instret_inc_in,
    input  logic [11:0]  csr_addr_in,
    output logic         csr_instret_inc_out,
    output logic [11:0]  csr_addr_out
    `endif

    `ifdef DEBUG
    ,
    input  opcodeType_e  opcode_type_in,
    output opcodeType_e  opcode_type_out
    `endif
);

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        reg_wr_en_out   <= 1'b0;
        mem_wr_en_out   <= 1'b0;
        jump_out        <= 1'b0;
        branch_out      <= 1'b0;
        branch_ctrl_out <= BRANCH_NOP;
        alu_ctrl_out    <= ALU_NOP;
        alu_src1_out    <= ALU_SRC1_RS1;
        alu_src2_out    <= ALU_SRC2_RS2;
        lsu_ctrl_out    <= LSU_NOP;
        result_src_out  <= RESULT_SRC_ALU;

        pc_out          <= 32'd0;
        pc_plus_4_out   <= 32'd0;
        rs1_data_out    <= 32'd0;
        rs2_data_out    <= 32'd0;
        imm_out         <= 32'd0;
        rs1_out         <= 5'd0;
        rs2_out         <= 5'd0;
        rd_out          <= 5'd0;
    end else if (clear) begin
        reg_wr_en_out   <= 1'b0;
        mem_wr_en_out   <= 1'b0;
        jump_out        <= 1'b0;
        branch_out      <= 1'b0;
        branch_ctrl_out <= BRANCH_NOP;
        alu_ctrl_out    <= ALU_NOP;
        alu_src1_out    <= ALU_SRC1_RS1;
        alu_src2_out    <= ALU_SRC2_RS2;
        lsu_ctrl_out    <= LSU_NOP;
        result_src_out  <= RESULT_SRC_ALU;

        pc_out          <= 32'd0;
        pc_plus_4_out   <= 32'd0;
        rs1_data_out    <= 32'd0;
        rs2_data_out    <= 32'd0;
        imm_out         <= 32'd0;
        rs1_out         <= 5'd0;
        rs2_out         <= 5'd0;
        rd_out          <= 5'd0;
    end else begin
        reg_wr_en_out   <= reg_wr_en_in;
        mem_wr_en_out   <= mem_wr_en_in;
        jump_out        <= jump_in;
        branch_out      <= branch_in;
        branch_ctrl_out <= branch_ctrl_in;
        alu_ctrl_out    <= alu_ctrl_in;
        alu_src1_out    <= alu_src1_in;
        alu_src2_out    <= alu_src2_in;
        lsu_ctrl_out    <= lsu_ctrl_in;
        result_src_out  <= result_src_in;

        pc_out          <= pc_in;
        pc_plus_4_out   <= pc_plus_4_in;
        rs1_data_out    <= rs1_data_in;
        rs2_data_out    <= rs2_data_in;
        imm_out         <= imm_in;
        rs1_out         <= rs1_in;
        rs2_out         <= rs2_in;
        rd_out          <= rd_in;
    end
end

`ifdef Zicsr_EXT
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        csr_instret_inc_out <= 1'b0;
        csr_addr_out        <= 32'd0;
    end else if (clear) begin
        csr_instret_inc_out <= 1'b0;
        csr_addr_out        <= 32'd0;
    end else begin
        csr_instret_inc_out <= csr_instret_inc_in;
        csr_addr_out        <= csr_addr_in;
    end
end
`endif

////////////////////////////////////////////////////////////////////////////////
// DEBUG
////////////////////////////////////////////////////////////////////////////////

`ifdef DEBUG
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        opcode_type_out <= NOP;
    end else if (clear) begin
        opcode_type_out <= NOP;
    end else begin
        opcode_type_out <= opcode_type_in;
    end
end
`endif

endmodule
