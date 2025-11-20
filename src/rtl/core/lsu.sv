`include "types.svh"

module lsu(
    input  lsuCtrl_e     lsu_ctrl,
    input  logic [31:0]  addr,
    input  logic         wr_en,
    input  logic [31:0]  wr_data,
    input  logic [31:0]  rd_data,

    output logic         mem_wr_en,
    output logic [31:0]  mem_bit_wr_en,
    output logic [31:0]  mem_addr,
    output logic [31:0]  mem_wr_data,

    output logic [31:0]  mem_rd_data
);

assign mem_wr_en   = wr_en;
assign mem_addr    = addr;

always_comb begin
    case (lsu_ctrl)
        LSU_SB: begin
            case (addr[1:0])
                2'b00:
                    mem_wr_data = {24'h000000, wr_data[7:0]};
                2'b01:
                    mem_wr_data = {16'h0000, wr_data[7:0], 8'h00};
                2'b10:
                    mem_wr_data = {8'h00, wr_data[7:0], 16'h0000};
                2'b11:
                    mem_wr_data = {wr_data[7:0], 24'h000000};
            endcase
        end

        LSU_SH: begin
            if (addr[1]) begin
                mem_wr_data = {wr_data[15:0], 16'h0000};
            end else begin
                mem_wr_data = {16'h0000, wr_data[15:0]};
            end
        end

        default: begin
            mem_wr_data = wr_data;
        end
    endcase
end

always_comb begin
    mem_rd_data   = rd_data;
    mem_bit_wr_en = 32'h00000000;

    case (lsu_ctrl)
        LSU_LB: begin
            mem_rd_data = { { 24{mem_rd_data[7]}}, mem_rd_data[7:0] };
        end

        LSU_LH: begin
            mem_rd_data = { { 16{mem_rd_data[15]}}, mem_rd_data[15:0] };
        end

        LSU_LW: begin
            mem_rd_data = rd_data;
        end

        LSU_LBU: begin
            mem_rd_data = { 24'h000000, mem_rd_data[7:0] };
        end

        LSU_LHU: begin
            mem_rd_data = { 16'h0000, mem_rd_data[15:0] };
        end

        LSU_SB: begin
            case (addr[1:0])
                2'b00:
                    mem_bit_wr_en = 32'h000000FF;
                2'b01:
                    mem_bit_wr_en = 32'h0000FF00;
                2'b10:
                    mem_bit_wr_en = 32'h00FF0000;
                2'b11:
                    mem_bit_wr_en = 32'hFF000000;
            endcase
        end

        LSU_SH: begin
            mem_bit_wr_en = addr[1] ? 32'hFFFF0000 : 32'h0000FFFF;
        end

        LSU_SW: begin
            mem_bit_wr_en = 32'hFFFFFFFF;
        end
    endcase
end

endmodule
