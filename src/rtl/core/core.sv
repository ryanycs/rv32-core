`include "types.svh"

`include "alu.sv"
`include "branch_comp.sv"
`include "control_unit.sv"
`include "decoder.sv"
`include "forwarding_unit.sv"
`include "hazard_unit.sv"
`include "imm_gen.sv"
`include "lsu.sv"
// `include "branch_predictor.sv" /* TODO */
// `include "fpu.sv"              /* TODO */
// `include "mul.sv"              /* TODO */
`include "program_counter.sv"
`include "reg_file.sv"
`include "mux/mux2.sv"
`include "mux/pc_mux.sv"
`include "mux/reg_data_mux.sv"
`include "mux/result_mux.sv"
`include "pipeline/if_id.sv"
`include "pipeline/id_ex.sv"
`include "pipeline/ex_mem.sv"
`include "pipeline/mem_wb.sv"
// `include "fp_reg_file.sv"      /* TODO */

`ifdef Zicsr_EXT
`include "csr.sv"
`endif

module core(
    input  logic clk,
    input  logic rst,

    input  logic [31:0] imem_rd_data,
    input  logic [31:0] dmem_rd_data,

    output logic [31:0] imem_addr,

    output logic        dmem_wr_en,
    output logic [31:0] dmem_bit_wr_en,
    output logic [31:0] dmem_addr,
    output logic [31:0] dmem_wr_data
);

////////////////////////////////////////
// IF stage
////////////////////////////////////////
pcSrc_e      pc_sel;
logic [31:0] pc_next;
logic [31:0] pc_if;
logic [31:0] pc_plus_4_if;
logic [31:0] inst_if;

`ifdef DEBUG
opcodeType_e opcode_type_if;
`endif

////////////////////////////////////////
// ID stage
////////////////////////////////////////
logic [31:0] pc_id;
logic [31:0] pc_plus_4_id;
logic [31:0] inst_id;

// Register addr
logic [4:0]  rd_id;
logic [4:0]  rs1_id;
logic [4:0]  rs2_id;

// Register read data
logic [31:0] rs1_data_id;
logic [31:0] rs2_data_id;

// Immediate generator
immType_e    imm_type_id;
logic [31:0] imm_id;

`ifdef Zicsr_EXT
// CSR signal
logic [11:0] csr_addr_id;
logic        csr_instret_inc_id;
`endif

// Control signal
opcodeType_e opcode_type_id;
logic        reg_wr_en_id;
logic        mem_wr_en_id;
aluCtrl_e    alu_ctrl_id;
logic        jump_id;
logic        branch_id;
branchCtrl_e branch_ctrl_id;
aluSrc1_e    alu_src1_id;
aluSrc2_e    alu_src2_id;
lsuCtrl_e    lsu_ctrl_id;
resultSrc_e  result_src_id;

////////////////////////////////////////
// EX stage
////////////////////////////////////////
logic [31:0] pc_ex;
logic [31:0] pc_plus_4_ex;

// Register addr
logic [4:0]  rd_ex;
logic [4:0]  rs1_ex;
logic [4:0]  rs2_ex;

// Register data
logic [31:0] rs1_data_ex;
logic [31:0] rs2_data_ex;

// Immediate
logic [31:0] imm_ex;

// Forwarded register data
logic [31:0] rs1_data_mux_out;
logic [31:0] rs2_data_mux_out;

// ALU signal
logic [31:0] alu_a;
logic [31:0] alu_b;
logic [31:0] alu_result_ex;

`ifdef Zicsr_EXT
// CSR signal
logic [11:0] csr_addr_ex;
logic        csr_instret_inc_ex;
logic [31:0] csr_rd_data_ex;
`endif

// Control signal
logic        reg_wr_en_ex;
logic        mem_wr_en_ex;
aluCtrl_e    alu_ctrl_ex;
logic        jump_ex;
logic        branch_ex;
branchCtrl_e branch_ctrl_ex;
aluSrc1_e    alu_src1_ex;
aluSrc2_e    alu_src2_ex;
lsuCtrl_e    lsu_ctrl_ex;
resultSrc_e  result_src_ex;

`ifdef DEBUG
opcodeType_e opcode_type_ex;
`endif

////////////////////////////////////////
// MEM stage
////////////////////////////////////////
logic [31:0] pc_plus_4_mem;
logic [4:0]  rd_mem;
logic [31:0] rs2_data_mem;
logic [31:0] alu_result_mem;
logic [31:0] mem_rd_data_mem;

// Control signal
logic        reg_wr_en_mem;
logic        mem_wr_en_mem;
lsuCtrl_e    lsu_ctrl_mem;
resultSrc_e  result_src_mem;

`ifdef Zicsr_EXT
// CSR signal
logic [31:0] csr_rd_data_mem;
`endif

`ifdef DEBUG
opcodeType_e opcode_type_mem;
`endif

////////////////////////////////////////
// WB stage
////////////////////////////////////////
logic [31:0] pc_plus_4_wb;
logic [4:0]  rd_wb;
logic [31:0] alu_result_wb;
logic [31:0] mem_rd_data_wb;
logic [31:0] result_wb;

// Control signal
logic        reg_wr_en_wb;
resultSrc_e  result_src_wb;

`ifdef Zicsr_EXT
// CSR signal
logic [31:0] csr_rd_data_wb;
`endif

`ifdef DEBUG
opcodeType_e opcode_type_wb;
`endif

////////////////////////////////////////
// Branch & Hazard signals
////////////////////////////////////////
// Branch signal
logic branch_taken;

// Forwarding signals
forwardCtrl_e forward_a;
forwardCtrl_e forward_b;

// Hazard signals
logic stall_pc;
logic stall_if_id;
logic flush_if_id;
logic flush_id_ex;

////////////////////////////////////////////////////////////////////////////////
// Instruction Fetch
////////////////////////////////////////////////////////////////////////////////

// PC Register
program_counter u_pc(
    .clk    (clk),
    .rst    (rst),
    .en     (stall_pc),

    .pc_in  (pc_next),
    .pc_out (pc_if)
);

assign pc_plus_4_if = pc_if + 32'd4;
assign imem_addr    = pc_if;
assign inst_if      = imem_rd_data;

// Pipeline Register IF/ID
if_id u_if_id(
    .clk           (clk),
    .rst           (rst),
    .clear         (flush_if_id),   // 1 to clear
    .en            (stall_if_id),   // 1 to enable

    .pc_in         (pc_if),
    .pc_plus_4_in  (pc_plus_4_if),
    .inst_in       (inst_if),

    .pc_out        (pc_id),
    .pc_plus_4_out (pc_plus_4_id),
    .inst_out      (inst_id)
);

// PC select:
//   - ALU_RESULT: if jump or branch taken in EX
//   - PC + 4: otherwise
assign pc_sel = (jump_ex | (branch_ex & branch_taken))
                ? PC_SRC_ALU_RESULT : PC_SRC_PC_PLUS_4;

// Mux for next PC:
//   - ALU result (branch/jump target in EX)
//   - PC + 4 (IF)
pc_mux u_pc_mux(
    .alu_result (alu_result_ex),
    .pc_plus_4  (pc_plus_4_if),
    .pc_sel     (pc_sel),
    .pc_out     (pc_next)
);

`ifdef DEBUG
decoder u_decoder_debug(
    .inst        (inst_if),        // Instruction
    .rs1         (),
    .rs2         (),
    .rd          (),
    .imm_type    (),
    .opcode_type (opcode_type_if)  // Instruction type
);
`endif

////////////////////////////////////////////////////////////////////////////////
// Instruction Decode
////////////////////////////////////////////////////////////////////////////////

decoder u_decoder(
    .inst        (inst_id),        // Instruction
    .rs1         (rs1_id),
    .rs2         (rs2_id),
    .rd          (rd_id),
`ifdef Zicsr_EXT
    .csr_addr    (csr_addr_id),
