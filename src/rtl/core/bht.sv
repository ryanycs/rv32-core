// Branch History Table (BHT)

module bht #(
    parameter SIZE = 256
)(
    input  logic clk,
    input  logic rst,

    input  logic [31:0] pc_i,

    input  logic        update_i,
    input  logic        update_taken_i,
    input  logic [31:0] update_pc_i,

    output logic predict_taken_o
);

localparam INDEX_WIDTH = $clog2(SIZE);

logic [1:0] bht [SIZE-1:0];
logic [INDEX_WIDTH-1:0] index, update_index;

// The last 2 bits is always 0, so we start from bit 2 for indexing
assign index = pc_i[2 +: INDEX_WIDTH];
assign update_index = update_pc_i[2 +: INDEX_WIDTH];

assign predict_taken_o = bht[index][1];

// bht
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        for (int i = 0; i < SIZE; i++) begin
            bht[i] <= 2'b00;
        end
    end else begin
        if (update_i) begin
            case (bht[update_index])
                2'b00: bht[update_index] <= update_taken_i ? 2'b01 : 2'b00;
                2'b01: bht[update_index] <= update_taken_i ? 2'b10 : 2'b00;
                2'b10: bht[update_index] <= update_taken_i ? 2'b11 : 2'b01;
                2'b11: bht[update_index] <= update_taken_i ? 2'b11 : 2'b10;
            endcase
        end
    end
end

endmodule
