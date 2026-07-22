`include "types.svh"

`include "alu.sv"
`include "branch_comp.sv"
`include "control.sv"
`include "csr.sv"
`include "decoder.sv"
`include "reg_ex_mem.sv"
`include "forwarding.sv"
`include "hazard.sv"
`include "reg_id_ex.sv"
`include "reg_if_id.sv"
`include "imm_gen.sv"
`include "lsu.sv"
`include "reg_mem_wb.sv"
`include "pc.sv"
`include "regfile.sv"
`include "fp_regfile.sv"
`include "fpu.sv"
`include "bht.sv"
`include "btb.sv"

module core(
    input  logic        clk,
    input  logic        rst,

    // Instruction memory
    output logic [31:0] imem_addr,
    input  logic [31:0] imem_rdata,

    // Data memory
    output logic        dmem_ceb,
    output logic        dmem_wen,
    output logic [31:0] dmem_bwe,
    output logic [31:0] dmem_addr,
    output logic [31:0] dmem_wdata,
    input  logic [31:0] dmem_rdata
);

// {{{ Wire declaration
////////////////////////////////////////
// IF stage
////////////////////////////////////////
pcSrc_e      pc_sel;
logic [31:0] pc_next;
logic [31:0] if_pc;
logic [31:0] if_pc_plus_4;
logic [31:0] if_inst;
// Branch predictor signal
logic        bht_predict_taken;
logic [31:0] btb_target;
logic        btb_hit;
logic        if_bp_taken;

////////////////////////////////////////
// ID stage
////////////////////////////////////////
logic [31:0] id_pc;
logic [31:0] id_pc_plus_4;
logic [31:0] id_inst;
logic [31:0] id_inst_prev;
// Register addr
logic [4:0]  id_rd_addr;
logic [4:0]  id_rs1_addr;
logic [4:0]  id_rs2_addr;
// Register read data
logic [31:0] rs1_data;
logic [31:0] rs2_data;
logic [31:0] fp_rs1_data;
logic [31:0] fp_rs2_data;
logic [31:0] id_rs1_data;
logic [31:0] id_rs2_data;
// Immediate generator
immType_e    id_imm_type;
logic [31:0] id_imm;
// CSR signal
logic [11:0] id_csr_addr;
logic        id_csr_instret_inc;
// Control signal
opcodeType_e id_opcode_type;
logic        id_rf_wen;
logic        id_fp_rf_wen;
rfSel_e      id_rs1_sel;
rfSel_e      id_rs2_sel;
logic        id_mem_ceb;
logic        id_mem_wen;
aluCtrl_e    id_alu_ctrl;
logic        id_jump;
logic        id_branch;
branchCtrl_e id_branch_ctrl;
aluSrc1_e    id_alu_src1;
aluSrc2_e    id_alu_src2;
fpuCtrl_e    id_fpu_ctrl;
lsuCtrl_e    id_lsu_ctrl;
resultSrc_e  id_result_src;
// Branch predictor signal
logic        id_bp_taken;

////////////////////////////////////////
// EX stage
////////////////////////////////////////
logic [31:0] ex_pc;
logic [31:0] ex_pc_plus_4;
// Register addr
logic [4:0]  ex_rd_addr;
logic [4:0]  ex_rs1_addr;
logic [4:0]  ex_rs2_addr;
// Register data
logic [31:0] ex_rs1_data;
logic [31:0] ex_rs2_data;
// Immediate
logic [31:0] ex_imm;
// Forwarded register data
logic [31:0] ex_rs1_data_fwd;
logic [31:0] ex_rs2_data_fwd;
// ALU signal
logic [31:0] ex_alu_a;
logic [31:0] ex_alu_b;
logic [31:0] ex_alu_result;
// FPU signal
logic [31:0] ex_fpu_result;
// CSR signal
logic [11:0] ex_csr_addr;
logic        ex_csr_instret_inc;
logic [31:0] ex_csr_rdata;
// Control signal
logic        ex_rf_wen;
logic        ex_fp_rf_wen;
rfSel_e      ex_rs1_sel;
rfSel_e      ex_rs2_sel;
logic        ex_mem_ceb;
logic        ex_mem_wen;
aluCtrl_e    ex_alu_ctrl;
logic        ex_jump;
logic        ex_branch;
branchCtrl_e ex_branch_ctrl;
aluSrc1_e    ex_alu_src1;
aluSrc2_e    ex_alu_src2;
fpuCtrl_e    ex_fpu_ctrl;
lsuCtrl_e    ex_lsu_ctrl;
resultSrc_e  ex_result_src;
// Branch predictor signal
logic        ex_bp_taken;

