`include "types.svh"

module fpu(
    input  logic [31:0] a_i,
    input  logic [31:0] b_i,
    input  fpuCtrl_e    ctrl_i,
    output logic [31:0] res_o
);

localparam NAN = 32'h7FC00000;
localparam INF = 32'h7F800000;
localparam NEG_INF = 32'hFF800000;

logic [31:0] res;
logic        res_sign;
logic [7:0]  res_exp;
logic [22:0] res_mant;

logic        sign_a;
logic        sign_b;
logic [7:0]  exp_a;
logic [7:0]  exp_b;
logic [23:0] mant_a;
logic [23:0] mant_b;

assign sign_a = a_i[31];
assign sign_b = b_i[31] ^ (ctrl_i == FPU_SUB);
assign exp_a  = a_i[30:23];
assign exp_b  = b_i[30:23];
assign mant_a = (exp_a == 8'h0) ? { 1'b0, a_i[22:0] } : { 1'b1, a_i[22:0] };
assign mant_b = (exp_b == 8'h0) ? { 1'b0, b_i[22:0] } : { 1'b1, b_i[22:0] };

logic signed [8:0] exp_diff;
assign exp_diff = exp_a - exp_b;

//              2                   1                   0
//  6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
// ┌─┬─────────────────────────────────────────────┬─┬─┬─┐
// │1│                  mantissa                   │G│R│S│
// └─┴─────────────────────────────────────────────┴─┴─┴─┘
logic [26:0] mant_a_aligned;
logic [26:0] mant_b_aligned;
logic [49:0] shift_wide;
logic [7:0]  exp_aligned;

//                2                   1                   0
//  7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
// ┌─┬─┬─────────────────────────────────────────────┬─┬─┬─┐
// │C│1│                  mantissa                   │G│R│S│
// └─┴─┴─────────────────────────────────────────────┴─┴─┴─┘
logic [27:0] mant_temp; // 26 + 1 bit for addition carry
logic [4:0]  clz;

logic [26:0] mant_norm;
logic [7:0]  exp_norm;

//          2                   1                   0
//  4 3 2 1 0 9 8 7 6 5 4 3 2 1 0 9 8 7 6 5 4 3 2 1 0
// ┌─┬─┬─────────────────────────────────────────────┐
// │C│1│                  mantissa                   │
// └─┴─┴─────────────────────────────────────────────┘
logic [24:0] mant_rounded; // 24 + 1 bit for rounding carry
logic        round_up;

always_comb begin
    // Exponent Alignment
    if (exp_diff > 0) begin
        mant_a_aligned = { mant_a, 3'b000 };

        shift_wide = { mant_b, 26'b0 } >> exp_diff;
        if (exp_diff >= 26) begin
            mant_b_aligned = { 26'b0, |mant_b };
        end else begin
            mant_b_aligned = { shift_wide[49 -: 26], |shift_wide[23:0] }; // { mant || G || R, S }
        end

        exp_aligned = exp_a;
    end else begin
        mant_b_aligned = { mant_b, 3'b000 };

        shift_wide = { mant_a, 26'b0 } >> -exp_diff;
        if (-exp_diff >= 26) begin
            mant_a_aligned = { 26'b0, |mant_a };
        end else begin
            mant_a_aligned = { shift_wide[49 -: 26], |shift_wide[23:0] }; // { mant || G || R, S }
        end

        exp_aligned = exp_b;
    end

    // Addition/Subtraction
    if (sign_a == sign_b) begin
        res_sign = sign_a;
        mant_temp = mant_a_aligned + mant_b_aligned;
    end else begin
        if (mant_a_aligned == mant_b_aligned) begin // a - b = 0
            res_sign = 1'b0;
            mant_temp = 28'h0;
        end else if (mant_a_aligned > mant_b_aligned) begin // a - b > 0
            res_sign = sign_a;
            mant_temp = mant_a_aligned - mant_b_aligned;
        end else begin // a - b < 0
            res_sign = sign_b;
            mant_temp = mant_b_aligned - mant_a_aligned;
        end
    end

    // Normalize
    if (mant_temp[27]) begin // mant_a + mant_b overflow
        mant_norm = { mant_temp[27:2], (mant_temp[1] | mant_temp[0]) };
        exp_norm = exp_aligned + 8'd1;
    end else begin
        if (mant_temp == 28'h0 || exp_aligned <= clz) begin // Zero
            mant_norm = 27'h0;
            exp_norm = 8'h0;
        end else begin
            mant_norm = mant_temp << clz;
            exp_norm = exp_aligned - clz;
        end
    end

    // Rounding
    // For (G, R, S):
    //   - (0, x, x) -> No rounding
    //   - (1, 0, 0) -> Round to even (Round up if LSB is 1)
    //   - (1, x, 1) -> Round up
    //   - (1, 1, x) -> Round up
    round_up = mant_norm[2] &
               (mant_norm[1] | mant_norm[0] | mant_norm[3]); // G & (R | S | LSB)
    mant_rounded = { 1'b0, mant_norm[26:3] } + round_up;

    // ReNormalize after rounding
    if (mant_rounded[24]) begin // overflow after rounding
        res_mant = mant_rounded[23:1];
        res_exp = exp_norm + 8'd1;
    end else begin
        res_mant = mant_rounded[22:0];
        res_exp = exp_norm;
    end
end


////////////////////////////////////////////////////////////////////////////////
// CLZ, count leading zeros
////////////////////////////////////////////////////////////////////////////////

logic [26:0] x1, x2, x3, x4;
always_comb begin
    if (mant_temp[26 -: 16] == 16'h0) begin
        clz[4] = 1'b1; // clz += 16
        x1 = mant_temp[26:0] << 16;
    end else begin
        clz[4] = 1'b0;
        x1 = mant_temp[26:0];
    end

    if (x1[26 -: 8] == 8'h0) begin
        clz[3] = 1'b1; // clz += 8
        x2 = x1 << 8;
    end else begin
        clz[3] = 1'b0;
        x2 = x1;
    end

    if (x2[26 -: 4] == 4'h0) begin
        clz[2] = 1'b1; // clz += 4
        x3 = x2 << 4;
    end else begin
        clz[2] = 1'b0;
        x3 = x2;
    end

    if (x3[26 -: 2] == 2'h0) begin
        clz[1] = 1'b1; // clz += 2
        x4 = x3 << 2;
    end else begin
        clz[1] = 1'b0;
        x4 = x3;
    end

    if (x4[26 -: 1] == 1'b0) begin
        clz[0] = 1'b1; // clz += 1
    end else begin
        clz[0] = 1'b0;
    end
end


////////////////////////////////////////////////////////////////////////////////
// Output
////////////////////////////////////////////////////////////////////////////////

logic a_is_nan;
logic b_is_nan;
logic a_is_inf;
logic b_is_inf;
logic is_nan; // result is NaN

assign a_is_nan = (exp_a == 8'hFF) && (mant_a[22:0] != 23'h0);
assign b_is_nan = (exp_b == 8'hFF) && (mant_b[22:0] != 23'h0);
assign a_is_inf = (exp_a == 8'hFF) && (mant_a[22:0] == 23'h0);
assign b_is_inf = (exp_b == 8'hFF) && (mant_b[22:0] == 23'h0);
assign is_nan = a_is_nan || b_is_nan;

// res
always_comb begin
    casez ({ is_nan, a_is_inf, b_is_inf })
        3'b1??:  res = NAN;
        3'b010:  res = { sign_a, 8'hFF, 23'h0 };
        3'b001:  res = { sign_b, 8'hFF, 23'h0 };
        3'b011:  res = (sign_a ^ sign_b) ? NAN : { sign_a, 8'hFF, 23'h0 };
        default: res = {res_sign, res_exp, res_mant};
    endcase
end

assign res_o = res;

endmodule
