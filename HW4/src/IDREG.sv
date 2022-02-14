`include "CPU_DEF.svh"
`include "interface.sv"
module IDREG(
    input clk,
    input rst,
    input IDRegWrite,
    input ID_flush,
    IDEXE_REG.ID ID,
    IDEXE_REG.EXE EXE
);

always_ff@(posedge clk or posedge rst) begin
    if(rst) begin
        EXE.funct3     <= 3'b0;
        EXE.funct7     <= 7'b0;
        EXE.PCtoRegSrc <= 1'b0;
        EXE.ALUSrc     <= 1'b0;
        EXE.RDSrc      <= 1'b0;
        EXE.MemRead    <= 1'b0;
        EXE.MemWrite   <= 1'b0;
        EXE.MemtoReg   <= 1'b0;
        EXE.rs1_data   <= `CPU_DATA_BITS'b0;
        EXE.rs2_data   <= `CPU_DATA_BITS'b0;
        EXE.rd         <= 5'b0;
        EXE.rs1_addr   <= 5'b0;
        EXE.rs2_addr   <= 5'b0;
        EXE.imm        <= `CPU_DATA_BITS'b0;
        EXE.RegWrite   <= 1'b0;
        EXE.shamt      <= 5'b0;
        EXE.ALUop      <= `ALUOP_BITS'b0;
        EXE.i_type     <= 1'b0;
        EXE.JumpType   <= `JUMP_NEXT;
        EXE.lw_type    <= `LW_WORD;
        EXE.sw_type    <= `SW_WORD;
        EXE.PC         <= `PC_BITS'b0;
        EXE.CSR        <= 1'b0;
        EXE.CSR_write  <= 1'b0;  
        EXE.CSR_set    <= 1'b0; 
        EXE.CSR_clear  <= 1'b0; 
        EXE.CSR_ret    <= 1'b0;
        EXE.CSR_wait   <= 1'b0;
        EXE.CSR_addr   <= 12'b0;
    end
    else if (IDRegWrite)begin
        EXE.PC         <= (ID_flush) ? 32'b0 : ID.PC;
        EXE.funct3     <= (ID_flush) ? 3'b0 :ID.funct3;
        EXE.funct7     <= (ID_flush) ? 7'b0 :ID.funct7;
        EXE.PCtoRegSrc <= (ID_flush) ? 1'b0 :ID.PCtoRegSrc;
        EXE.ALUSrc     <= (ID_flush) ? 1'b0 :ID.ALUSrc;
        EXE.RDSrc      <= (ID_flush) ? 1'b0 :ID.RDSrc;
        EXE.MemRead    <= (ID_flush) ? 1'b0 : ID.MemRead;
        EXE.MemWrite   <= (ID_flush) ? 1'b0 : ID.MemWrite;
        EXE.RegWrite   <= (ID_flush) ? 1'b0 : ID.RegWrite;
        EXE.MemtoReg   <= ID.MemtoReg;
        EXE.rs1_data   <= (ID_flush) ? 32'b0: ID.rs1_data;
        EXE.rs2_data   <= (ID_flush) ? 32'b0: ID.rs2_data;
        EXE.rd         <= (ID_flush) ? 5'b0 :ID.rd;
        EXE.rs1_addr   <= (ID_flush) ? 5'b0 :ID.rs1_addr;
        EXE.rs2_addr   <= (ID_flush) ? 5'b0 :ID.rs2_addr;
        EXE.imm        <= (ID_flush) ? 32'b0 :ID.imm;
        EXE.shamt      <= (ID_flush) ? 5'b0 :ID.shamt;
        EXE.ALUop      <= (ID_flush) ? `ALUOP_BITS'b0:ID.ALUop;
        EXE.i_type     <= (ID_flush) ? 1'b0 :ID.i_type;
        EXE.JumpType   <= (ID_flush)? `JUMP_NEXT:ID.JumpType;
        EXE.lw_type    <= (ID_flush)? `LW_WORD:ID.lw_type;
        EXE.sw_type    <= (ID_flush)? `SW_WORD:ID.sw_type;
        EXE.CSR        <= (ID_flush)? 1'b0: ID.CSR      ;
        EXE.CSR_write  <= (ID_flush)? 1'b0 :ID.CSR_write;  
        EXE.CSR_set    <= (ID_flush)? 1'b0 :ID.CSR_set  ; 
        EXE.CSR_clear  <= (ID_flush)? 1'b0 :ID.CSR_clear; 
        EXE.CSR_ret    <= (ID_flush)? 1'b0 :ID.CSR_ret  ;
        EXE.CSR_wait   <= (ID_flush)? 1'b0 :ID.CSR_wait ;
        EXE.CSR_addr   <= (ID_flush)? 12'b0 :ID.CSR_addr;
    end
end

endmodule
