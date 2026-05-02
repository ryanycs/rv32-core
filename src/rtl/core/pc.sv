`include "define.svh"
`include "types.svh"

module pc(
    input  logic        clk,
    input  logic        rst,
    input  logic        stall,

    input  logic [31:0] pc_i,
    output logic [31:0] pc_o
);

logic [31:0] pc_reg;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        pc_reg <= PC_START_ADDR;
    end else if (!stall) begin
        pc_reg <= pc_i;
    end
end

assign pc_o = pc_reg;

endmodule
