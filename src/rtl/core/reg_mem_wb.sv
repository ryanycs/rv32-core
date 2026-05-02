`include "types.svh"

module reg_mem_wb(
    input  logic        clk,
    input  logic        rst,

    input  logic        reg_wen_i,
    input  resultSrc_e  result_src_i,
    input  logic [31:0] alu_result_i,
    input  logic [31:0] mem_rdata_i,
    input  logic [4:0]  rd_addr_i,
    input  logic [31:0] pc_plus_4_i,
    input  logic [31:0] csr_rdata_i,

    output logic        reg_wen_o,
    output resultSrc_e  result_src_o,
    output logic [31:0] alu_result_o,
    output logic [31:0] mem_rdata_o,
    output logic [4:0]  rd_addr_o,
    output logic [31:0] pc_plus_4_o,
    output logic [31:0] csr_rdata_o
);

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        reg_wen_o    <= 1'b0;
        result_src_o   <= RESULT_SRC_ALU;
        alu_result_o   <= 32'd0;
        mem_rdata_o  <= 32'd0;
        rd_addr_o      <= 5'd0;
        pc_plus_4_o    <= 32'd0;
        csr_rdata_o  <= 32'd0;
    end else begin
        reg_wen_o    <= reg_wen_i;
        result_src_o   <= result_src_i;
        alu_result_o   <= alu_result_i;
        mem_rdata_o  <= mem_rdata_i;
        rd_addr_o      <= rd_addr_i;
        pc_plus_4_o    <= pc_plus_4_i;
        csr_rdata_o  <= csr_rdata_i;
    end
end

endmodule