////////////////////////////////////////
// MEM stage
////////////////////////////////////////
logic [31:0] mem_pc_plus_4;
logic [4:0]  mem_rd_addr;
logic [31:0] mem_rs2_data;
logic [31:0] mem_alu_result;
logic [31:0] mem_fpu_result;
logic [31:0] mem_mem_rdata;
// Control signal
logic        mem_rf_wen;
logic        mem_fp_rf_wen;
logic        mem_mem_ceb;
logic        mem_mem_wen;
lsuCtrl_e    mem_lsu_ctrl;
resultSrc_e  mem_result_src;
// CSR signal
logic [31:0] mem_csr_rdata;

////////////////////////////////////////
// WB stage
////////////////////////////////////////
logic [31:0] wb_pc_plus_4;
logic [4:0]  wb_rd_addr;
logic [31:0] wb_alu_result;
logic [31:0] wb_fpu_result;
logic [31:0] wb_mem_rdata;
logic [31:0] wb_result;
// Control signal
logic        wb_rf_wen;
logic        wb_fp_rf_wen;
resultSrc_e  wb_result_src;
// CSR signal
logic [31:0] wb_csr_rdata;

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
logic stall_if_id_s1;
logic flush_if_id;
logic flush_if_id_s1;
logic flush_id_ex;
// }}}

////////////////////////////////////////////////////////////////////////////////
// Instruction Fetch
////////////////////////////////////////////////////////////////////////////////

// PC
pc u_pc(
    .clk  (clk),
    .rst  (rst),
    .stall(stall_pc),
    .pc_i (pc_next),
    .pc_o (if_pc)
);

assign if_pc_plus_4 = if_pc + 32'd4;
assign imem_addr = if_pc;

// Branch History Table
bht u_bht(
    .clk            (clk),
    .rst            (rst),
    .pc_i           (if_pc),
    .update_i       (ex_branch),
    .update_taken_i (branch_taken),
    .update_pc_i    (ex_pc),
    .predict_taken_o(bht_predict_taken)
);

