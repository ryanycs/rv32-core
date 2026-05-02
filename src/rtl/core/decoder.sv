`include "types.svh"

module decoder(
    input  logic        [31:0] inst_i,
    output logic        [4:0]  rs1_addr_o,
    output logic        [4:0]  rs2_addr_o,
    output logic        [4:0]  rd_addr_o,
    output logic        [11:0] csr_addr_o,
    output immType_e           imm_type_o,
    output opcodeType_e        opcode_type_o
);

// Register-Immediate
localparam OPCODE_OP_IMM = 7'b0010011;
localparam OPCODE_LUI    = 7'b0110111;
localparam OPCODE_AUIPC  = 7'b0010111;

// Register-Register
localparam OPCODE_OP     = 7'b0110011;

// Control Transfer
localparam OPCODE_JAL    = 7'b1101111;
localparam OPCODE_JALR   = 7'b1100111;
localparam OPCODE_BRANCH = 7'b1100011;

// Load/Store
localparam OPCODE_LOAD   = 7'b0000011;
localparam OPCODE_STORE  = 7'b0100011;

// System
localparam OPCODE_SYSTEM = 7'b1110011;

// Floating Point Operations
localparam OPCODE_LOAD_FP  = 7'b0000111;
localparam OPCODE_STORE_FP = 7'b0100111;
localparam OPCODE_OP_FP    = 7'b1010011;

logic [6:0]  funct7;
logic [2:0]  funct3;
logic [6:0]  opcode;

assign funct7     = inst_i[31:25];
assign funct3     = inst_i[14:12];
assign opcode     = inst_i[6:0];

assign rs2_addr_o = inst_i[24:20];
assign rs1_addr_o = inst_i[19:15];
assign rd_addr_o  = inst_i[11:7];
assign csr_addr_o = inst_i[31:20];

// imm_type
always_comb begin
    case (opcode)
        OPCODE_OP_IMM, OPCODE_LOAD, OPCODE_JALR: begin
            imm_type_o = I_TYPE;
        end
        OPCODE_STORE: begin
            imm_type_o = S_TYPE;
        end
        OPCODE_BRANCH: begin
            imm_type_o = B_TYPE;
        end
        OPCODE_AUIPC, OPCODE_LUI: begin
            imm_type_o = U_TYPE;
        end
        OPCODE_JAL: begin
            imm_type_o = J_TYPE;
        end
        default: begin
            imm_type_o = I_TYPE;
        end
    endcase
end

always_comb begin
    unique casez ({ opcode, funct3, funct7 })
        { OPCODE_OP_IMM, 3'b000, 7'b??????? }: opcode_type_o = ADDI;
        { OPCODE_OP_IMM, 3'b001, 7'b0000000 }: opcode_type_o = SLLI;
        { OPCODE_OP_IMM, 3'b010, 7'b??????? }: opcode_type_o = SLTI;
        { OPCODE_OP_IMM, 3'b011, 7'b??????? }: opcode_type_o = SLTIU;
        { OPCODE_OP_IMM, 3'b100, 7'b??????? }: opcode_type_o = XORI;
        { OPCODE_OP_IMM, 3'b101, 7'b0000000 }: opcode_type_o = SRLI;
        { OPCODE_OP_IMM, 3'b101, 7'b0100000 }: opcode_type_o = SRAI;
        { OPCODE_OP_IMM, 3'b110, 7'b??????? }: opcode_type_o = ORI;
        { OPCODE_OP_IMM, 3'b111, 7'b??????? }: opcode_type_o = ANDI;

        { OPCODE_LUI   , 3'b???, 7'b??????? }: opcode_type_o = LUI;

        { OPCODE_AUIPC , 3'b???, 7'b??????? }: opcode_type_o = AUIPC;

        { OPCODE_OP    , 3'b000, 7'b0000000 }: opcode_type_o = ADD;
        { OPCODE_OP    , 3'b000, 7'b0100000 }: opcode_type_o = SUB;
        { OPCODE_OP    , 3'b001, 7'b0000000 }: opcode_type_o = SLL;
        { OPCODE_OP    , 3'b010, 7'b0000000 }: opcode_type_o = SLT;
        { OPCODE_OP    , 3'b011, 7'b0000000 }: opcode_type_o = SLTU;
        { OPCODE_OP    , 3'b100, 7'b0000000 }: opcode_type_o = XOR;
        { OPCODE_OP    , 3'b101, 7'b0000000 }: opcode_type_o = SRL;
        { OPCODE_OP    , 3'b101, 7'b0100000 }: opcode_type_o = SRA;
        { OPCODE_OP    , 3'b110, 7'b0000000 }: opcode_type_o = OR;
        { OPCODE_OP    , 3'b111, 7'b0000000 }: opcode_type_o = AND;

        { OPCODE_JAL   , 3'b???, 7'b??????? }: opcode_type_o = JAL;

        { OPCODE_JALR  , 3'b???, 7'b??????? }: opcode_type_o = JALR;

        { OPCODE_BRANCH, 3'b000, 7'b??????? }: opcode_type_o = BEQ;
        { OPCODE_BRANCH, 3'b001, 7'b??????? }: opcode_type_o = BNE;
        { OPCODE_BRANCH, 3'b100, 7'b??????? }: opcode_type_o = BLT;
        { OPCODE_BRANCH, 3'b101, 7'b??????? }: opcode_type_o = BGE;
        { OPCODE_BRANCH, 3'b110, 7'b??????? }: opcode_type_o = BLTU;
        { OPCODE_BRANCH, 3'b111, 7'b??????? }: opcode_type_o = BGEU;

        { OPCODE_LOAD  , 3'b000, 7'b??????? }: opcode_type_o = LB;
        { OPCODE_LOAD  , 3'b001, 7'b??????? }: opcode_type_o = LH;
        { OPCODE_LOAD  , 3'b010, 7'b??????? }: opcode_type_o = LW;
        { OPCODE_LOAD  , 3'b100, 7'b??????? }: opcode_type_o = LBU;
        { OPCODE_LOAD  , 3'b101, 7'b??????? }: opcode_type_o = LHU;

        { OPCODE_STORE , 3'b000, 7'b??????? }: opcode_type_o = SB;
        { OPCODE_STORE , 3'b001, 7'b??????? }: opcode_type_o = SH;
        { OPCODE_STORE , 3'b010, 7'b??????? }: opcode_type_o = SW;

        // M extension
        { OPCODE_OP    , 3'b000, 7'b0000001 }: opcode_type_o = MUL;
        { OPCODE_OP    , 3'b001, 7'b0000001 }: opcode_type_o = MULH;
        { OPCODE_OP    , 3'b010, 7'b0000001 }: opcode_type_o = MULHSU;
        { OPCODE_OP    , 3'b011, 7'b0000001 }: opcode_type_o = MULHU;

        // F extension
        { OPCODE_OP_FP   , 3'b???, 7'b00000?? }: opcode_type_o = FADD;
        { OPCODE_OP_FP   , 3'b???, 7'b00001?? }: opcode_type_o = FSUB;
        { OPCODE_LOAD_FP , 3'b010, 7'b??????? }: opcode_type_o = FLW;
        { OPCODE_STORE_FP, 3'b010, 7'b??????? }: opcode_type_o = FSW;

        // Zicsr extension
        { OPCODE_SYSTEM, 3'b010, 7'b??????? }: opcode_type_o = CSRRS;

        default:
            opcode_type_o = NOP;
    endcase
end

endmodule
