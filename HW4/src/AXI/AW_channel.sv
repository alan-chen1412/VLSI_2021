`include "AXI_define.svh"

module AW_channel(
    input clk,
    input rst,

	input [`AXI_ID_BITS-1:0   ]AWID_M0,
	input [`AXI_ADDR_BITS-1:0 ]AWADDR_M0,
	input [`AXI_LEN_BITS-1:0  ]AWLEN_M0,
	input [`AXI_SIZE_BITS-1:0 ]AWSIZE_M0,
	input [`AXI_BURST_BITS-1:0]AWBURST_M0,
	input AWVALID_M0,
    output logic AWREADY_M0,

	input [`AXI_ID_BITS-1:0   ]AWID_M1,
	input [`AXI_ADDR_BITS-1:0 ]AWADDR_M1,
	input [`AXI_LEN_BITS-1:0  ]AWLEN_M1,
	input [`AXI_SIZE_BITS-1:0 ]AWSIZE_M1,
	input [`AXI_BURST_BITS-1:0]AWBURST_M1,
	input AWVALID_M1,
    output logic AWREADY_M1,

	input [`AXI_ID_BITS-1:0   ]AWID_M2,
	input [`AXI_ADDR_BITS-1:0 ]AWADDR_M2,
	input [`AXI_LEN_BITS-1:0  ]AWLEN_M2,
	input [`AXI_SIZE_BITS-1:0 ]AWSIZE_M2,
	input [`AXI_BURST_BITS-1:0]AWBURST_M2,
	input AWVALID_M2,
    output logic AWREADY_M2,
	
    input AWREADY_S0,
	output logic [`AXI_IDS_BITS-1:0] AWID_S0,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S0,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S0,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S0,
	output logic [1:0] AWBURST_S0,
	output logic AWVALID_S0,

    input AWREADY_S1,
	output logic [`AXI_IDS_BITS-1:0] AWID_S1,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S1,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S1,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S1,
	output logic [1:0] AWBURST_S1,
	output logic AWVALID_S1,
    
    input AWREADY_S2,
	output logic [`AXI_IDS_BITS-1:0] AWID_S2,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S2,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S2,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S2,
	output logic [1:0] AWBURST_S2,
	output logic AWVALID_S2,
    
    input AWREADY_S3,
	output logic [`AXI_IDS_BITS-1:0] AWID_S3,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S3,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S3,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S3,
	output logic [1:0] AWBURST_S3,
	output logic AWVALID_S3,
    
    input AWREADY_S4,
	output logic [`AXI_IDS_BITS-1:0] AWID_S4,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S4,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S4,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S4,
	output logic [1:0] AWBURST_S4,
	output logic AWVALID_S4,
    
    input AWREADY_S5,
	output logic [`AXI_IDS_BITS-1:0] AWID_S5,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S5,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S5,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S5,
	output logic [1:0] AWBURST_S5,
	output logic AWVALID_S5,
    
    input AWREADY_S6,
	output logic [`AXI_IDS_BITS-1:0] AWID_S6,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S6,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S6,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S6,
	output logic [1:0] AWBURST_S6,
	output logic AWVALID_S6,

    output logic [`AXI_MASTER_BITS-1:0] Master,
    output logic [`AXI_SLAVE_BITS-1:0] slave
);

logic [`AXI_ID_BITS-1:0   ]AWID;
logic [`AXI_ADDR_BITS-1:0 ]AWADDR;
logic [`AXI_LEN_BITS-1:0  ]AWLEN;
logic [`AXI_SIZE_BITS-1:0 ]AWSIZE;
logic [`AXI_BURST_BITS-1:0]AWBURST;
logic AWVALID;
logic AWREADY;
logic AWVALID_S0_tmp;
logic AWVALID_S1_tmp;
logic AWVALID_S2_tmp;
logic AWVALID_S3_tmp;
logic AWVALID_S4_tmp;
logic AWVALID_S5_tmp;
logic AWVALID_S6_tmp;


