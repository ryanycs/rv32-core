`ifndef TYPES_SVH
`define TYPES_SVH

typedef enum logic [2:0] {
    I_TYPE,
    S_TYPE,
    B_TYPE,
    U_TYPE,
    J_TYPE
} immType_e;


typedef enum logic [5:0] {
    // R-Type (10 ops)
    ADD, SUB,
    AND, OR, XOR,
    SLL, SRL, SRA,
    SLT, SLTU,

    // I-Type (15 ops)
    ADDI,
    ANDI, ORI, XORI,
    SLLI, SRLI, SRAI, SLTI, SLTIU,
    JALR,
    LW, LH, LHU, LB, LBU,

    // S-Type (3 ops)
    SW, SB, SH,

    // U-Type (2 ops)
    AUIPC, LUI,

    // J-Type (1 op)
    JAL,

    // B-Type (6 ops)
    BEQ, BNE, BLT, BGE, BLTU, BGEU,

    // M Extension
    MUL, MULH, MULHSU, MULHU,

    // F Extension
    FLW, FSW,
    FADD, FSUB,

    // Zicsr Extension
    CSRRS,

    NOP // Note: This is not a real opcode, just a placeholder
} opcodeType_e;


typedef enum logic [4:0] {
    ALU_NOP,
    ALU_ADD,
    ALU_SUB,
    ALU_AND,
    ALU_OR,
    ALU_XOR,
    ALU_SLL,
    ALU_SRL,
    ALU_SRA,
    ALU_SLT,
    ALU_SLTU,
    ALU_LUI,
    ALU_MUL,
    ALU_MULH,
    ALU_MULHSU,
    ALU_MULHU
} aluCtrl_e;


typedef enum logic {
    ALU_SRC1_RS1,
    ALU_SRC1_PC
} aluSrc1_e;


typedef enum logic {
    ALU_SRC2_RS2,
    ALU_SRC2_IMM
} aluSrc2_e;


typedef enum logic [2:0] {
    BRANCH_NOP,
    BRANCH_EQ,
    BRANCH_NE,
    BRANCH_LT,
    BRANCH_GE,
    BRANCH_LTU,
    BRANCH_GEU
} branchCtrl_e;


typedef enum logic [1:0] {
    FORWARD_NONE,
    FORWARD_FROM_WB,
    FORWARD_FROM_MEM_ALU,
    FORWARD_FROM_MEM_FPU
} forwardCtrl_e;


typedef enum logic [3:0] {
    LSU_NOP,
    LSU_LB,
    LSU_LH,
    LSU_LW,
    LSU_LBU,
    LSU_LHU,
    LSU_SB,
    LSU_SH,
    LSU_SW
} lsuCtrl_e;


typedef enum logic [1:0] {
    PC_SRC_PC_PLUS_4,
    PC_SRC_ALU_RESULT,
    PC_SRC_BTB,
    PC_SRC_MISPREDICT
} pcSrc_e;


typedef enum logic [2:0] {
    RESULT_SRC_ALU,
    RESULT_SRC_MEM,
    RESULT_SRC_PC_PLUS_4,
    RESULT_SRC_CSR,
    RESULT_SRC_FPU
} resultSrc_e;


typedef enum logic [11:0] {
    CSR_CYCLE    = 12'hC00,
    CSR_CYCLEH   = 12'hC80,
    CSR_INSTRET  = 12'hC02,
    CSR_INSTRETH = 12'hC82
} csrAddr_e;


typedef enum logic {
    RF_SEL_INT,
    RF_SEL_FP
} rfSel_e;


typedef enum logic [1:0] {
    FPU_NOP,
    FPU_ADD,
    FPU_SUB
} fpuCtrl_e;

`endif // TYPES_SVH
