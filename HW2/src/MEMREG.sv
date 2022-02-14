`include "CPU_DEF.svh"

module MEMREG(
    input clk,
    input rst,
    input                       MEMRegWrite,
    input                       MEM_Memtoreg,
    input [`CPU_DATA_BITS-1:0 ] MEM_rd_data,
    input [`SRAM_DATA_BITS-1:0] MEM_mem_data,
    input [4:0                ] MEM_rd_addr,
    input                       MEM_RegWrite,
    output logic                       WB_Memtoreg,
    output logic [`CPU_DATA_BITS-1:0 ] WB_rd_data,
    output logic [4:0                ] WB_rd_addr,
    output logic [`SRAM_DATA_BITS-1:0] WB_mem_data,
    output logic                       WB_RegWrite
);

always_ff @(posedge clk or posedge rst) begin
    if(rst)begin
        WB_Memtoreg <= 1'b0;
        WB_rd_data  <= `CPU_DATA_BITS'b0;
        WB_rd_addr  <= 5'b0;
        WB_mem_data <= `SRAM_DATA_BITS'b0;   
        WB_RegWrite <= 1'b0; 
    end
    else if(MEMRegWrite) begin
        WB_Memtoreg <= MEM_Memtoreg; 
        WB_rd_data  <= MEM_rd_data;
        WB_rd_addr  <= MEM_rd_addr;
        WB_mem_data <= MEM_mem_data;
        WB_RegWrite <= MEM_RegWrite; 
    end
end

endmodule
