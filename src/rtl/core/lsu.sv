`include "types.svh"

module lsu(
    input  lsuCtrl_e    ctrl_i,
    input  logic [31:0] addr_i,
    input  logic        wen_i,
    input  logic [31:0] wdata_i,
    input  logic [31:0] rdata_i,

    output logic        mem_wen_o,
    output logic [31:0] mem_bwe_o,
    output logic [31:0] mem_addr_o,
    output logic [31:0] mem_wdata_o,
    output logic [31:0] mem_rdata_o
);

assign mem_wen_o = wen_i;
assign mem_addr_o  = addr_i;

always_comb begin
    case (ctrl_i)
        LSU_SB: begin
            case (addr_i[1:0])
                2'b00:
                    mem_wdata_o = {24'h000000, wdata_i[7:0]};
                2'b01:
                    mem_wdata_o = {16'h0000, wdata_i[7:0], 8'h00};
                2'b10:
                    mem_wdata_o = {8'h00, wdata_i[7:0], 16'h0000};
                2'b11:
                    mem_wdata_o = {wdata_i[7:0], 24'h000000};
            endcase
        end

        LSU_SH: begin
            if (addr_i[1]) begin
                mem_wdata_o = {wdata_i[15:0], 16'h0000};
            end else begin
                mem_wdata_o = {16'h0000, wdata_i[15:0]};
            end
        end

        default: begin
            mem_wdata_o = wdata_i;
        end
    endcase
end

always_comb begin
    mem_bwe_o = 32'h00000000;

    case (ctrl_i)
        LSU_SB: begin
            case (addr_i[1:0])
                2'b00:
                    mem_bwe_o = 32'h000000FF;
                2'b01:
                    mem_bwe_o = 32'h0000FF00;
                2'b10:
                    mem_bwe_o = 32'h00FF0000;
                2'b11:
                    mem_bwe_o = 32'hFF000000;
            endcase
        end

        LSU_SH: begin
            mem_bwe_o = addr_i[1] ? 32'hFFFF0000 : 32'h0000FFFF;
        end

        LSU_SW: begin
            mem_bwe_o = 32'hFFFFFFFF;
        end
    endcase
end

always_comb begin
    mem_rdata_o   = rdata_i;

    case (ctrl_i)
        LSU_LB: begin
            mem_rdata_o = { { 24{mem_rdata_o[7]}}, mem_rdata_o[7:0] };
        end

        LSU_LH: begin
            mem_rdata_o = { { 16{mem_rdata_o[15]}}, mem_rdata_o[15:0] };
        end

        LSU_LW: begin
            mem_rdata_o = rdata_i;
        end

        LSU_LBU: begin
            mem_rdata_o = { 24'h000000, mem_rdata_o[7:0] };
        end

        LSU_LHU: begin
            mem_rdata_o = { 16'h0000, mem_rdata_o[15:0] };
        end
    endcase
end

endmodule
