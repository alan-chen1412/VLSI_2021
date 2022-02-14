`include "CPU_DEF.svh"
module IDREG(
    input clk,
    input rst,
    input IDRegWrite,
    input ID_flush,
    input [2:0] ID_funct3,
    input [6:0] ID_funct7,
    input ID_PCtoRegSrc,
    input ID_ALUSrc,
    input ID_RDSrc,
    input ID_MemRead,
    input ID_MemWrite,
    input ID_MemtoReg,
    input [`CPU_DATA_BITS-1:0] ID_rs1_data,
    input [`CPU_DATA_BITS-1:0] ID_rs2_data,
    input [4:0] ID_rd,
    input [4:0] ID_rs1_addr,
    input [4:0] ID_rs2_addr,
    input [`CPU_DATA_BITS-1:0] ID_imm,
    input ID_RegWrite,
    input [4:0] ID_shamt,
    input [`ALUOP_BITS-1:0] ID_ALUop,
    input ID_i_type,
    input [`JUMP_BITS-1:0]ID_JumpType,
    input [`LW_TYPE_BITS-1:0 ] ID_lw_type,
    input [`LW_TYPE_BITS-1:0 ] ID_sw_type,
    input [`PC_BITS-1:0      ] ID_PC,
    output logic [`PC_BITS-1:0      ] EXE_PC,
    output logic [2:0               ] EXE_funct3,
    output logic [6:0               ] EXE_funct7,
    output logic                      EXE_PCtoRegSrc,
    output logic                      EXE_ALUSrc,
    output logic                      EXE_RDSrc,
    output logic                      EXE_MemRead,
    output logic                      EXE_MemWrite,
    output logic                      EXE_MemtoReg,
    output logic [`CPU_DATA_BITS-1:0] EXE_rs1_data,
    output logic [`CPU_DATA_BITS-1:0] EXE_rs2_data,
    output logic [4:0               ] EXE_rd,
    output logic [4:0               ] EXE_rs1_addr,
    output logic [4:0               ] EXE_rs2_addr,
    output logic [`CPU_DATA_BITS-1:0] EXE_imm,
    output logic                      EXE_RegWrite,
    output logic [4:0               ] EXE_shamt,
    output logic [`ALUOP_BITS-1:0   ] EXE_ALUop,
    output logic                      EXE_i_type,
    output logic [`JUMP_BITS-1:0    ] EXE_JumpType,
    output logic [`LW_TYPE_BITS-1:0 ] EXE_lw_type,
    output logic [`LW_TYPE_BITS-1:0 ] EXE_sw_type
);

always_ff@(posedge clk or posedge rst) begin
    if(rst) begin
        EXE_funct3 <= 3'b0;
        EXE_funct7 <= 7'b0;
        EXE_PCtoRegSrc <= 1'b0;
        EXE_ALUSrc <= 1'b0;
        EXE_RDSrc <= 1'b0;
        EXE_MemRead <= 1'b0;
        EXE_MemWrite <= 1'b0;
        EXE_MemtoReg <= 1'b0;
        EXE_rs1_data <= `CPU_DATA_BITS'b0;
        EXE_rs2_data <= `CPU_DATA_BITS'b0;
        EXE_rd <= 5'b0;
        EXE_rs1_addr <= 5'b0;
        EXE_rs2_addr <= 5'b0;
        EXE_imm <= `CPU_DATA_BITS'b0;
        EXE_RegWrite <= 1'b0;
        EXE_shamt <= 5'b0;
        EXE_ALUop <= `ALUOP_BITS'b0;
        EXE_i_type <= 1'b0;
        EXE_JumpType <= `JUMP_NEXT;
        EXE_lw_type <= `LW_WORD;
        EXE_sw_type <= `SW_WORD;
        EXE_PC      <= `PC_BITS'b0;
    end
    else if (IDRegWrite)begin
        EXE_PC         <= ID_PC;
        EXE_funct3     <= ID_funct3;
        EXE_funct7     <= ID_funct7;
        EXE_PCtoRegSrc <= ID_PCtoRegSrc;
        EXE_ALUSrc     <= ID_ALUSrc;
        EXE_RDSrc      <= ID_RDSrc;
        EXE_MemRead    <= (ID_flush) ? 1'b0 : ID_MemRead;
        EXE_MemWrite   <= (ID_flush) ? 1'b0 : ID_MemWrite;
        EXE_RegWrite   <= (ID_flush) ? 1'b0 : ID_RegWrite;
        EXE_MemtoReg   <= ID_MemtoReg;
        EXE_rs1_data   <= ID_rs1_data;
        EXE_rs2_data   <= ID_rs2_data;
        EXE_rd         <= ID_rd;
        EXE_rs1_addr   <= ID_rs1_addr;
        EXE_rs2_addr   <= ID_rs2_addr;
        EXE_imm        <= ID_imm;
        EXE_shamt      <= ID_shamt;
        EXE_ALUop      <= ID_ALUop;
        EXE_i_type     <= ID_i_type;
        EXE_JumpType   <= (ID_flush)? `JUMP_NEXT:ID_JumpType;
        EXE_lw_type    <= ID_lw_type;
        EXE_sw_type    <= ID_sw_type;
    end
end

endmodule
