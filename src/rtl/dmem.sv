module dmem(
    input  logic        clk,
    input  logic        rst,
    input  logic        wen,  // 0: read, 1: write
    input  logic [31:0] bwe,  // Set 1'b1 for which bits to write
    input  logic [31:0] addr,
    input  logic [31:0] wdata,
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

always @(posedge clk) begin
    if (wen) begin
        mem[row_addr][col_addr] <= wdata & bwe
                                   | mem[row_addr][col_addr] & ~bwe;
    end
end

endmodule
