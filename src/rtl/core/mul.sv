// mul.sv

module mul(
    input  logic [31:0] a_i,
    input  logic [31:0] b_i,
    input  aluCtrl_e    ctrl_i,
    output logic [31:0] res_o
);

logic sign_a;
logic sign_b;
logic [65:0] mul_res;

assign sign_a = (ctrl_i == ALU_MULH || ctrl_i == ALU_MULHSU)
                ? a_i[31] : 1'b0;
assign sign_b = (ctrl_i == ALU_MULH)
                ? b_i[31] : 1'b0;

assign mul_res = $signed({sign_a, a_i}) * $signed({sign_b, b_i});

always_comb begin
    case (ctrl_i)
        ALU_MUL:    res_o = mul_res[31: 0];
        ALU_MULH:   res_o = mul_res[63:32];
        ALU_MULHSU: res_o = mul_res[63:32];
        ALU_MULHU:  res_o = mul_res[63:32];
        default:    res_o = mul_res[31: 0];
    endcase
end

endmodule
