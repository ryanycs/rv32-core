`include "types.svh"

module imm_gen(
    input  logic     [31:0] inst_i,
    input  immType_e        imm_type_i,
    output logic     [31:0] imm_o
);

always_comb begin
    case (imm_type_i)
        I_TYPE: begin
            imm_o = { { 21{inst_i[31]}}, inst_i[30:20] };
        end

        S_TYPE: begin
            imm_o = { { 21{inst_i[31]}}, inst_i[30:25], inst_i[11:7] };
        end

        B_TYPE: begin
            imm_o = { { 20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0 };
        end

        U_TYPE: begin
            imm_o = { inst_i[31:12], 12'b0 };
        end

        J_TYPE: begin
            imm_o = { { 12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:25], inst_i[24:21], 1'b0 };
        end

        default: begin
            imm_o = 32'b0;
        end
    endcase
end

endmodule
