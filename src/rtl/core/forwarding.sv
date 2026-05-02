`include "types.svh"

module forwarding(
    input  logic [4:0] rs1_addr_ex_i,
    input  logic [4:0] rs2_addr_ex_i,
    input  logic [4:0] rd_addr_mem_i,
    input  logic [4:0] rd_addr_wb_i,
    input  logic       reg_wen_mem_i,
    input  logic       reg_wen_wb_i,

    output forwardCtrl_e forward_a_o,
    output forwardCtrl_e forward_b_o
);

// forward_a
always_comb begin
    if ( (rs1_addr_ex_i == rd_addr_mem_i && reg_wen_mem_i) && rs1_addr_ex_i != 5'd0) begin
        // Forward from MEM stage
        forward_a_o = FORWARD_FROM_MEM;
    end else if ( (rs1_addr_ex_i == rd_addr_wb_i && reg_wen_wb_i) && rs1_addr_ex_i != 5'd0) begin
        // Forward from WB stage
        forward_a_o = FORWARD_FROM_WB;
    end else begin
        // No forwarding
        forward_a_o = FORWARD_NONE;
    end
end

// forward_b
always_comb begin
    if ( (rs2_addr_ex_i == rd_addr_mem_i && reg_wen_mem_i) && rs2_addr_ex_i != 5'd0) begin
        // Forward from MEM stage
        forward_b_o = FORWARD_FROM_MEM;
    end else if ( (rs2_addr_ex_i == rd_addr_wb_i && reg_wen_wb_i) && rs2_addr_ex_i != 5'd0) begin
        // Forward from WB stage
        forward_b_o = FORWARD_FROM_WB;
    end else begin
        // No forwarding
        forward_b_o = FORWARD_NONE;
    end
end

endmodule
