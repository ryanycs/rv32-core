`include "types.svh"

module branch_comp(
    input  logic        [31:0] a_i,
    input  logic        [31:0] b_i,
    input  branchCtrl_e        ctrl_i,
    output logic               branch_taken_o
);

always_comb begin
    case (ctrl_i)
        BRANCH_EQ: begin
            branch_taken_o = (a_i == b_i);
        end

        BRANCH_NE: begin
            branch_taken_o = (a_i != b_i);
        end

        BRANCH_LT: begin
            branch_taken_o = ($signed(a_i) < $signed(b_i));
        end

        BRANCH_GE: begin
            branch_taken_o = ($signed(a_i) >= $signed(b_i));
        end

        BRANCH_LTU: begin
            branch_taken_o = (a_i < b_i);
        end

        BRANCH_GEU: begin
            branch_taken_o = (a_i >= b_i);
        end

        default: begin
            branch_taken_o = 1'b0;
        end
    endcase
end

endmodule