// Branch Target Buffer
btb u_btb(
    .clk            (clk),
    .rst            (rst),
    .flush          (1'b0),
    .pc_i           (if_pc),
    .update_i       (ex_branch & branch_taken),
    .update_pc_i    (ex_pc),
    .update_target_i(ex_alu_result),
    .target_o       (btb_target),
    .hit_o          (btb_hit)
);

assign if_bp_taken = bht_predict_taken & btb_hit;

// PC select: (in order of priority)
//   - ALU_RESULT: jump or branch misprediction (predicted not taken but taken)
//   - PC + 4 (EX): branch misprediction (predicted taken but not taken)
//   - BTB: if branch predicted taken in IF
//   - PC + 4 (IF): otherwise
always_comb begin
    if (ex_jump || (ex_branch && branch_taken && !ex_bp_taken)) begin
        pc_sel = PC_SRC_ALU_RESULT;
    end else if (ex_bp_taken && !branch_taken && ex_branch) begin
        pc_sel = PC_SRC_MISPREDICT;
    end else if (if_bp_taken) begin
        pc_sel = PC_SRC_BTB;
    end else begin
        pc_sel = PC_SRC_PC_PLUS_4;
    end
end

// Mux for next PC:
//   - ALU result (branch/jump target in EX)
//   - BTB (branch target in IF)
//   - PC + 4 (EX)
//   - PC + 4 (IF)
always_comb begin
    case (pc_sel)
        PC_SRC_ALU_RESULT: begin
            pc_next = ex_alu_result & 32'hFFFFFFFE; // Ensure LSB is 0
        end
        PC_SRC_BTB: begin
            pc_next = btb_target;
        end
        PC_SRC_MISPREDICT: begin
            pc_next = ex_pc_plus_4;
        end
        default: begin
            pc_next = if_pc_plus_4;
        end
    endcase
end

// Pipeline Register IF/ID
reg_if_id u_if_id(
    .clk            (clk),
    .rst            (rst),
    .stall          (stall_if_id),
    .flush          (flush_if_id),
    .pc_i           (if_pc),
    .pc_plus_4_i    (if_pc_plus_4),
    .predict_taken_i(if_bp_taken),
    .pc_o           (id_pc),
    .pc_plus_4_o    (id_pc_plus_4),
    .predict_taken_o(id_bp_taken)
);


////////////////////////////////////////////////////////////////////////////////
// Instruction Decode
////////////////////////////////////////////////////////////////////////////////

// Delay 1 cycle to match the IMEM read latency
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        flush_if_id_s1 <= 1'b0;
        stall_if_id_s1 <= 1'b0;
        id_inst_prev <= 32'd0;
    end else begin
        flush_if_id_s1 <= flush_if_id;
        stall_if_id_s1 <= stall_if_id;
        id_inst_prev <= imem_rdata; // for stall
    end
end

// Mux for instruction
//   - flush
//      - To avoid fetching UNKNOWN value form IMEM,
//        flush the instruction after reset (if_pc == 32'd0)
//   - stall
//   - instruction from IMEM
always_comb begin
    if (flush_if_id_s1 || if_pc == 32'd0) begin
        id_inst = 32'd0;
    end else if (stall_if_id_s1) begin
        id_inst = id_inst_prev;
    end else begin
        id_inst = imem_rdata;
    end
end

decoder u_decoder(
    .inst_i       (id_inst),
    .rs1_addr_o   (id_rs1_addr),
    .rs2_addr_o   (id_rs2_addr),
    .rd_addr_o    (id_rd_addr),
    .csr_addr_o   (id_csr_addr),
    .imm_type_o   (id_imm_type),
    .opcode_type_o(id_opcode_type)
);

imm_gen u_imm_gen(
    .inst_i    (id_inst),
    .imm_type_i(id_imm_type),
    .imm_o     (id_imm)
);

control u_control(
    .opcode_type_i    (id_opcode_type),
    .rf_wen_o         (id_rf_wen),
    .fp_rf_wen_o      (id_fp_rf_wen),
    .rf_rs1_sel_o     (id_rs1_sel),
    .rf_rs2_sel_o     (id_rs2_sel),
    .mem_ceb_o        (id_mem_ceb),
    .mem_wen_o        (id_mem_wen),
    .jump_o           (id_jump),
    .branch_o         (id_branch),
    .branch_ctrl_o    (id_branch_ctrl),
    .alu_ctrl_o       (id_alu_ctrl),
    .alu_src1_o       (id_alu_src1),
    .alu_src2_o       (id_alu_src2),
    .fpu_ctrl_o       (id_fpu_ctrl),
    .lsu_ctrl_o       (id_lsu_ctrl),
    .result_src_o     (id_result_src),
    .csr_instret_inc_o(id_csr_instret_inc)
);

regfile u_regfile(
    .clk       (clk),
    .rst       (rst),
    .rs1_addr_i(id_rs1_addr),
    .rs2_addr_i(id_rs2_addr),
    .rs1_data_o(rs1_data),
    .rs2_data_o(rs2_data),
    .wen_i     (wb_rf_wen),
    .waddr_i   (wb_rd_addr),
    .wdata_i   (wb_result)
);

fp_regfile u_fp_regfile(
    .clk       (clk),
    .rst       (rst),
    .rs1_addr_i(id_rs1_addr),
    .rs2_addr_i(id_rs2_addr),
    .rs1_data_o(fp_rs1_data),
    .rs2_data_o(fp_rs2_data),
    .wen_i     (wb_fp_rf_wen),
    .waddr_i   (wb_rd_addr),
    .wdata_i   (wb_result)
);

// Mux for regfile
//   - regfile
//   - fp_regfile
always_comb begin
    // rs1
    if (id_rs1_sel == RF_SEL_FP) begin
        id_rs1_data = fp_rs1_data;
    end else begin
        id_rs1_data = rs1_data;
    end

    // rs2
    if (id_rs2_sel == RF_SEL_FP) begin
        id_rs2_data = fp_rs2_data;
    end else begin
        id_rs2_data = rs2_data;
    end
end

reg_id_ex u_id_ex(
    .clk              (clk),
    .rst              (rst),
    .flush            (flush_id_ex),
    .rf_wen_i         (id_rf_wen),
    .fp_rf_wen_i      (id_fp_rf_wen),
    .rs1_sel_i        (id_rs1_sel),
    .rs2_sel_i        (id_rs2_sel),
    .mem_ceb_i        (id_mem_ceb),
    .mem_wen_i        (id_mem_wen),
    .jump_i           (id_jump),
    .branch_i         (id_branch),
    .branch_ctrl_i    (id_branch_ctrl),
    .alu_ctrl_i       (id_alu_ctrl),
    .alu_src1_i       (id_alu_src1),
    .alu_src2_i       (id_alu_src2),
    .fpu_ctrl_i       (id_fpu_ctrl),
    .lsu_ctrl_i       (id_lsu_ctrl),
    .result_src_i     (id_result_src),
    .pc_i             (id_pc),
    .pc_plus_4_i      (id_pc_plus_4),
    .rs1_data_i       (id_rs1_data),
    .rs2_data_i       (id_rs2_data),
    .imm_i            (id_imm),
    .rs1_addr_i       (id_rs1_addr),
    .rs2_addr_i       (id_rs2_addr),
    .rd_addr_i        (id_rd_addr),
    .csr_instret_inc_i(id_csr_instret_inc),
    .csr_addr_i       (id_csr_addr),
    .predict_taken_i  (id_bp_taken),
    .rf_wen_o         (ex_rf_wen),
    .fp_rf_wen_o      (ex_fp_rf_wen),
    .rs1_sel_o        (ex_rs1_sel),
    .rs2_sel_o        (ex_rs2_sel),
    .mem_ceb_o        (ex_mem_ceb),
    .mem_wen_o        (ex_mem_wen),
    .jump_o           (ex_jump),
    .branch_o         (ex_branch),
    .branch_ctrl_o    (ex_branch_ctrl),
    .alu_ctrl_o       (ex_alu_ctrl),
    .alu_src1_o       (ex_alu_src1),
    .alu_src2_o       (ex_alu_src2),
    .fpu_ctrl_o       (ex_fpu_ctrl),
    .lsu_ctrl_o       (ex_lsu_ctrl),
    .result_src_o     (ex_result_src),
    .pc_o             (ex_pc),
    .pc_plus_4_o      (ex_pc_plus_4),
    .rs1_data_o       (ex_rs1_data),
    .rs2_data_o       (ex_rs2_data),
    .imm_o            (ex_imm),
    .rs1_addr_o       (ex_rs1_addr),
    .rs2_addr_o       (ex_rs2_addr),
    .rd_addr_o        (ex_rd_addr),
    .csr_instret_inc_o(ex_csr_instret_inc),
    .csr_addr_o       (ex_csr_addr),
    .predict_taken_o  (ex_bp_taken)
);

////////////////////////////////////////////////////////////////////////////////
// Execute
////////////////////////////////////////////////////////////////////////////////

// Mux for forwarding rs1 data:
//   - rs1 (EX)
//   - ALU result (MEM)
//   - FPU result (MEM)
//   - write-back data (WB)
always_comb begin
    case (forward_a)
        FORWARD_NONE: begin
            ex_rs1_data_fwd = ex_rs1_data;
        end
        FORWARD_FROM_MEM_ALU: begin
            ex_rs1_data_fwd = mem_alu_result;
        end
        FORWARD_FROM_MEM_FPU: begin
            ex_rs1_data_fwd = mem_fpu_result;
        end
        FORWARD_FROM_WB: begin
            ex_rs1_data_fwd = wb_result;
        end
        default: begin
            ex_rs1_data_fwd = ex_rs1_data;
        end
    endcase
end

// Mux for ALU operand a:
//   - rs1
//   - PC
always_comb begin
    if (ex_alu_src1) begin
        ex_alu_a = ex_pc;
    end else begin
        ex_alu_a = ex_rs1_data_fwd;
    end
end

// Mux for forwarding rs2 data:
//   - rs2 (EX)
//   - ALU result (MEM)
//   - FPU result (MEM)
//   - write-back data (WB)
always_comb begin
    case (forward_b)
        FORWARD_NONE: begin
            ex_rs2_data_fwd = ex_rs2_data;
        end
        FORWARD_FROM_MEM_ALU: begin
            ex_rs2_data_fwd = mem_alu_result;
        end
        FORWARD_FROM_MEM_FPU: begin
            ex_rs2_data_fwd = mem_fpu_result;
        end
        FORWARD_FROM_WB: begin
            ex_rs2_data_fwd = wb_result;
        end
        default: begin
            ex_rs2_data_fwd = ex_rs2_data;
        end
    endcase
end

// Mux for ALU operand b:
//   - rs2
//   - immediate
always_comb begin
    if (ex_alu_src2) begin
        ex_alu_b = ex_imm;
    end else begin
        ex_alu_b = ex_rs2_data_fwd;
    end
end

alu u_alu(
    .a_i   (ex_alu_a),
    .b_i   (ex_alu_b),
    .ctrl_i(ex_alu_ctrl),
    .res_o (ex_alu_result)
);

fpu u_fpu(
    .a_i   (ex_rs1_data_fwd),
    .b_i   (ex_rs2_data_fwd),
    .ctrl_i(ex_fpu_ctrl),
    .res_o (ex_fpu_result)
);

branch_comp u_branch_comp(
    .a_i           (ex_rs1_data_fwd),
    .b_i           (ex_rs2_data_fwd),
    .ctrl_i        (ex_branch_ctrl),
    .branch_taken_o(branch_taken)
);

forwarding u_forwarding(
    .rs1_addr_ex_i  (ex_rs1_addr),
    .rs2_addr_ex_i  (ex_rs2_addr),
    .rs1_sel_ex_i   (ex_rs1_sel),
    .rs2_sel_ex_i   (ex_rs2_sel),
    .rd_addr_mem_i  (mem_rd_addr),
    .rf_wen_mem_i   (mem_rf_wen),
    .fp_rf_wen_mem_i(mem_fp_rf_wen),
    .rd_addr_wb_i   (wb_rd_addr),
    .rf_wen_wb_i    (wb_rf_wen),
    .fp_rf_wen_wb_i (wb_fp_rf_wen),
    .forward_a_o    (forward_a),
    .forward_b_o    (forward_b)
);

hazard u_hazard(
    .id_rs1_addr_i  (id_rs1_addr),
    .id_rs2_addr_i  (id_rs2_addr),
    .ex_rd_addr_i   (ex_rd_addr),
    .ex_result_src_i(ex_result_src),
    .jump_i         (ex_jump),
    .branch_taken_i (ex_branch & branch_taken),
    .predict_taken_i(ex_bp_taken),
    .stall_pc_o     (stall_pc),
    .stall_if_id_o  (stall_if_id),
    .flush_if_id_o  (flush_if_id),
    .flush_id_ex_o  (flush_id_ex)
);

csr u_csr(
    .clk              (clk),
    .rst              (rst),
    .csr_instret_inc_i(ex_csr_instret_inc),
    .csr_addr_i       (ex_csr_addr),
    .csr_rdata_o      (ex_csr_rdata)
);

reg_ex_mem u_ex_mem(
    .clk         (clk),
    .rst         (rst),
    .rf_wen_i    (ex_rf_wen),
    .fp_rf_wen_i (ex_fp_rf_wen),
    .mem_ceb_i   (ex_mem_ceb),
    .mem_wen_i   (ex_mem_wen),
    .lsu_ctrl_i  (ex_lsu_ctrl),
    .result_src_i(ex_result_src),
    .alu_result_i(ex_alu_result),
    .fpu_result_i(ex_fpu_result),
    .pc_plus_4_i (ex_pc_plus_4),
    .rs2_data_i  (ex_rs2_data_fwd),
    .rd_addr_i   (ex_rd_addr),
    .csr_rdata_i (ex_csr_rdata),
    .rf_wen_o    (mem_rf_wen),
    .fp_rf_wen_o (mem_fp_rf_wen),
    .mem_ceb_o   (mem_mem_ceb),
    .mem_wen_o   (mem_mem_wen),
    .lsu_ctrl_o  (mem_lsu_ctrl),
    .result_src_o(mem_result_src),
    .alu_result_o(mem_alu_result),
    .fpu_result_o(mem_fpu_result),
    .pc_plus_4_o (mem_pc_plus_4),
    .rs2_data_o  (mem_rs2_data),
    .rd_addr_o   (mem_rd_addr),
    .csr_rdata_o (mem_csr_rdata)
);


////////////////////////////////////////////////////////////////////////////////
// Memory Access
////////////////////////////////////////////////////////////////////////////////

lsu u_lsu(
    .clk        (clk),
    .ctrl_i     (mem_lsu_ctrl),
    .addr_i     (mem_alu_result),
    .ceb_i      (mem_mem_ceb),
    .wen_i      (mem_mem_wen),
    .wdata_i    (mem_rs2_data),
    .rdata_i    (dmem_rdata),
    .mem_ceb_o  (dmem_ceb),
    .mem_wen_o  (dmem_wen),
    .mem_bwe_o  (dmem_bwe),
    .mem_addr_o (dmem_addr),
    .mem_wdata_o(dmem_wdata),
    .mem_rdata_o(wb_mem_rdata)
);

reg_mem_wb u_mem_wb(
    .clk         (clk),
    .rst         (rst),
    .rf_wen_i    (mem_rf_wen),
    .fp_rf_wen_i (mem_fp_rf_wen),
    .result_src_i(mem_result_src),
    .alu_result_i(mem_alu_result),
    .fpu_result_i(mem_fpu_result),
    .rd_addr_i   (mem_rd_addr),
    .pc_plus_4_i (mem_pc_plus_4),
    .csr_rdata_i (mem_csr_rdata),
    .rf_wen_o    (wb_rf_wen),
    .fp_rf_wen_o (wb_fp_rf_wen),
    .result_src_o(wb_result_src),
    .alu_result_o(wb_alu_result),
    .fpu_result_o(wb_fpu_result),
    .rd_addr_o   (wb_rd_addr),
    .pc_plus_4_o (wb_pc_plus_4),
    .csr_rdata_o (wb_csr_rdata)
);


////////////////////////////////////////////////////////////////////////////////
// Write Back
////////////////////////////////////////////////////////////////////////////////

// Mux for write-back data:
//   - PC + 4 (for JAL/JALR)
//   - ALU result
//   - FPU result
//   - Memory read data
//   - CSR read data
always_comb begin
    case (wb_result_src)
        RESULT_SRC_PC_PLUS_4: begin
            wb_result = wb_pc_plus_4;
        end
        RESULT_SRC_ALU: begin
            wb_result = wb_alu_result;
        end
        RESULT_SRC_FPU: begin
            wb_result = wb_fpu_result;
        end
        RESULT_SRC_MEM: begin
            wb_result = wb_mem_rdata;
        end
        RESULT_SRC_CSR: begin
            wb_result = wb_csr_rdata;
        end
        default: begin
            wb_result = 32'd0;
        end
    endcase
end

////////////////////////////////////////////////////////////////////////////////
// Debug
////////////////////////////////////////////////////////////////////////////////

`ifdef DEBUG
opcodeType_e ex_opcode_type;
opcodeType_e mem_opcode_type;
opcodeType_e wb_opcode_type;

always_ff @(posedge clk) begin
    if (rst) begin
        ex_opcode_type <= NOP;
        mem_opcode_type <= NOP;
        wb_opcode_type <= NOP;
    end else begin
        ex_opcode_type <= flush_id_ex ? NOP : id_opcode_type;
        mem_opcode_type <= ex_opcode_type;
        wb_opcode_type <= mem_opcode_type;
    end
end
`endif

endmodule
