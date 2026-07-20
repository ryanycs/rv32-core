`include "types.svh"

module alu(
    input  logic     [31:0] a_i,
    input  logic     [31:0] b_i,
    input  aluCtrl_e        ctrl_i,
    output logic     [31:0] res_o
);

logic        sign_a;
logic        sign_b;
logic [63:0] mul_res;

assign sign_a = (ctrl_i == ALU_MULH || ctrl_i == ALU_MULHSU) ? a_i[31] : 1'b0;
assign sign_b = (ctrl_i == ALU_MULH) ? b_i[31] : 1'b0;
assign mul_res = { {32{sign_a}}, a_i } * { {32{sign_b}}, b_i };

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

        ALU_MUL: begin
            res_o = mul_res[31:0];
        end

        ALU_MULH: begin
            res_o = mul_res[63:32];
        end

        ALU_MULHSU: begin
            res_o = mul_res[63:32];
        end

        ALU_MULHU: begin
            res_o = mul_res[63:32];
        end

        default: begin
            res_o = 32'd0;
        end
    endcase
end

endmodule
