`include "CPU_DEF.svh"
module EXEREG(
    input clk,
    input rst,
    input EXERegWrite,
    input [`PC_BITS-1:0        ] EXE_PCtoReg,
    input [`CPU_DATA_BITS-1:0  ] EXE_ALUout,
    input [`CPU_DATA_BITS-1:0  ] EXE_forward_rs2_data,
    input [4:0                 ] EXE_rd_addr,
    input                        EXE_RDsrc,
    input                        EXE_Memread,
    input                        EXE_Memwrite,
    input                        EXE_MemtoReg,
    input                        EXE_RegWrite,
    input [`LW_TYPE_BITS-1:0   ] EXE_lw_type,
    input [`LW_TYPE_BITS-1:0   ] EXE_sw_type,
    input MEM_flush,
    output logic [`PC_BITS-1:0        ] MEM_PCtoReg,
    output logic [`CPU_DATA_BITS-1:0  ] MEM_ALUout,
    output logic [`CPU_DATA_BITS-1:0  ] MEM_forward_rs2_data,
    output logic [4:0                 ] MEM_rd_addr,
    output logic                        MEM_RDsrc,
    output logic                        MEM_Memread,
    output logic                        MEM_Memwrite,
    output logic                        MEM_MemtoReg,
    output logic                        MEM_RegWrite,
    output logic [`LW_TYPE_BITS-1:0   ] MEM_lw_type,
    output logic [`LW_TYPE_BITS-1:0   ] MEM_sw_type
);

always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        MEM_PCtoReg          <= `CPU_DATA_BITS'b0;
        MEM_ALUout           <= `CPU_DATA_BITS'b0;
        MEM_forward_rs2_data <= `CPU_DATA_BITS'b0;
        MEM_rd_addr          <= 5'b0;
        MEM_RDsrc            <= 1'b0;
        MEM_Memread          <= 1'b0;
        MEM_Memwrite         <= 1'b0;
        MEM_MemtoReg         <= 1'b0;
        MEM_RegWrite         <= 1'b0;
        MEM_lw_type          <= `LW_WORD;
        MEM_sw_type          <= `SW_WORD;
    end
    else if (EXERegWrite) begin
        MEM_RegWrite         <= EXE_RegWrite;
        MEM_PCtoReg          <= EXE_PCtoReg;
        MEM_ALUout           <= EXE_ALUout;
        MEM_forward_rs2_data <= EXE_forward_rs2_data;
        MEM_rd_addr          <= EXE_rd_addr;
        MEM_RDsrc            <= EXE_RDsrc;
        MEM_Memread          <= EXE_Memread;
        MEM_Memwrite         <= EXE_Memwrite;       
        MEM_MemtoReg         <= EXE_MemtoReg;
        MEM_lw_type          <= EXE_lw_type;
        MEM_sw_type          <= EXE_sw_type;
    end
    else if (MEM_flush) begin
        MEM_Memread          <= 1'b0;
        MEM_Memwrite         <= 1'b0;       
    end
end


endmodule
