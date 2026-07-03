`include "types.svh"

module lsu(
    input  logic        clk,
    input  lsuCtrl_e    ctrl_i,
    input  logic [31:0] addr_i,
    input  logic        ceb_i,
    input  logic        wen_i,
    input  logic [31:0] wdata_i,
    input  logic [31:0] rdata_i,

    output logic        mem_ceb_o,
    output logic        mem_wen_o,
    output logic [31:0] mem_bwe_o,
    output logic [31:0] mem_addr_o,
    output logic [31:0] mem_wdata_o,
    output logic [31:0] mem_rdata_o
);

lsuCtrl_e   ctrl_s1;
logic [1:0] addr_s1;

assign mem_ceb_o = ceb_i;
assign mem_wen_o = wen_i;
assign mem_addr_o  = addr_i;

// mem_wdata_o
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

// mem_bwe_o
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

// Delay 1 cycle to match the DMEM read latency
always_ff @(posedge clk) begin
    ctrl_s1 <= ctrl_i;
    addr_s1 <= addr_i[1:0];
end

// mem_rdata_o
always_comb begin
    mem_rdata_o   = rdata_i;

    case (ctrl_s1)
        LSU_LB: begin
            case (addr_s1)
                2'b00:
                    mem_rdata_o = { { 24{rdata_i[7]}}, rdata_i[7:0]};
                2'b01:
                    mem_rdata_o = { { 24{rdata_i[15]}}, rdata_i[15:8]};
                2'b10:
                    mem_rdata_o = { { 24{rdata_i[23]}}, rdata_i[23:16]};
                2'b11:
                    mem_rdata_o = { { 24{rdata_i[31]}}, rdata_i[31:24]};
            endcase
        end

        LSU_LH: begin
            if (addr_s1[1]) begin
                mem_rdata_o = { { 16{rdata_i[31]}}, rdata_i[31:16] };
            end else begin
                mem_rdata_o = { { 16{rdata_i[15]}}, rdata_i[15:0] };
            end
        end

        LSU_LW: begin
            mem_rdata_o = rdata_i;
        end

        LSU_LBU: begin
            case (addr_s1)
                2'b00:
                    mem_rdata_o = { 24'h000000, rdata_i[7:0]};
                2'b01:
                    mem_rdata_o = { 24'h000000, rdata_i[15:8]};
                2'b10:
                    mem_rdata_o = { 24'h000000, rdata_i[23:16]};
                2'b11:
                    mem_rdata_o = { 24'h000000, rdata_i[31:24]};
            endcase
        end

        LSU_LHU: begin
            if (addr_s1[1]) begin
                mem_rdata_o = { 16'h0000, rdata_i[31:16] };
            end else begin
                mem_rdata_o = { 16'h0000, rdata_i[15:0] };
            end
        end
    endcase
end

endmodule
