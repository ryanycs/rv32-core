`include "types.svh"

// TODO: Round to nearest, ties to even
module fpu(
    input  logic [31:0] a_i,
    input  logic [31:0] b_i,
    input  fpuCtrl_e    ctrl_i,
    output logic [31:0] res_o
);

localparam NAN = 32'h7FC00000;
localparam INF = 32'h7F800000;
localparam NEG_INF = 32'hFF800000;

logic        sign_a;
logic        sign_b;
logic [7:0]  exp_a;
logic [7:0]  exp_b;
logic [23:0] mant_a;
logic [23:0] mant_b;

logic [31:0] res;
logic        res_sign;
logic [7:0]  res_exp;
logic [22:0] res_mant;

logic signed [8:0] exp_diff;
logic [23:0] mant_a_shifted;
logic [23:0] mant_b_shifted;
logic [7:0]  exp_temp;
logic [24:0] mant_temp;
logic [4:0] clz;

assign sign_a = a_i[31];
assign sign_b = b_i[31] ^ (ctrl_i == FPU_SUB);
assign exp_a  = a_i[30:23];
assign exp_b  = b_i[30:23];
assign mant_a = (exp_a == 8'h0) ? { 1'b0, a_i[22:0] } : { 1'b1, a_i[22:0] };
assign mant_b = (exp_b == 8'h0) ? { 1'b0, b_i[22:0] } : { 1'b1, b_i[22:0] };

assign exp_diff = exp_a - exp_b;

always_comb begin
    // Align
    if (exp_diff > 0) begin
        mant_a_shifted = mant_a;
        mant_b_shifted = mant_b >> exp_diff;
        exp_temp = exp_a;
    end else begin
        mant_a_shifted = mant_a >> -exp_diff;
        mant_b_shifted = mant_b;
        exp_temp = exp_b;
    end

    // Compute
    if (sign_a == sign_b) begin
        res_sign = sign_a;
        mant_temp = mant_a_shifted + mant_b_shifted;
    end else begin
        if (mant_a_shifted == mant_b_shifted) begin
            res_sign = 1'b0;
            mant_temp = 24'h0;
        end else if (mant_a_shifted > mant_b_shifted) begin
            res_sign = sign_a;
            mant_temp = mant_a_shifted - mant_b_shifted;
        end else begin
            res_sign = sign_b;
            mant_temp = mant_b_shifted - mant_a_shifted;
        end
    end

    // Normalize
    if (mant_temp[24]) begin // mant_a + mant_b overflow
        res_mant = mant_temp[23:1];
        res_exp = exp_temp + 8'd1;
    end else begin
        if (mant_temp == 25'h0 || exp_temp <= clz) begin // Zero
            res_mant = 23'h0;
            res_exp = 8'h0;
        end else begin
            res_mant = mant_temp << clz;
            res_exp = exp_temp - clz;
        end
    end
end

// clz
logic [23:0] x1, x2, x3, x4;
always_comb begin
    if (mant_temp[23 -: 16] == 16'h0) begin
        clz[4] = 1'b1; // clz += 16
        x1 = mant_temp[23:0] << 16;
    end else begin
        clz[4] = 1'b0;
        x1 = mant_temp[23:0];
    end

    if (x1[23 -: 8] == 8'h0) begin
        clz[3] = 1'b1; // clz += 8
        x2 = x1 << 8;
    end else begin
        clz[3] = 1'b0;
        x2 = x1;
    end

    if (x2[23 -: 4] == 4'h0) begin
        clz[2] = 1'b1; // clz += 4
        x3 = x2 << 4;
    end else begin
        clz[2] = 1'b0;
        x3 = x2;
    end

    if (x3[23 -: 2] == 2'h0) begin
        clz[1] = 1'b1; // clz += 2
        x4 = x3 << 2;
    end else begin
        clz[1] = 1'b0;
        x4 = x3;
    end

    if (x4[23 -: 1] == 1'b0) begin
        clz[0] = 1'b1; // clz += 1
    end else begin
        clz[0] = 1'b0;
    end
end

// res
always_comb begin
    if (ctrl_i == FPU_NOP) begin
        res = 32'h0;
    end else if (exp_a == 8'hFF || exp_b == 8'hFF) begin
        if (mant_a[22:0] || mant_b[22:0]) begin // Either a or b is NaN
            res = NAN;
        end else begin
            if (sign_a ^ sign_b) begin // inf + (-inf) or (-inf) + inf
                res = NAN;
            end else if (sign_a) begin // real/-inf + (-inf)
                res = NEG_INF;
            end else begin // real/inf + inf
                res = INF;
            end
        end
    end else begin
        res = {res_sign, res_exp, res_mant};
    end
end

assign res_o = res;

endmodule
