`include "CPU_DEF.svh"

module MEMREG(
    input clk,
    input rst,
    input MEMRegWrite,
    MEMWB_REG.MEM MEM,
    MEMWB_REG.WB WB
);

always_ff @(posedge clk or posedge rst) begin
    if(rst)begin
        WB.Memtoreg <= 1'b0;
        WB.rd_data  <= `CPU_DATA_BITS'b0;
        WB.rd_addr  <= 5'b0;
        WB.mem_data <= `SRAM_DATA_BITS'b0;   
        WB.RegWrite <= 1'b0; 
    end
    else if(MEMRegWrite) begin
        WB.Memtoreg <= MEM.Memtoreg; 
        WB.rd_data  <= MEM.rd_data;
        WB.rd_addr  <= MEM.rd_addr;
        WB.mem_data <= MEM.mem_data;
        WB.RegWrite <= MEM.RegWrite; 
    end
end

endmodule
