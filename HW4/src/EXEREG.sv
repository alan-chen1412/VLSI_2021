`include "CPU_DEF.svh"
`include "interface.sv"
module EXEREG(
    input clk,
    input rst,
    input EXERegWrite,
    input MEM_flush,
    EXEMEM_REG.EXE EXE,
    EXEMEM_REG.MEM MEM
);

always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        MEM.PCtoReg          <= `CPU_DATA_BITS'b0;
        MEM.ALUout           <= `CPU_DATA_BITS'b0;
        MEM.forward_rs2_data <= `CPU_DATA_BITS'b0;
        MEM.rd_addr          <= 5'b0;
        MEM.RDsrc            <= 1'b0;
        MEM.Memread          <= 1'b0;
        MEM.Memwrite         <= 1'b0;
        MEM.MemtoReg         <= 1'b0;
        MEM.RegWrite         <= 1'b0;
        MEM.lw_type          <= `LW_WORD;
        MEM.sw_type          <= `SW_WORD;
    end
    else if(MEM_flush) begin
        MEM.Memwrite <= 1'b0;
        MEM.Memread <= 1'b0;
    end
    else if (EXERegWrite) begin
        MEM.RegWrite         <= EXE.RegWrite;
        MEM.PCtoReg          <= EXE.PCtoReg;
        MEM.ALUout           <= EXE.ALUout;
        MEM.forward_rs2_data <= EXE.forward_rs2_data;
        MEM.rd_addr          <= EXE.rd_addr;
        MEM.RDsrc            <= EXE.RDsrc;
        MEM.Memread          <= EXE.Memread;
        MEM.Memwrite         <= EXE.Memwrite;       
        MEM.MemtoReg         <= EXE.MemtoReg;
        MEM.lw_type          <= EXE.lw_type;
        MEM.sw_type          <= EXE.sw_type;
        MEM.pc <= EXE.pc;
    end
end


endmodule
