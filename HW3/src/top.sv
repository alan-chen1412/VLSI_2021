`include "CPU_DEF.svh"
`include "SRAM_wrapper.sv"
`include "AXI.sv"
`include "CPU_wrapper.sv"
module top(
    input clk,
    input rst
);

logic latch_rst;
AXI_master_p master0();
AXI_master_p master1();
AXI_slave_p slave0();
AXI_slave_p slave1();



always_ff@(posedge clk or posedge rst) begin
    if(rst) latch_rst <= rst;
    else latch_rst <= rst; 
end

AXI AXI(
	.ACLK(clk),
	.ARESETn(~latch_rst),
    .master0(master0),
    .master1(master1),
    .slave0(slave0),
    .slave1(slave1)
);
CPU_wrapper CPU_wrapper(
        .master0(master0),
        .master1(master1),
        .clk(clk),
        .rst(~latch_rst)
);

SRAM_wrapper IM1(
        .slave(slave0),
        .clk(clk),
        .rst(~latch_rst)
);

SRAM_wrapper DM1(
        .slave(slave1),
        .clk(clk),
        .rst(~latch_rst)
);
endmodule