`endif

    .imm_type    (imm_type_id),
    .opcode_type (opcode_type_id)
);

imm_gen u_imm_gen(
    .inst     (inst_id),
    .imm_type (imm_type_id),
    .imm      (imm_id)
);

control_unit u_control(
    .opcode_type (opcode_type_id),  // Instruction type
    .reg_wr_en   (reg_wr_en_id),    // Register write enable
    .mem_wr_en   (mem_wr_en_id),    // Memory write enable
    .jump        (jump_id),         // Jump signal
    .branch      (branch_id),       // Branch signal
    .branch_ctrl (branch_ctrl_id),  // Branch control (BEQ, BNE, etc.)
    .alu_ctrl    (alu_ctrl_id),     // ALU control signal (ADD, SUB, etc.)
    .alu_src1    (alu_src1_id),     // ALU source 1 select
    .alu_src2    (alu_src2_id),     // ALU source 2 select
    .lsu_ctrl    (lsu_ctrl_id),     // Load/Store unit control
    .result_src  (result_src_id)    // Result source select

`ifdef Zicsr_EXT
    ,
    .csr_instret_inc (csr_instret_inc_id)
`endif
);

// Register File
reg_file u_reg_file(
    .clk      (clk),
    .rst      (rst),
    .rs1      (rs1_id),
    .rs2      (rs2_id),
    .rs1_data (rs1_data_id),
    .rs2_data (rs2_data_id),
    .wr_en    (reg_wr_en_wb),
    .wr_addr  (rd_wb),
    .wr_data  (result_wb)
);

id_ex u_id_ex(
    .clk             (clk),
    .rst             (rst),
    .clear           (flush_id_ex),

    .reg_wr_en_in    (reg_wr_en_id),
    .mem_wr_en_in    (mem_wr_en_id),
    .jump_in         (jump_id),
    .branch_in       (branch_id),
    .branch_ctrl_in  (branch_ctrl_id),
    .alu_ctrl_in     (alu_ctrl_id),
    .alu_src1_in     (alu_src1_id),
    .alu_src2_in     (alu_src2_id),
    .lsu_ctrl_in     (lsu_ctrl_id),
    .result_src_in   (result_src_id),
    .pc_in           (pc_id),
    .pc_plus_4_in    (pc_plus_4_id),
    .rs1_data_in     (rs1_data_id),
    .rs2_data_in     (rs2_data_id),
    .imm_in          (imm_id),
    .rs1_in          (rs1_id),
    .rs2_in          (rs2_id),
    .rd_in           (rd_id),

    .reg_wr_en_out   (reg_wr_en_ex),
    .mem_wr_en_out   (mem_wr_en_ex),
    .jump_out        (jump_ex),
    .branch_out      (branch_ex),
    .branch_ctrl_out (branch_ctrl_ex),
    .alu_ctrl_out    (alu_ctrl_ex),
    .alu_src1_out    (alu_src1_ex),
    .alu_src2_out    (alu_src2_ex),
    .lsu_ctrl_out    (lsu_ctrl_ex),
    .result_src_out  (result_src_ex),
    .pc_out          (pc_ex),
    .pc_plus_4_out   (pc_plus_4_ex),
    .rs1_data_out    (rs1_data_ex),
    .rs2_data_out    (rs2_data_ex),
    .imm_out         (imm_ex),
    .rs1_out         (rs1_ex),
    .rs2_out         (rs2_ex),
    .rd_out          (rd_ex)

`ifdef Zicsr_EXT
    ,
    .csr_instret_inc_in  (csr_instret_inc_id),
    .csr_addr_in         (csr_addr_id),
    .csr_instret_inc_out (csr_instret_inc_ex),
    .csr_addr_out        (csr_addr_ex)
