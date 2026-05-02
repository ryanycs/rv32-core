`include "types.svh"

module csr(
    input  logic        clk,
    input  logic        rst,
    input  logic        csr_instret_inc_i,
    input  logic [11:0] csr_addr_i,
    output logic [31:0] csr_rdata_o
);

// CSR Registers
logic [63:0] instret;
logic [63:0] cycle;

// cycle
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        cycle   <= 32'd0;
    end else begin
        cycle <= cycle + 32'd1;
    end
end

// instret
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        instret <= 32'd0;
    end else begin
        if (csr_instret_inc_i) begin
            instret <= instret + 32'd1;
        end
    end
end

always_comb begin
    case (csr_addr_i)
        CSR_CYCLE: begin
            csr_rdata_o = cycle[31:0];
        end

        CSR_CYCLEH: begin
            csr_rdata_o = cycle[63:32];
        end

        CSR_INSTRET: begin
            csr_rdata_o = instret[31:0];
        end

        CSR_INSTRETH: begin
            csr_rdata_o = instret[63:32];
        end

        default: begin
            csr_rdata_o = 32'd0;
        end
    endcase
end

endmodule
