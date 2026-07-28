module reg_if_id(
    input  logic        clk,
    input  logic        rst,
    input  logic        stall,
    input  logic        flush,

    input  logic [31:0] pc_i,
    input  logic [31:0] pc_plus_4_i,
    input  logic        predict_taken_i,
    input  logic [31:0] predict_addr_i,

    output logic [31:0] pc_o,
    output logic [31:0] pc_plus_4_o,
    output logic        predict_taken_o,
    output logic [31:0] predict_addr_o
);

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        pc_o            <= 32'd0;
        pc_plus_4_o     <= 32'd0;
        predict_taken_o <= 1'b0;
        predict_addr_o  <= 32'd0;
    end else if (flush) begin
        pc_o            <= 32'd0;
        pc_plus_4_o     <= 32'd0;
        predict_taken_o <= 1'b0;
        predict_addr_o  <= 32'd0;
    end else if (!stall) begin
        pc_o            <= pc_i;
        pc_plus_4_o     <= pc_plus_4_i;
        predict_taken_o <= predict_taken_i;
        predict_addr_o  <= predict_addr_i;
    end
end

endmodule