`endif

`ifdef DEBUG
    ,
    .opcode_type_in  (opcode_type_id),
    .opcode_type_out (opcode_type_ex)
`endif
);

////////////////////////////////////////////////////////////////////////////////
// Execute
////////////////////////////////////////////////////////////////////////////////

// Mux for forwarding rs1 data:
//   - rs1 (EX)
//   - ALU result (MEM)
//   - write-back data (WB)
reg_data_mux u_rs1_data_mux(
    .rd_data_ex     (rs1_data_ex),
    .alu_result_mem (alu_result_mem),
    .result_wb      (result_wb),
    .forward_sel    (forward_a),
    .rd_data_out    (rs1_data_mux_out)
);

// Mux for ALU operand a:
//   - PC
//   - rs1
mux2 u_alu_src1_mux(
    .in1 (pc_ex),
    .in2 (rs1_data_mux_out),
    .sel (alu_src1_ex),
    .out (alu_a)
);

// Mux for forwarding rs2 data:
//   - rs2 (EX)
//   - ALU result (MEM)
//   - write-back data (WB)
reg_data_mux u_rs2_data_mux(
    .rd_data_ex     (rs2_data_ex),
    .alu_result_mem (alu_result_mem),
    .result_wb      (result_wb),
    .forward_sel    (forward_b),
    .rd_data_out    (rs2_data_mux_out)
);

// Mux for ALU operand b:
//   - rs2
//   - immediate
mux2 u_alu_src2_mux(
    .in1 (rs2_data_mux_out),
    .in2 (imm_ex),
    .sel (alu_src2_ex),
    .out (alu_b)
);

alu u_alu(
    .a          (alu_a),
    .b          (alu_b),
    .alu_ctrl   (alu_ctrl_ex),
    .alu_result (alu_result_ex)
);

branch_comp u_branch_comp(
    .a            (rs1_data_mux_out),
    .b            (rs2_data_mux_out),
    .branch_ctrl  (branch_ctrl_ex),
    .branch_taken (branch_taken)
);

forwarding_unit u_forwarding(
    .rs1_ex        (rs1_ex),
    .rs2_ex        (rs2_ex),
    .rd_mem        (rd_mem),
    .rd_wb         (rd_wb),
    .reg_wr_en_mem (reg_wr_en_mem),
    .reg_wr_en_wb  (reg_wr_en_wb),
    .forward_a     (forward_a),
    .forward_b     (forward_b)
);

hazard_unit u_hazard(
    .rs1_id        (rs1_id),
    .rs2_id        (rs2_id),
    .rd_ex         (rd_ex),
    .result_src_ex (result_src_ex),
    .pc_sel        (pc_sel),

    .stall_pc      (stall_pc),
    .stall_if_id   (stall_if_id),
    .flush_if_id   (flush_if_id),
    .flush_id_ex   (flush_id_ex)
);

`ifdef Zicsr_EXT
csr u_csr(
    .clk             (clk),
    .rst             (rst),
    .csr_instret_inc (csr_instret_inc_ex),
    .csr_addr        (csr_addr_ex),
    .csr_rd_data     (csr_rd_data_ex)
);
`endif

ex_mem u_ex_mem(
    .clk            (clk),
    .rst            (rst),

    .reg_wr_en_in   (reg_wr_en_ex),
    .mem_wr_en_in   (mem_wr_en_ex),
    .lsu_ctrl_in    (lsu_ctrl_ex),
    .result_src_in  (result_src_ex),
    .alu_result_in  (alu_result_ex),
    .pc_plus_4_in   (pc_plus_4_ex),
    .rs2_data_in    (rs2_data_mux_out),
    .rd_in          (rd_ex),

    .reg_wr_en_out  (reg_wr_en_mem),
    .mem_wr_en_out  (mem_wr_en_mem),
    .lsu_ctrl_out   (lsu_ctrl_mem),
    .result_src_out (result_src_mem),
    .alu_result_out (alu_result_mem),
    .pc_plus_4_out  (pc_plus_4_mem),
    .rs2_data_out   (rs2_data_mem),
    .rd_out         (rd_mem)

`ifdef Zicsr_EXT
    ,
    .csr_rd_data_in  (csr_rd_data_ex),
    .csr_rd_data_out (csr_rd_data_mem)
