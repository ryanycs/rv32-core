`include "core/core.sv"
`include "imem.sv"
`include "dmem.sv"

module top(
    input logic clk,
    input logic rst
);

logic [31:0] imem_addr;
logic [31:0] imem_rdata;
logic [31:0] dmem_addr;
logic [31:0] dmem_wdata;
logic        dmem_wen;
logic [31:0] dmem_bwe;
logic [31:0] dmem_rdata;

core u_core(
    .clk       (clk),
    .rst       (rst),
    .imem_addr (imem_addr),
    .imem_rdata(imem_rdata),
    .dmem_wen  (dmem_wen),
    .dmem_bwe  (dmem_bwe),
    .dmem_addr (dmem_addr),
    .dmem_wdata(dmem_wdata),
    .dmem_rdata(dmem_rdata)
);

imem u_imem(
    .clk  (clk),
    .rst  (rst),
    .addr (imem_addr),
    .rdata(imem_rdata)
);

dmem u_dmem(
    .clk  (clk),
    .rst  (rst),
    .wen  (dmem_wen),
    .bwe  (dmem_bwe),
    .addr (dmem_addr),
    .wdata(dmem_wdata),
    .rdata(dmem_rdata)
);

endmodule
