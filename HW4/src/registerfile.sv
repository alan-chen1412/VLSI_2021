`include "CPU_DEF.svh"
module registerfile(
    input clk,
    input rst,
    input [4:0] ID_rs1_addr,
    input [4:0] ID_rs2_addr,
    input [4:0] WB_rd_addr,
    input       WB_RegWrite,
    input [`CPU_DATA_BITS-1:0] WB_rd_data,
    output logic [`CPU_DATA_BITS-1:0] ID_rs1_data,
    output logic [`CPU_DATA_BITS-1:0] ID_rs2_data 
);

integer i;
logic not_zero;
logic [`CPU_DATA_BITS-1:0]  register[31:0];
assign not_zero = |WB_rd_addr;

assign ID_rs1_data = ((ID_rs1_addr == WB_rd_addr) & WB_RegWrite & not_zero) ? WB_rd_data:register[ID_rs1_addr];
assign ID_rs2_data = ((ID_rs2_addr == WB_rd_addr) & WB_RegWrite & not_zero) ? WB_rd_data:register[ID_rs2_addr];

always_ff @(posedge clk or posedge rst) begin
    if(rst)  begin
        for(i=0;i<32;i=i+1) 
            register[i] <= `CPU_DATA_BITS'b0;
    end
    else if (WB_RegWrite & not_zero) begin
        register[WB_rd_addr] <= WB_rd_data;
    end 
end


endmodule