`endif

`ifdef DEBUG
    ,
    .opcode_type_in  (opcode_type_ex),
    .opcode_type_out (opcode_type_mem)
`endif
);

////////////////////////////////////////////////////////////////////////////////
// Memory Access
////////////////////////////////////////////////////////////////////////////////

lsu u_lsu(
    .lsu_ctrl       (lsu_ctrl_mem),
    .addr           (alu_result_mem),
    .wr_en          (mem_wr_en_mem),
    .wr_data        (rs2_data_mem),
    .rd_data        (dmem_rd_data),

    .mem_wr_en      (dmem_wr_en),
    .mem_bit_wr_en  (dmem_bit_wr_en),
    .mem_addr       (dmem_addr),
    .mem_wr_data    (dmem_wr_data),
    .mem_rd_data    (mem_rd_data_mem)
);

mem_wb u_mem_wb(
    .clk             (clk),
    .rst             (rst),

    .reg_wr_en_in    (reg_wr_en_mem),
    .result_src_in   (result_src_mem),
    .alu_result_in   (alu_result_mem),
    .mem_rd_data_in  (mem_rd_data_mem),
    .rd_in           (rd_mem),
    .pc_plus_4_in    (pc_plus_4_mem),

    .reg_wr_en_out   (reg_wr_en_wb),
    .result_src_out  (result_src_wb),
    .alu_result_out  (alu_result_wb),
    .mem_rd_data_out (mem_rd_data_wb),
    .rd_out          (rd_wb),
    .pc_plus_4_out   (pc_plus_4_wb)

`ifdef Zicsr_EXT
    ,
    .csr_rd_data_in      (csr_rd_data_mem),
    .csr_rd_data_out     (csr_rd_data_wb)
`endif

`ifdef DEBUG
    ,
    .opcode_type_in  (opcode_type_mem),
    .opcode_type_out (opcode_type_wb)
`endif
);

////////////////////////////////////////////////////////////////////////////////
// Write Back
////////////////////////////////////////////////////////////////////////////////

// Mux for write-back data:
//   - PC + 4 (for JAL/JALR)
//   - ALU result
//   - Memory read data
//   - CSR read data (if Zicsr is enabled)
result_mux u_result_mux(
    .pc_plus_4   (pc_plus_4_wb),
    .alu_result  (alu_result_wb),
    .mem_rd_data (mem_rd_data_wb),
`ifdef Zicsr_EXT
    .csr_rd_data (csr_rd_data_wb),
`endif
    .result_sel  (result_src_wb),
    .result_out  (result_wb)
);

endmodule
