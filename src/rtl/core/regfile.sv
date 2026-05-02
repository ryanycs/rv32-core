`include "define.svh"
`include "types.svh"

module regfile(
    input  logic  clk,
    input  logic  rst,

    input  logic [4:0]   rs1_addr_i,
    input  logic [4:0]   rs2_addr_i,
    output logic [31:0]  rs1_data_o,
    output logic [31:0]  rs2_data_o,

    input  logic         wen_i,
    input  logic [4:0]   waddr_i,
    input  logic [31:0]  wdata_i
);

logic [31:0] reg_file [31:1];

// rs1_data_o
always_comb begin
    if (rs1_addr_i == 5'd0) begin
        rs1_data_o = 32'd0;
    end else begin
        rs1_data_o = (rs1_addr_i == waddr_i && wen_i) ? wdata_i : reg_file[rs1_addr_i];
    end
end

// rs2_data_o
always_comb begin
    if (rs2_addr_i == 5'd0) begin
        rs2_data_o = 32'd0;
    end else begin
        rs2_data_o = (rs2_addr_i == waddr_i && wen_i) ? wdata_i : reg_file[rs2_addr_i];
    end
end

// Write to register file
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        for (int i = 1; i < 32; i = i + 1) begin
            reg_file[i] <= 32'd0;
        end
        reg_file[2] <= SP_START_ADDR;
    end else if (wen_i) begin
        reg_file[waddr_i] <= wdata_i;
    end
end

endmodule
