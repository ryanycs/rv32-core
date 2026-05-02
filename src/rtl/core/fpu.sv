`include "types.svh"

module fpu(
    input  logic  clk,
    input  logic  rst,

    input  logic [31:0] a_i,
    input  logic [31:0] b_i,
    input  logic [2:0]  ctrl_i,
    output logic [31:0] res_o
);

endmodule
