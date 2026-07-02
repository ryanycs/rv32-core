module reg_if_id(
    input  logic        clk,
    input  logic        rst,
    input  logic        stall,
    input  logic        flush,

    input  logic [31:0] pc_i,
    input  logic [31:0] pc_plus_4_i,

    output logic [31:0] pc_o,
    output logic [31:0] pc_plus_4_o
);

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        pc_o        <= 32'd0;
        pc_plus_4_o <= 32'd0;
    end else if (flush) begin
        pc_o        <= 32'd0;
        pc_plus_4_o <= 32'd0;
    end else if (!stall) begin
        pc_o        <= pc_i;
        pc_plus_4_o <= pc_plus_4_i;
    end
end

endmodule
