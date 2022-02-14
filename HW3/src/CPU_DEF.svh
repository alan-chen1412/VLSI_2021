`ifndef CPU_SVH
`define CPU_SVH

// Define SRAM bit
`define SRAM_DATA_BITS 32
`define SRAM_ADDR_BITS 14
`define SRAM_WRITE_BITS 4

// Define CPU bit

`define PC_BITS 32
`define CPU_DATA_BITS 32

//Define Type instruction
`define OPCODE_BITS 7
`define R_TYPE `OPCODE_BITS'b0110011
`define I_TYPE `OPCODE_BITS'b0010011
`define L_TYPE `OPCODE_BITS'b0000011
`define JALR   `OPCODE_BITS'b1100111
`define S_TYPE `OPCODE_BITS'b0100011
`define B_TYPE `OPCODE_BITS'b1100011
`define AUIPC  `OPCODE_BITS'b0010111
`define LUI    `OPCODE_BITS'b0110111
`define J_TYPE `OPCODE_BITS'b1101111

//Define Imm_type
`define IMM_TYPE_BITS 3
`define IMM_I_TYPE `IMM_TYPE_BITS'b0
`define IMM_S_TYPE `IMM_TYPE_BITS'b1
`define IMM_B_TYPE `IMM_TYPE_BITS'b10
`define IMM_U_TYPE `IMM_TYPE_BITS'b11
`define IMM_J_TYPE `IMM_TYPE_BITS'b100

//Define ALUOP
`define ALUOP_BITS 2
`define ALUOP_R_TYPE `ALUOP_BITS'b0
`define ALUOP_ADD    `ALUOP_BITS'b1
`define ALUOP_B_TYPE `ALUOP_BITS'b10
`define ALUOP_LUI    `ALUOP_BITS'b11

//Define Jump
`define JUMP_BITS 2
`define JUMP_NEXT `JUMP_BITS'b0
`define JUMP_IMM  `JUMP_BITS'b1
`define JUMP_REG  `JUMP_BITS'b10
`define JUMP_BRA  `JUMP_BITS'b11

//Define Branch
`define BRANCH_BITS 2
`define BRANCH_NEXT `BRANCH_BITS'b0
`define BRANCH_IMM  `BRANCH_BITS'b1
`define BRANCH_REG  `BRANCH_BITS'b10
`define BRANCH_EXP  `BRANCH_BITS'b11

//Define ALUCtrl
`define ALUCTRL_BITS 4
`define ALU_ADD   `ALUCTRL_BITS'b0
`define ALU_SUB   `ALUCTRL_BITS'b1
`define ALU_SLL   `ALUCTRL_BITS'b10
`define ALU_SLT   `ALUCTRL_BITS'b11
`define ALU_XOR   `ALUCTRL_BITS'b100
`define ALU_SRL   `ALUCTRL_BITS'b101
`define ALU_OR    `ALUCTRL_BITS'b110
`define ALU_AND   `ALUCTRL_BITS'b111
`define ALU_IMM   `ALUCTRL_BITS'b1000
`define ALU_SLTU  `ALUCTRL_BITS'b1001
`define ALU_SRA   `ALUCTRL_BITS'b1010

//Define Forward src
`define FORWARD_BITS 2
`define FORWARD_REG `FORWARD_BITS'b0
`define FORWARD_MEM `FORWARD_BITS'b1
`define FORWARD_WB  `FORWARD_BITS'b10


//Define LW type
`define LW_TYPE_BITS 3
`define LW_WORD   `LW_TYPE_BITS'b010
`define LW_S_BYTE `LW_TYPE_BITS'b000
`define LW_HWORD_S `LW_TYPE_BITS'b001
`define LW_HWORD_U `LW_TYPE_BITS'b101
`define LW_U_BYTE `LW_TYPE_BITS'b100
//Define SW type
`define SW_TYPE_BITS 3
`define SW_WORD `SW_TYPE_BITS'b010
`define SW_BYTE `SW_TYPE_BITS'b000
`define SW_HWORD `SW_TYPE_BITS'b001

`endif