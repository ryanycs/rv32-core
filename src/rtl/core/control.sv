`include "types.svh"

module control(
    input  opcodeType_e opcode_type_i,

    output logic        rf_wen_o,
    output logic        fp_rf_wen_o,
    output rfSel_e      rf_rs1_sel_o,
    output rfSel_e      rf_rs2_sel_o,
    output logic        mem_ceb_o,
    output logic        mem_wen_o,
    output logic        jump_o,
    output logic        branch_o,
    output branchCtrl_e branch_ctrl_o,
    output aluCtrl_e    alu_ctrl_o,
    output aluSrc1_e    alu_src1_o,
    output aluSrc2_e    alu_src2_o,
    output fpuCtrl_e    fpu_ctrl_o,
    output lsuCtrl_e    lsu_ctrl_o,
    output resultSrc_e  result_src_o,
    output logic        csr_instret_inc_o
);

always_comb begin
    rf_wen_o          = 1'b0;
    fp_rf_wen_o       = 1'b0;
    rf_rs1_sel_o      = RF_SEL_INT;
    rf_rs2_sel_o      = RF_SEL_INT;
    mem_ceb_o         = 1'b0;
    mem_wen_o         = 1'b0;
    jump_o            = 1'b0;
    branch_o          = 1'b0;
    branch_ctrl_o     = BRANCH_NOP;
    alu_ctrl_o        = ALU_NOP;
    alu_src1_o        = ALU_SRC1_RS1;
    alu_src2_o        = ALU_SRC2_RS2;
    fpu_ctrl_o        = FPU_NOP;
    lsu_ctrl_o        = LSU_NOP;
    result_src_o      = RESULT_SRC_ALU;
    csr_instret_inc_o = 1'b1;

    case (opcode_type_i)
        ADDI: begin
            rf_wen_o     = 1'b1;
            alu_ctrl_o   = ALU_ADD;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_IMM;
            result_src_o = RESULT_SRC_ALU;
        end

        SLLI: begin
            rf_wen_o     = 1'b1;
            alu_ctrl_o   = ALU_SLL;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_IMM;
            result_src_o = RESULT_SRC_ALU;
        end

        SLTI: begin
            rf_wen_o     = 1'b1;
            alu_ctrl_o   = ALU_SLT;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_IMM;
            result_src_o = RESULT_SRC_ALU;
        end

        SLTIU: begin
            rf_wen_o     = 1'b1;
            alu_ctrl_o   = ALU_SLTU;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_IMM;
            result_src_o = RESULT_SRC_ALU;
        end

        XORI: begin
            rf_wen_o     = 1'b1;
            alu_ctrl_o   = ALU_XOR;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_IMM;
            result_src_o = RESULT_SRC_ALU;
        end

        SRLI: begin
            rf_wen_o     = 1'b1;
            alu_ctrl_o   = ALU_SRL;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_IMM;
            result_src_o = RESULT_SRC_ALU;
        end

        SRAI: begin
            rf_wen_o     = 1'b1;
            alu_ctrl_o   = ALU_SRA;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_IMM;
            result_src_o = RESULT_SRC_ALU;
        end

        ORI: begin
            rf_wen_o     = 1'b1;
            alu_ctrl_o   = ALU_OR;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_IMM;
            result_src_o = RESULT_SRC_ALU;
        end

        ANDI: begin
            rf_wen_o     = 1'b1;
            alu_ctrl_o   = ALU_AND;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_IMM;
            result_src_o = RESULT_SRC_ALU;
        end

        LUI: begin
            rf_wen_o     = 1'b1;
            alu_ctrl_o   = ALU_LUI;
            alu_src2_o   = ALU_SRC2_IMM;
            result_src_o = RESULT_SRC_ALU;
        end

        AUIPC: begin
            rf_wen_o     = 1'b1;
            alu_ctrl_o   = ALU_ADD;
            alu_src1_o   = ALU_SRC1_PC;
            alu_src2_o   = ALU_SRC2_IMM;
            result_src_o = RESULT_SRC_ALU;
        end

        ADD: begin
            rf_wen_o     = 1'b1;
            alu_ctrl_o   = ALU_ADD;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_RS2;
            result_src_o = RESULT_SRC_ALU;
        end

        SUB: begin
            rf_wen_o     = 1'b1;
            alu_ctrl_o   = ALU_SUB;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_RS2;
            result_src_o = RESULT_SRC_ALU;
        end

        SLL: begin
            rf_wen_o     = 1'b1;
            alu_ctrl_o   = ALU_SLL;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_RS2;
            result_src_o = RESULT_SRC_ALU;
        end

        SLT: begin
            rf_wen_o     = 1'b1;
            alu_ctrl_o   = ALU_SLT;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_RS2;
            result_src_o = RESULT_SRC_ALU;
        end

        SLTU: begin
            rf_wen_o     = 1'b1;
            alu_ctrl_o   = ALU_SLTU;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_RS2;
            result_src_o = RESULT_SRC_ALU;
        end

        XOR: begin
            rf_wen_o     = 1'b1;
            alu_ctrl_o   = ALU_XOR;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_RS2;
            result_src_o = RESULT_SRC_ALU;
        end

        SRL: begin
            rf_wen_o     = 1'b1;
            alu_ctrl_o   = ALU_SRL;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_RS2;
            result_src_o = RESULT_SRC_ALU;
        end

        SRA: begin
            rf_wen_o     = 1'b1;
            alu_ctrl_o   = ALU_SRA;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_RS2;
            result_src_o = RESULT_SRC_ALU;
        end

        OR: begin
            rf_wen_o     = 1'b1;
            alu_ctrl_o   = ALU_OR;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_RS2;
            result_src_o = RESULT_SRC_ALU;
        end

        AND: begin
            rf_wen_o     = 1'b1;
            alu_ctrl_o   = ALU_AND;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_RS2;
            result_src_o = RESULT_SRC_ALU;
        end

        JAL: begin
            rf_wen_o     = 1'b1;
            jump_o       = 1'b1;
            alu_ctrl_o   = ALU_ADD;
            alu_src1_o   = ALU_SRC1_PC;
            alu_src2_o   = ALU_SRC2_IMM;
            result_src_o = RESULT_SRC_PC_PLUS_4;
        end

        JALR: begin
            rf_wen_o     = 1'b1;
            jump_o       = 1'b1;
            alu_ctrl_o   = ALU_ADD;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_IMM;
            result_src_o = RESULT_SRC_PC_PLUS_4;
        end

        BEQ: begin
            branch_o      = 1'b1;
            branch_ctrl_o = BRANCH_EQ;
            alu_ctrl_o    = ALU_ADD;
            alu_src1_o    = ALU_SRC1_PC;
            alu_src2_o    = ALU_SRC2_IMM;
        end

        BNE: begin
            branch_o      = 1'b1;
            branch_ctrl_o = BRANCH_NE;
            alu_ctrl_o    = ALU_ADD;
            alu_src1_o    = ALU_SRC1_PC;
            alu_src2_o    = ALU_SRC2_IMM;
        end

        BLT: begin
            branch_o      = 1'b1;
            branch_ctrl_o = BRANCH_LT;
            alu_ctrl_o    = ALU_ADD;
            alu_src1_o    = ALU_SRC1_PC;
            alu_src2_o    = ALU_SRC2_IMM;
        end

        BGE: begin
            branch_o      = 1'b1;
            branch_ctrl_o = BRANCH_GE;
            alu_ctrl_o    = ALU_ADD;
            alu_src1_o    = ALU_SRC1_PC;
            alu_src2_o    = ALU_SRC2_IMM;
        end

        BLTU: begin
            branch_o      = 1'b1;
            branch_ctrl_o = BRANCH_LTU;
            alu_ctrl_o    = ALU_ADD;
            alu_src1_o    = ALU_SRC1_PC;
            alu_src2_o    = ALU_SRC2_IMM;
        end

        BGEU: begin
            branch_o      = 1'b1;
            branch_ctrl_o = BRANCH_GEU;
            alu_ctrl_o    = ALU_ADD;
            alu_src1_o    = ALU_SRC1_PC;
            alu_src2_o    = ALU_SRC2_IMM;
        end

        LB: begin
            rf_wen_o     = 1'b1;
            mem_ceb_o    = 1'b1;
            alu_ctrl_o   = ALU_ADD;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_IMM;
            lsu_ctrl_o   = LSU_LB;
            result_src_o = RESULT_SRC_MEM;
        end

        LH: begin
            rf_wen_o     = 1'b1;
            mem_ceb_o    = 1'b1;
            alu_ctrl_o   = ALU_ADD;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_IMM;
            lsu_ctrl_o   = LSU_LH;
            result_src_o = RESULT_SRC_MEM;
        end

        LW: begin
            rf_wen_o     = 1'b1;
            mem_ceb_o    = 1'b1;
            alu_ctrl_o   = ALU_ADD;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_IMM;
            lsu_ctrl_o   = LSU_LW;
            result_src_o = RESULT_SRC_MEM;
        end

        LBU: begin
            rf_wen_o     = 1'b1;
            mem_ceb_o    = 1'b1;
            alu_ctrl_o   = ALU_ADD;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_IMM;
            lsu_ctrl_o   = LSU_LBU;
            result_src_o = RESULT_SRC_MEM;
        end

        LHU: begin
            rf_wen_o     = 1'b1;
            mem_ceb_o    = 1'b1;
            alu_ctrl_o   = ALU_ADD;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_IMM;
            lsu_ctrl_o   = LSU_LHU;
            result_src_o = RESULT_SRC_MEM;
        end

        SB: begin
            mem_ceb_o  = 1'b1;
            mem_wen_o  = 1'b1;
            alu_ctrl_o = ALU_ADD;
            alu_src1_o = ALU_SRC1_RS1;
            alu_src2_o = ALU_SRC2_IMM;
            lsu_ctrl_o = LSU_SB;
        end

        SH: begin
            mem_ceb_o  = 1'b1;
            mem_wen_o  = 1'b1;
            alu_ctrl_o = ALU_ADD;
            alu_src1_o = ALU_SRC1_RS1;
            alu_src2_o = ALU_SRC2_IMM;
            lsu_ctrl_o = LSU_SH;
        end

        SW: begin
            mem_ceb_o  = 1'b1;
            mem_wen_o  = 1'b1;
            alu_ctrl_o = ALU_ADD;
            alu_src1_o = ALU_SRC1_RS1;
            alu_src2_o = ALU_SRC2_IMM;
            lsu_ctrl_o = LSU_SW;
        end

        MUL: begin
        end

        MULH: begin
        end

        MULHSU: begin
        end

        MULHU: begin
        end

        FADD: begin
            fp_rf_wen_o  = 1'b1;
            rf_rs1_sel_o = RF_SEL_FP;
            rf_rs2_sel_o = RF_SEL_FP;
            fpu_ctrl_o   = FPU_ADD;
            result_src_o = RESULT_SRC_FPU;
        end

        FSUB: begin
            fp_rf_wen_o  = 1'b1;
            rf_rs1_sel_o = RF_SEL_FP;
            rf_rs2_sel_o = RF_SEL_FP;
            fpu_ctrl_o   = FPU_SUB;
            result_src_o = RESULT_SRC_FPU;
        end

        FLW: begin
            fp_rf_wen_o  = 1'b1;
            mem_ceb_o    = 1'b1;
            alu_ctrl_o   = ALU_ADD;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_IMM;
            lsu_ctrl_o   = LSU_LW;
            result_src_o = RESULT_SRC_MEM;
        end

        FSW: begin
            rf_rs2_sel_o = RF_SEL_FP;
            mem_ceb_o    = 1'b1;
            mem_wen_o    = 1'b1;
            alu_ctrl_o   = ALU_ADD;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_IMM;
            lsu_ctrl_o   = LSU_SW;
        end

        CSRRS: begin
            rf_wen_o     = 1'b1;
            result_src_o = RESULT_SRC_CSR;
        end

        default: begin
            csr_instret_inc_o = 1'b0;
        end
    endcase
end

endmodule
