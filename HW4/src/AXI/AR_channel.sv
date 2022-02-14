`include "AXI_define.svh"
module AR_channel(
    input clk,
    input rst,

	input [`AXI_ID_BITS-1:0   ]ARID_M0,
	input [`AXI_ADDR_BITS-1:0 ]ARADDR_M0,
	input [`AXI_LEN_BITS-1:0  ]ARLEN_M0,
	input [`AXI_SIZE_BITS-1:0 ]ARSIZE_M0,
	input [`AXI_BURST_BITS-1:0]ARBURST_M0,
	input ARVALID_M0,
    output logic ARREADY_M0,

	input [`AXI_ID_BITS-1:0   ]ARID_M1,
	input [`AXI_ADDR_BITS-1:0 ]ARADDR_M1,
	input [`AXI_LEN_BITS-1:0  ]ARLEN_M1,
	input [`AXI_SIZE_BITS-1:0 ]ARSIZE_M1,
	input [`AXI_BURST_BITS-1:0]ARBURST_M1,
	input ARVALID_M1,
    output logic ARREADY_M1,

	input [`AXI_ID_BITS-1:0   ]ARID_M2,
	input [`AXI_ADDR_BITS-1:0 ]ARADDR_M2,
	input [`AXI_LEN_BITS-1:0  ]ARLEN_M2,
	input [`AXI_SIZE_BITS-1:0 ]ARSIZE_M2,
	input [`AXI_BURST_BITS-1:0]ARBURST_M2,
	input ARVALID_M2,
    output logic ARREADY_M2,
	
    input ARREADY_S0,
	output logic [`AXI_IDS_BITS-1:0] ARID_S0,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S0,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S0,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S0,
	output logic [1:0] ARBURST_S0,
	output logic ARVALID_S0,

    input ARREADY_S1,
	output logic [`AXI_IDS_BITS-1:0] ARID_S1,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S1,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S1,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S1,
	output logic [1:0] ARBURST_S1,
	output logic ARVALID_S1,
    
    input ARREADY_S2,
	output logic [`AXI_IDS_BITS-1:0] ARID_S2,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S2,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S2,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S2,
	output logic [1:0] ARBURST_S2,
	output logic ARVALID_S2,
    
    input ARREADY_S3,
	output logic [`AXI_IDS_BITS-1:0] ARID_S3,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S3,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S3,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S3,
	output logic [1:0] ARBURST_S3,
	output logic ARVALID_S3,
    
    input ARREADY_S4,
	output logic [`AXI_IDS_BITS-1:0] ARID_S4,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S4,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S4,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S4,
	output logic [1:0] ARBURST_S4,
	output logic ARVALID_S4,
    
    input ARREADY_S5,
	output logic [`AXI_IDS_BITS-1:0] ARID_S5,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S5,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S5,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S5,
	output logic [1:0] ARBURST_S5,
	output logic ARVALID_S5,
    
    input ARREADY_S6,
	output logic [`AXI_IDS_BITS-1:0] ARID_S6,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S6,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S6,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S6,
	output logic [1:0] ARBURST_S6,
	output logic ARVALID_S6
);

logic [`AXI_ID_BITS-1:0   ]ARID;
logic [`AXI_ADDR_BITS-1:0 ]ARADDR;
logic [`AXI_LEN_BITS-1:0  ]ARLEN;
logic [`AXI_SIZE_BITS-1:0 ]ARSIZE;
logic [`AXI_BURST_BITS-1:0]ARBURST;
logic ARVALID;
logic ARREADY;
logic [`AXI_MASTER_BITS-1:0] Master;

assign ARID_S0 = {Master,ARID};
assign ARADDR_S0 = ARADDR;
assign ARLEN_S0 = ARLEN;
assign ARSIZE_S0 = ARSIZE;
assign ARBURST_S0 = ARBURST;

assign ARID_S1 = {Master,ARID};
assign ARADDR_S1 = ARADDR;
assign ARLEN_S1 = ARLEN;
assign ARSIZE_S1 = ARSIZE;
assign ARBURST_S1 = ARBURST;

assign ARID_S2 = {Master,ARID};
assign ARADDR_S2 = ARADDR;
assign ARLEN_S2 = ARLEN;
assign ARSIZE_S2 = ARSIZE;
assign ARBURST_S2 = ARBURST;

assign ARID_S3 = {Master,ARID};
assign ARADDR_S3 = ARADDR;
assign ARLEN_S3 = ARLEN;
assign ARSIZE_S3 = ARSIZE;
assign ARBURST_S3 = ARBURST;


assign ARID_S4 = {Master,ARID};
assign ARADDR_S4 = ARADDR;
assign ARLEN_S4 = ARLEN;
assign ARSIZE_S4 = ARSIZE;
assign ARBURST_S4 = ARBURST;

assign ARID_S5 = {Master,ARID};
assign ARADDR_S5 = ARADDR;
assign ARLEN_S5 = ARLEN;
assign ARSIZE_S5 = ARSIZE;
assign ARBURST_S5 = ARBURST;

assign ARID_S6 = {Master,ARID};
assign ARADDR_S6 = ARADDR;
assign ARLEN_S6 = ARLEN;
assign ARSIZE_S6 = ARSIZE;
assign ARBURST_S6 = ARBURST;

Decoder AR_decoder(
    .ADDR    (ARADDR    ),
    .READY_S0(ARREADY_S0),
    .READY_S1(ARREADY_S1),
    .READY_S2(ARREADY_S2),
    .READY_S3(ARREADY_S3),
    .READY_S4(ARREADY_S4),
    .READY_S5(ARREADY_S5),
    .READY_S6(ARREADY_S6),
    .VALID_S0(ARVALID_S0),
    .VALID_S1(ARVALID_S1),
    .VALID_S2(ARVALID_S2),
    .VALID_S3(ARVALID_S3),
    .VALID_S4(ARVALID_S4),
    .VALID_S5(ARVALID_S5),
    .VALID_S6(ARVALID_S6),
    .READY   (ARREADY    ),
    .VALID   (ARVALID   ),
    .clk(clk),
    .rst(rst)
);

Arbiter AR_Arbiter(
    .clk(clk),
    .rst(rst),
	.ID_M0   (ARID_M0   ),
	.ADDR_M0 (ARADDR_M0 ),
	.LEN_M0  (ARLEN_M0  ),
	.SIZE_M0 (ARSIZE_M0 ),
	.BURST_M0(ARBURST_M0),
	.VALID_M0(ARVALID_M0),
	.ID_M1   (ARID_M1   ),
	.ADDR_M1 (ARADDR_M1 ),
	.LEN_M1  (ARLEN_M1  ),
	.SIZE_M1 (ARSIZE_M1 ),
	.BURST_M1(ARBURST_M1),
	.VALID_M1(ARVALID_M1),
	.ID_M2   (ARID_M2   ),
	.ADDR_M2 (ARADDR_M2 ),
	.LEN_M2  (ARLEN_M2  ),
	.SIZE_M2 (ARSIZE_M2 ),
	.BURST_M2(ARBURST_M2),
	.VALID_M2(ARVALID_M2),
    	.ID      (ARID      ),
    	.ADDR    (ARADDR    ),
    	.LEN     (ARLEN     ),
    	.SIZE    (ARSIZE    ),
    	.BURST   (ARBURST   ),
    	.VALID   (ARVALID   ),
    	.READY   (ARREADY   ),
    	.READY_M0(ARREADY_M0),
    	.READY_M1(ARREADY_M1),
    	.READY_M2(ARREADY_M2),
    	.Master(Master)
);

endmodule
