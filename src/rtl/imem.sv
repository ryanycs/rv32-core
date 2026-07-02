`include "define.svh"

module imem(
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] addr,
    output logic [31:0] rdata
);

logic [31:0] mem [511:0][31:0];

logic [8:0] row_addr;
logic [4:0] col_addr;

assign row_addr = (addr >> 2) / 32;
assign col_addr = (addr >> 2) % 32;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        rdata <= 32'd0;
    end else begin
        rdata <= mem[row_addr][col_addr];
    end
end

endmodule
