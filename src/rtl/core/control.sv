`include "types.svh"

module control(
    input  opcodeType_e opcode_type_i,

    output logic        reg_wen_o,
    output logic        mem_wen_o,
    output logic        jump_o,
    output logic        branch_o,
    output branchCtrl_e branch_ctrl_o,
    output aluCtrl_e    alu_ctrl_o,
    output aluSrc1_e    alu_src1_o,
    output aluSrc2_e    alu_src2_o,
    output lsuCtrl_e    lsu_ctrl_o,
    output resultSrc_e  result_src_o,
    output logic        csr_instret_inc_o
);

always_comb begin
    reg_wen_o         = 1'b0;
    mem_wen_o         = 1'b0;
    jump_o            = 1'b0;
    branch_o          = 1'b0;
    branch_ctrl_o     = BRANCH_NOP;
    alu_ctrl_o        = ALU_NOP;
    alu_src1_o        = ALU_SRC1_RS1;
    alu_src2_o        = ALU_SRC2_RS2;
    lsu_ctrl_o        = LSU_NOP;
    result_src_o      = RESULT_SRC_ALU;
    csr_instret_inc_o = 1'b1;

    case (opcode_type_i)
        ADDI: begin
            reg_wen_o    = 1'b1;
            alu_ctrl_o   = ALU_ADD;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_IMM;
            result_src_o = RESULT_SRC_ALU;
        end

        SLLI: begin
            reg_wen_o    = 1'b1;
            alu_ctrl_o   = ALU_SLL;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_IMM;
            result_src_o = RESULT_SRC_ALU;
        end

        SLTI: begin
            reg_wen_o    = 1'b1;
            alu_ctrl_o   = ALU_SLT;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_IMM;
            result_src_o = RESULT_SRC_ALU;
        end

        SLTIU: begin
            reg_wen_o    = 1'b1;
            alu_ctrl_o   = ALU_SLTU;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_IMM;
            result_src_o = RESULT_SRC_ALU;
        end

        XORI: begin
            reg_wen_o    = 1'b1;
            alu_ctrl_o   = ALU_XOR;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_IMM;
            result_src_o = RESULT_SRC_ALU;
        end

        SRLI: begin
            reg_wen_o    = 1'b1;
            alu_ctrl_o   = ALU_SRL;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_IMM;
            result_src_o = RESULT_SRC_ALU;
        end

        SRAI: begin
            reg_wen_o    = 1'b1;
            alu_ctrl_o   = ALU_SRA;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_IMM;
            result_src_o = RESULT_SRC_ALU;
        end

        ORI: begin
            reg_wen_o    = 1'b1;
            alu_ctrl_o   = ALU_OR;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_IMM;
            result_src_o = RESULT_SRC_ALU;
        end

        ANDI: begin
            reg_wen_o    = 1'b1;
            alu_ctrl_o   = ALU_AND;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_IMM;
            result_src_o = RESULT_SRC_ALU;
        end

        LUI: begin
            reg_wen_o    = 1'b1;
            alu_ctrl_o   = ALU_LUI;
            alu_src2_o   = ALU_SRC2_IMM;
            result_src_o = RESULT_SRC_ALU;
        end

        AUIPC: begin
            reg_wen_o    = 1'b1;
            alu_ctrl_o   = ALU_ADD;
            alu_src1_o   = ALU_SRC1_PC;
            alu_src2_o   = ALU_SRC2_IMM;
            result_src_o = RESULT_SRC_ALU;
        end

        ADD: begin
            reg_wen_o    = 1'b1;
            alu_ctrl_o   = ALU_ADD;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_RS2;
            result_src_o = RESULT_SRC_ALU;
        end

        SUB: begin
            reg_wen_o    = 1'b1;
            alu_ctrl_o   = ALU_SUB;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_RS2;
            result_src_o = RESULT_SRC_ALU;
        end

        SLL: begin
            reg_wen_o    = 1'b1;
            alu_ctrl_o   = ALU_SLL;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_RS2;
            result_src_o = RESULT_SRC_ALU;
        end

        SLT: begin
            reg_wen_o    = 1'b1;
            alu_ctrl_o   = ALU_SLT;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_RS2;
            result_src_o = RESULT_SRC_ALU;
        end

        SLTU: begin
            reg_wen_o    = 1'b1;
            alu_ctrl_o   = ALU_SLTU;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_RS2;
            result_src_o = RESULT_SRC_ALU;
        end

        XOR: begin
            reg_wen_o    = 1'b1;
            alu_ctrl_o   = ALU_XOR;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_RS2;
            result_src_o = RESULT_SRC_ALU;
        end

        SRL: begin
            reg_wen_o    = 1'b1;
            alu_ctrl_o   = ALU_SRL;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_RS2;
            result_src_o = RESULT_SRC_ALU;
        end

        SRA: begin
            reg_wen_o    = 1'b1;
            alu_ctrl_o   = ALU_SRA;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_RS2;
            result_src_o = RESULT_SRC_ALU;
        end

        OR: begin
            reg_wen_o    = 1'b1;
            alu_ctrl_o   = ALU_OR;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_RS2;
            result_src_o = RESULT_SRC_ALU;
        end

        AND: begin
            reg_wen_o    = 1'b1;
            alu_ctrl_o   = ALU_AND;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_RS2;
            result_src_o = RESULT_SRC_ALU;
        end

        JAL: begin
            reg_wen_o    = 1'b1;
            jump_o       = 1'b1;
            alu_ctrl_o   = ALU_ADD;
            alu_src1_o   = ALU_SRC1_PC;
            alu_src2_o   = ALU_SRC2_IMM;
            result_src_o = RESULT_SRC_PC_PLUS_4;
        end

        JALR: begin
            reg_wen_o    = 1'b1;
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
            reg_wen_o    = 1'b1;
            alu_ctrl_o   = ALU_ADD;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_IMM;
            lsu_ctrl_o   = LSU_LB;
            result_src_o = RESULT_SRC_MEM;
        end

        LH: begin
            reg_wen_o    = 1'b1;
            alu_ctrl_o   = ALU_ADD;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_IMM;
            lsu_ctrl_o   = LSU_LH;
            result_src_o = RESULT_SRC_MEM;
        end

        LW: begin
            reg_wen_o    = 1'b1;
            alu_ctrl_o   = ALU_ADD;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_IMM;
            lsu_ctrl_o   = LSU_LW;
            result_src_o = RESULT_SRC_MEM;
        end

        LBU: begin
            reg_wen_o    = 1'b1;
            alu_ctrl_o   = ALU_ADD;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_IMM;
            lsu_ctrl_o   = LSU_LBU;
            result_src_o = RESULT_SRC_MEM;
        end

        LHU: begin
            reg_wen_o    = 1'b1;
            alu_ctrl_o   = ALU_ADD;
            alu_src1_o   = ALU_SRC1_RS1;
            alu_src2_o   = ALU_SRC2_IMM;
            lsu_ctrl_o   = LSU_LHU;
            result_src_o = RESULT_SRC_MEM;
        end

        SB: begin
            mem_wen_o  = 1'b1;
            alu_ctrl_o = ALU_ADD;
            alu_src1_o = ALU_SRC1_RS1;
            alu_src2_o = ALU_SRC2_IMM;
            lsu_ctrl_o = LSU_SB;
        end

        SH: begin
            mem_wen_o  = 1'b1;
            alu_ctrl_o = ALU_ADD;
            alu_src1_o = ALU_SRC1_RS1;
            alu_src2_o = ALU_SRC2_IMM;
            lsu_ctrl_o = LSU_SH;
        end

        SW: begin
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
        end

        FSUB: begin
        end

        FLW: begin
        end

        FSW: begin
        end

        CSRRS: begin
            reg_wen_o    = 1'b1;
            result_src_o = RESULT_SRC_CSR;
        end

        default: begin
            csr_instret_inc_o = 1'b0;
        end
    endcase
end

endmodule
