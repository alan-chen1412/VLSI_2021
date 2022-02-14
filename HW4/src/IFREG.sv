`include "CPU_DEF.svh"
`include "interface.sv"
module IFREG(
    input clk,
    input rst,
    input IF_reg_Write,
    IFID_REG.ID ID,
    IFID_REG.IF IF
);

always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        ID.pc <= `PC_BITS'b0;
        ID.instr <= `SRAM_DATA_BITS'b0;
    end
    else if (IF_reg_Write) begin
        ID.pc <= IF.pc;
        ID.instr <= IF.instr;
    end
end

endmodule
