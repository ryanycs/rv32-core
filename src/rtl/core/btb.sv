// Branch Target Buffer (BTB)

module btb #(
    parameter BTB_SIZE = 8,
    parameter BTB_INDEX_WIDTH = $clog2(BTB_SIZE)
)(
    input  logic        clk,
    input  logic        rst,
    input  logic        flush,

    input  logic [31:0] pc_i,

    input  logic        update_i,
    input  logic [31:0] update_pc_i,
    input  logic [31:0] update_target_i,

    output logic [31:0] target_o,
    output logic        hit_o
);

localparam TAG_WIDTH = 32 - BTB_INDEX_WIDTH - 2;
localparam ENTRY_WIDTH = 1 + TAG_WIDTH + 32; // valid bit + tag + target address

// btb entry format:
// ┌─┬───────┬──────────────────┐
// │V│  tag  │  target address  │
// └─┴───────┴──────────────────┘
logic [ENTRY_WIDTH-1:0] btb [BTB_SIZE-1:0];

logic [BTB_INDEX_WIDTH-1:0] index, update_index;
logic [TAG_WIDTH-1:0] tag, update_tag;

assign index = pc_i[2 +: BTB_INDEX_WIDTH];
assign tag = pc_i[31 -: TAG_WIDTH];

assign update_index = update_pc_i[2 +: BTB_INDEX_WIDTH];
assign update_tag = update_pc_i[31 -: TAG_WIDTH];

// btb
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        for (int i = 0; i < BTB_SIZE; i++) begin
            btb[i] <= {ENTRY_WIDTH{1'b0}};
        end
    end else if (flush) begin
        for (int i = 0; i < BTB_SIZE; i++) begin
            btb[i][32] <= 1'b0;
        end
    end else begin
        if (update_i) begin
            btb[update_index] <= {1'b1, update_tag, update_target_i};
        end
    end
end

assign target_o = btb[index][31:0];
assign hit_o    = btb[index][ENTRY_WIDTH-1] & (btb[index][32 +: TAG_WIDTH] == tag);

endmodule
