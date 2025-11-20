`include "types.svh"

module pc_mux(
    input  logic [31:0]  alu_result,
    input  logic [31:0]  pc_plus_4,
    input  pcSrc_e       pc_sel,
    output logic [31:0]  pc_out
);

always_comb begin
    if (pc_sel == PC_SRC_ALU_RESULT) begin
        pc_out = alu_result & 32'hFFFFFFFE; // Ensure LSB is 0
    end else begin
        pc_out = pc_plus_4;
    end
end

endmodule
