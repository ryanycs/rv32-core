`include "types.svh"

module mem_wb(
    input  logic clk,
    input  logic rst,

    input  logic         reg_wr_en_in,
    input  resultSrc_e   result_src_in,
    input  logic [31:0]  alu_result_in,
    input  logic [31:0]  mem_rd_data_in,
    input  logic [4:0]   rd_in,
    input  logic [31:0]  pc_plus_4_in,

    output logic         reg_wr_en_out,
    output resultSrc_e   result_src_out,
    output logic [31:0]  alu_result_out,
    output logic [31:0]  mem_rd_data_out,
    output logic [4:0]   rd_out,
    output logic [31:0]  pc_plus_4_out

    `ifdef Zicsr_EXT
    ,
    input  logic [31:0]  csr_rd_data_in,
    output logic [31:0]  csr_rd_data_out
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
        result_src_out  <= RESULT_SRC_ALU;
        alu_result_out  <= 32'd0;
        mem_rd_data_out <= 32'd0;
        rd_out          <= 5'd0;
        pc_plus_4_out   <= 32'd0;
    end else begin
        reg_wr_en_out   <= reg_wr_en_in;
        result_src_out  <= result_src_in;
        alu_result_out  <= alu_result_in;
        mem_rd_data_out <= mem_rd_data_in;
        rd_out          <= rd_in;
        pc_plus_4_out   <= pc_plus_4_in;
    end
end

`ifdef Zicsr_EXT
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        csr_rd_data_out     <= 32'd0;
    end else begin
        csr_rd_data_out     <= csr_rd_data_in;
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
    end else begin
        opcode_type_out <= opcode_type_in;
    end
end
`endif

endmodule
