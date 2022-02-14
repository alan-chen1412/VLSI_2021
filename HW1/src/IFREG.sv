`include "CPU_DEF.svh"
module IFREG(
    input clk,
    input rst,
    input [`PC_BITS-1:0] IF_pc,
    input [`SRAM_DATA_BITS-1:0] IF_instr,
    input IF_reg_Write,
    output logic [`PC_BITS-1:0] ID_pc,
    output logic [`SRAM_DATA_BITS-1:0] ID_instr
);

always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        ID_pc <= `PC_BITS'b0;
        ID_instr <= `SRAM_DATA_BITS'b0;
    end
    else if (IF_reg_Write) begin
        ID_pc <= IF_pc;
        ID_instr <= IF_instr;
    end
end

endmodule
