`include "types.svh"

module alu(
    input  logic     [31:0] a_i,
    input  logic     [31:0] b_i,
    input  aluCtrl_e        ctrl_i,
    output logic     [31:0] res_o
);

always_comb begin
    case (ctrl_i)
        ALU_ADD: begin
            res_o = a_i + b_i;
        end

        ALU_SUB: begin
            res_o = a_i - b_i;
        end

        ALU_AND: begin
            res_o = a_i & b_i;
        end

        ALU_OR: begin
            res_o = a_i | b_i;
        end

        ALU_XOR: begin
            res_o = a_i ^ b_i;
        end

        ALU_SLL: begin
            res_o = a_i << b_i[4:0];
        end

        ALU_SRL: begin
            res_o = a_i >> b_i[4:0];
        end

        ALU_SRA: begin
            res_o = $signed(a_i) >>> b_i[4:0];
        end

        ALU_SLT: begin
            res_o = $signed(a_i) < $signed(b_i) ? 32'd1 : 32'd0;
        end

        ALU_SLTU: begin
            res_o = a_i < b_i ? 32'd1 : 32'd0;
        end

        ALU_LUI: begin
            res_o = b_i;
        end

        default: begin
            res_o = 32'd0;
        end
    endcase
end

endmodule
