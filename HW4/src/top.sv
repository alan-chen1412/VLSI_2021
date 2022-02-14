`include "CPU_DEF.svh"
`include "SRAM_wrapper.sv"
`include "AXI.sv"
`include "CPU_wrapper.sv"
`include "DRAM_wrapper.sv"
`include "rom_wrapper.sv"
`include "sensor_wrapper.sv"
`include "DMA.sv"
module top(
    input clk,
    input rst,
    input sensor_ready,
    input [31:0]sensor_out,
    input [31:0]ROM_out,
    input [31:0] DRAM_Q,
    input DRAM_valid,
    output logic ROM_read,
    output logic ROM_enable,
    output logic [13:0]ROM_address,
    output logic sensor_en,
    output logic DRAM_CSn,
    output logic [3:0] DRAM_WEn,
    output logic DRAM_RASn,
    output logic DRAM_CASn,
    output logic [10:0] DRAM_A,
    output logic [31:0] DRAM_D

);

logic latch_rst;
logic sensor_interrupt;
AXI_master_p master0();
AXI_master_p master1();
AXI_master_p master2();
AXI_slave_p slave0();
AXI_slave_p slave1();
AXI_slave_p slave2();
AXI_slave_p slave3();
AXI_slave_p slave4();
AXI_slave_p slave5();
logic ROM_read_r;
logic ROM_enable_r;
logic [13:0]ROM_address_r;
logic sensor_en_r;
logic DRAM_CSn_r;
logic [3:0] DRAM_WEn_r;
logic DRAM_RASn_r;
logic DRAM_CASn_r;
logic [10:0] DRAM_A_r;
logic [31:0] DRAM_D_r;

always_ff@(posedge clk or posedge rst) begin
	if(rst) begin
DRAM_CSn <= 1'b1;
DRAM_WEn <= 4'hf;
DRAM_RASn <= 1'b1;
DRAM_CASn <= 1'b1;
DRAM_A <= 11'b0;
DRAM_D <= 32'b0;
	end
	else begin
DRAM_CSn  <=DRAM_CSn_r   ;
DRAM_WEn  <=DRAM_WEn_r   ;
DRAM_RASn <=DRAM_RASn_r  ;
DRAM_CASn <=DRAM_CASn_r  ;
DRAM_A    <=DRAM_A_r     ;
DRAM_D    <=DRAM_D_r     ;
	end
end

always_ff@(posedge clk or posedge rst) begin
    if(rst) latch_rst <= rst;
    else latch_rst <= rst; 
end

AXI AXI(
	.ACLK(clk),
	.ARESETn(~latch_rst),
    .master0(master0),
    .master1(master1),
    .master2(master2),
    .slave0(slave0),
    .slave1(slave1),
    .slave2(slave2),
    .slave3(slave3),
    .slave4(slave4),
    .slave5(slave5)
);

rom_wrapper rom_wrapper(
    .clk(clk),
    .rst(~latch_rst),
    .slave(slave0),
    .ROM_out(ROM_out),
    .ROM_read(ROM_read),
    .ROM_enable(ROM_enable),
    .ROM_address(ROM_address)
);

DRAM_wrapper dram_wrapper(
    .slave(slave4),
    .DRAM_Q(DRAM_Q),
	.DRAM_valid(DRAM_valid),
    .clk(clk),
    .rst(~latch_rst),
    .DRAM_CSn(DRAM_CSn_r),
    .DRAM_WEn(DRAM_WEn_r),
    .DRAM_RASn(DRAM_RASn_r),
    .DRAM_CASn(DRAM_CASn_r),
    .DRAM_A(DRAM_A_r),
    .DRAM_D(DRAM_D_r)
);

sensor_wrapper sensor_wrapper(
    .clk(clk),
    .rst(~latch_rst),
    .slave(slave3),
    .sensor_ready(sensor_ready),
    .sensor_out(sensor_out),
    .sensor_en(sensor_en),
    .sensor_interrupt(sensor_interrupt)

);

CPU_wrapper CPU_wrapper(
        .interrupt(sensor_interrupt),
        .master0(master0),
        .master1(master1),
        .clk(clk),
        .rst(~latch_rst)
);

SRAM_wrapper IM1(
        .slave(slave1),
        .clk(clk),
        .rst(~latch_rst)
);

SRAM_wrapper DM1(
        .slave(slave2),
        .clk(clk),
        .rst(~latch_rst)
);
DMA dma(
    .clk(clk),
    .rst(~latch_rst),
    .master(master2),
    .slave(slave5)
);
endmodule