assign slave = {AWVALID_S6_tmp,AWVALID_S5_tmp,AWVALID_S4_tmp,AWVALID_S3_tmp,AWVALID_S2_tmp,AWVALID_S1_tmp,AWVALID_S0_tmp};
assign {AWVALID_S6,AWVALID_S5,AWVALID_S4,AWVALID_S3,AWVALID_S2,AWVALID_S1} = slave[`AXI_SLAVE_BITS-1:1];
assign AWVALID_S0 = AWVALID_S0_tmp;

assign AWID_S0 = {Master,AWID};
assign AWADDR_S0 = AWADDR;
assign AWLEN_S0 = AWLEN;
assign AWSIZE_S0 = AWSIZE;
assign AWBURST_S0 = AWBURST;

assign AWID_S1 = {Master,AWID};
assign AWADDR_S1 = AWADDR;
assign AWLEN_S1 = AWLEN;
assign AWSIZE_S1 = AWSIZE;
assign AWBURST_S1 = AWBURST;

assign AWID_S2 = {Master,AWID};
assign AWADDR_S2 = AWADDR;
assign AWLEN_S2 = AWLEN;
assign AWSIZE_S2 = AWSIZE;
assign AWBURST_S2 = AWBURST;

assign AWID_S3 = {Master,AWID};
assign AWADDR_S3 = AWADDR;
assign AWLEN_S3 = AWLEN;
assign AWSIZE_S3 = AWSIZE;
assign AWBURST_S3 = AWBURST;


assign AWID_S4 = {Master,AWID};
assign AWADDR_S4 = AWADDR;
assign AWLEN_S4 = AWLEN;
assign AWSIZE_S4 = AWSIZE;
assign AWBURST_S4 = AWBURST;

assign AWID_S5 = {Master,AWID};
assign AWADDR_S5 = AWADDR;
assign AWLEN_S5 = AWLEN;
assign AWSIZE_S5 = AWSIZE;
assign AWBURST_S5 = AWBURST;

assign AWID_S6 = {Master,AWID};
assign AWADDR_S6 = AWADDR;
assign AWLEN_S6 = AWLEN;
assign AWSIZE_S6 = AWSIZE;
assign AWBURST_S6 = AWBURST;

Decoder AW_decoder(
    .ADDR    (AWADDR    ),
    .READY_S0(AWREADY_S0),
    .READY_S1(AWREADY_S1),
    .READY_S2(AWREADY_S2),
    .READY_S3(AWREADY_S3),
    .READY_S4(AWREADY_S4),
    .READY_S5(AWREADY_S5),
    .READY_S6(AWREADY_S6),
    .VALID_S0(AWVALID_S0_tmp),
    .VALID_S1(AWVALID_S1_tmp),
    .VALID_S2(AWVALID_S2_tmp),
    .VALID_S3(AWVALID_S3_tmp),
    .VALID_S4(AWVALID_S4_tmp),
    .VALID_S5(AWVALID_S5_tmp),
    .VALID_S6(AWVALID_S6_tmp),
    .READY   (AWREADY    ),
    .VALID   (AWVALID   ), 
    .clk(clk),
    .rst(rst)
);

Arbiter AW_Arbiter(
    .clk(clk),
    .rst(rst),
	.ID_M0   (AWID_M0   ),
	.ADDR_M0 (AWADDR_M0 ),
	.LEN_M0  (AWLEN_M0  ),
	.SIZE_M0 (AWSIZE_M0 ),
	.BURST_M0(AWBURST_M0),
	.VALID_M0(AWVALID_M0),
	.ID_M1   (AWID_M1   ),
	.ADDR_M1 (AWADDR_M1 ),
	.LEN_M1  (AWLEN_M1  ),
	.SIZE_M1 (AWSIZE_M1 ),
	.BURST_M1(AWBURST_M1),
	.VALID_M1(AWVALID_M1),
	.ID_M2   (AWID_M2   ),
	.ADDR_M2 (AWADDR_M2 ),
	.LEN_M2  (AWLEN_M2  ),
	.SIZE_M2 (AWSIZE_M2 ),
	.BURST_M2(AWBURST_M2),
	.VALID_M2(AWVALID_M2),
    .ID      (AWID      ),
    .ADDR    (AWADDR    ),
    .LEN     (AWLEN     ),
    .SIZE    (AWSIZE    ),
    .BURST   (AWBURST   ),
    .VALID   (AWVALID   ),
    .READY   (AWREADY   ),
    .READY_M0(AWREADY_M0),
    .READY_M1(AWREADY_M1),
    .READY_M2(AWREADY_M2),
    .Master(Master)
);

endmodule
