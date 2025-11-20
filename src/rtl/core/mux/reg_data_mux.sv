`include "types.svh"

module reg_data_mux (
    input  logic [31:0]  rd_data_ex,
    input  logic [31:0]  alu_result_mem,
    input  logic [31:0]  result_wb,
    input  forwardCtrl_e forward_sel,
    output logic [31:0]  rd_data_out
);

always_comb begin
    case (forward_sel)
        FORWARD_NONE:
            rd_data_out = rd_data_ex;

        FORWARD_FROM_WB:
            rd_data_out = result_wb;

        FORWARD_FROM_MEM:
            rd_data_out = alu_result_mem;

        default:
            rd_data_out = rd_data_ex;
    endcase
end

endmodule
