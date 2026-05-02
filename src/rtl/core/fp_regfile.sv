module fp_reg_file(
    input  logic        clk,
    input  logic        rst,

    input  logic [4:0]  rs1_addr_i,
    input  logic [4:0]  rs2_addr_i,
    output logic [31:0] rs1_data_o,
    output logic [31:0] rs2_data_o,

    input  logic        wen_i,
    input  logic [4:0]  waddr_i,
    input  logic [31:0] wdata_i
);

endmodule
