//================================================
// Auther:      Chang Wan-Yun (Claire)            
// Filename:    AXI.sv                            
// Description: Top module of AXI                  
// Version:     1.0 
//================================================
`include "AXI_define.svh"
`include "AR.sv"
`include "AW.sv"
`include "DW.sv"
`include "Default_Slave.sv"
`include "RW.sv"
`include "DR.sv"
`include "AXI_slave.sv"
`include "AXI_master.sv"

module AXI(
	input ACLK,
	input ARESETn,
    AXI_master_p.bridge master0,
    AXI_master_p.bridge master1,
    AXI_slave_p.bridge slave0,
    AXI_slave_p.bridge slave1
);
    //---------- you should put your design here ----------//

logic [`AXI_MASTER_BITS-1:0] MASTER;
// default Slave
logic [`AXI_IDS_BITS-1:0 ] ARID_DEFAULT;
logic [`AXI_ADDR_BITS-1:0] ARADDR_DEFAULT;
logic [`AXI_LEN_BITS-1:0 ] ARLEN_DEFAULT;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_DEFAULT;
logic [1:0               ] ARBURST_DEFAULT;
logic                      ARVALID_DEFAULT;
logic                      ARREADY_DEFAULT;

logic [`AXI_IDS_BITS-1:0 ] AWID_DEFAULT;
logic [`AXI_ADDR_BITS-1:0] AWADDR_DEFAULT;
logic [`AXI_LEN_BITS-1:0 ] AWLEN_DEFAULT;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_DEFAULT;
logic [1:0               ] AWBURST_DEFAULT;
logic                      AWVALID_DEFAULT;
logic                      AWREADY_DEFAULT;


logic [`AXI_DATA_BITS-1:0] WDATA_DEFAULT;
logic [`AXI_STRB_BITS-1:0] WSTRB_DEFAULT;
logic WLAST_DEFAULT;
logic WVALID_DEFAULT;
logic WREADY_DEFAULT;


logic [`AXI_IDS_BITS-1:0] BID_DEFAULT;
logic [1:0] BRESP_DEFAULT;
logic BVALID_DEFAULT;
logic BREADY_DEFAULT;
	
logic [`AXI_IDS_BITS-1:0] RID_DEFAULT;
logic [`AXI_DATA_BITS-1:0] RDATA_DEFAULT;
logic [1:0] RRESP_DEFAULT;
logic RLAST_DEFAULT;
logic RVALID_DEFAULT;
logic RREADY_DEFAULT;

assign master0.AWREADY = 1'b0;
assign master0.WREADY = 1'b0;
assign master0.BID = `AXI_ID_BITS'b0;
assign master0.BRESP = `AXI_RESP_OKAY;
assign master0.BVALID = 1'b0;

Default_Slave Slave(
    .clk(ACLK),
    .rst(ARESETn),
    .ARID_DEFAULT(ARID_DEFAULT),  
    .ARADDR_DEFAULT(ARADDR_DEFAULT),
    .ARLEN_DEFAULT(ARLEN_DEFAULT),
    .ARSIZE_DEFAULT(ARSIZE_DEFAULT),
    .ARBURST_DEFAULT(ARBURST_DEFAULT),
    .ARVALID_DEFAULT(ARVALID_DEFAULT),
    .ARREADY_DEFAULT(ARREADY_DEFAULT),
    .AWID_DEFAULT(AWID_DEFAULT),
    .AWADDR_DEFAULT(AWADDR_DEFAULT),
    .AWLEN_DEFAULT(AWLEN_DEFAULT),
    .AWSIZE_DEFAULT(AWSIZE_DEFAULT),
    .AWBURST_DEFAULT(AWBURST_DEFAULT),
    .AWVALID_DEFAULT(AWVALID_DEFAULT),
    .AWREADY_DEFAULT(AWREADY_DEFAULT),
    .BID_DEFAULT(BID_DEFAULT),
    .BRESP_DEFAULT(BRESP_DEFAULT),
    .BVALID_DEFAULT(BVALID_DEFAULT),
    .BREADY_DEFAULT(BREADY_DEFAULT),
    .RID_DEFAULT(RID_DEFAULT),
    .RDATA_DEFAULT(RDATA_DEFAULT),
    .RRESP_DEFAULT(RRESP_DEFAULT),
    .RLAST_DEFAULT(RLAST_DEFAULT),
    .RVALID_DEFAULT(RVALID_DEFAULT),
    .RREADY_DEFAULT(RREADY_DEFAULT),
	.WDATA_DEFAULT(WDATA_DEFAULT),
	.WSTRB_DEFAULT(WSTRB_DEFAULT),
	.WLAST_DEFAULT(WLAST_DEFAULT),
	.WVALID_DEFAULT(WVALID_DEFAULT),
	.WREADY_DEFAULT(WREADY_DEFAULT)
);

// READ ADDRESS Channel

AR AR(
    .clk(ACLK),
    .rst(ARESETn),
    .master0(master0),
	//.ID_M0   (master0.ARID   ),
	//.ADDR_M0 (master0.ARADDR ),
	//.LEN_M0  (master0.ARLEN  ),
	//.SIZE_M0 (master0.ARSIZE ),
	//.BURST_M0(master0.ARBURST),
	//.VALID_M0(master0.ARVALID),
	.ID_M1   (master1.ARID   ),
	.ADDR_M1 (master1.ARADDR ),
	.LEN_M1  (master1.ARLEN  ),
	.SIZE_M1 (master1.ARSIZE ),
	.BURST_M1(master1.ARBURST),
	.VALID_M1(master1.ARVALID),
	.READY_S0(slave0.ARREADY),
	.READY_S1(slave1.ARREADY),
    .READY_S2(ARREADY_DEFAULT),
	.ID_S0   (slave0.ARID   ),
	.ADDR_S0 (slave0.ARADDR ),
	.LEN_S0  (slave0.ARLEN  ),
	.SIZE_S0 (slave0.ARSIZE ),
	.BURST_S0(slave0.ARBURST),
	.VALID_S0(slave0.ARVALID),
	.ID_S1   (slave1.ARID   ),
	.ADDR_S1 (slave1.ARADDR ),
	.LEN_S1  (slave1.ARLEN  ),
	.SIZE_S1 (slave1.ARSIZE ),
	.BURST_S1(slave1.ARBURST),
	.VALID_S1(slave1.ARVALID),
	.ID_S2   (ARID_DEFAULT),
	.ADDR_S2 (ARADDR_DEFAULT),
	.LEN_S2  (ARLEN_DEFAULT),
	.SIZE_S2 (ARSIZE_DEFAULT),
	.BURST_S2(ARBURST_DEFAULT),
	.VALID_S2(ARVALID_DEFAULT),
    //.READY_M0(master0.ARREADY),
    .READY_M1(master1.ARREADY)

);

// WRITE ADDRESS Channel
AW AW(
    .clk(ACLK),
    .rst(ARESETn),
	.ID_M1   (master1.AWID   ),
	.ADDR_M1 (master1.AWADDR ),
	.LEN_M1  (master1.AWLEN  ),
	.SIZE_M1 (master1.AWSIZE ),
	.BURST_M1(master1.AWBURST),
	.VALID_M1(master1.AWVALID),
	.READY_S0(slave0.AWREADY),
	.READY_S1(slave1.AWREADY),
    .READY_S2(AWREADY_DEFAULT),
	.ID_S0   (slave0.AWID   ),
	.ADDR_S0 (slave0.AWADDR ),
	.LEN_S0  (slave0.AWLEN  ),
	.SIZE_S0 (slave0.AWSIZE ),
	.BURST_S0(slave0.AWBURST),
	.VALID_S0(slave0.AWVALID),
	.ID_S1   (slave1.AWID   ),
	.ADDR_S1 (slave1.AWADDR ),
	.LEN_S1  (slave1.AWLEN  ),
	.SIZE_S1 (slave1.AWSIZE ),
	.BURST_S1(slave1.AWBURST),
	.VALID_S1(slave1.AWVALID),
	.ID_S2   (AWID_DEFAULT),
	.ADDR_S2 (AWADDR_DEFAULT),
	.LEN_S2  (AWLEN_DEFAULT),
	.SIZE_S2 (AWSIZE_DEFAULT),
	.BURST_S2(AWBURST_DEFAULT),
	.VALID_S2(AWVALID_DEFAULT),
    .READY_M1(master1.AWREADY),
	.MASTER  (MASTER)
);


//WRITE DATA CHannel
DW DW(
    .clk(ACLK),
    .rst(ARESETn),
	.WDATA_M1  (master1.WDATA),
	.WSTRB_M1  (master1.WSTRB),
	.WLAST_M1  (master1.WLAST),
	.WVALID_M1 (master1.WVALID),
	.WREADY_M1 (master1.WREADY),
	.WDATA_S0  (slave0.WDATA),
	.WSTRB_S0  (slave0.WSTRB),
	.WLAST_S0  (slave0.WLAST),
	.WVALID_S0 (slave0.WVALID),
	.WREADY_S0 (slave0.WREADY),
    .AWVALID_S0(slave0.AWVALID),
	.WDATA_S1  (slave1.WDATA),
	.WSTRB_S1  (slave1.WSTRB),
	.WLAST_S1  (slave1.WLAST),
	.WVALID_S1 (slave1.WVALID),
	.WREADY_S1 (slave1.WREADY),
    .AWVALID_S1(slave1.AWVALID),
    .MASTER(MASTER),
    .AWVALID_S2(AWVALID_DEFAULT),
	.WDATA_S2(WDATA_DEFAULT),
	.WSTRB_S2(WSTRB_DEFAULT),
	.WLAST_S2(WLAST_DEFAULT),
	.WVALID_S2(WVALID_DEFAULT),
	.WREADY_S2(WREADY_DEFAULT)

);

RW RW(
    .clk(ACLK),
    .rst(ARESETn),
	.BID_M1   (master1.BID),
	.BRESP_M1 (master1.BRESP),
	.BVALID_M1(master1.BVALID),
	.BREADY_M1(master1.BREADY),
	.BID_S0   (slave0.BID),
	.BRESP_S0 (slave0.BRESP),
	.BVALID_S0(slave0.BVALID),
	.BREADY_S0(slave0.BREADY),
	.BID_S1   (slave1.BID),
	.BRESP_S1 (slave1.BRESP),
	.BVALID_S1(slave1.BVALID),
	.BREADY_S1(slave1.BREADY),
	.BID_S2   (BID_DEFAULT),
	.BRESP_S2 (BRESP_DEFAULT),
	.BVALID_S2(BVALID_DEFAULT),
	.BREADY_S2(BREADY_DEFAULT)
);
DR DR(
    .clk(ACLK),
    .rst(ARESETn),
	.RID_M0   (master0.RID),
	.RDATA_M0 (master0.RDATA),
	.RLAST_M0 (master0.RLAST),
	.RRESP_M0 (master0.RRESP),
	.RVALID_M0(master0.RVALID),
	.RREADY_M0(master0.RREADY),
	.RID_M1   (master1.RID),
	.RDATA_M1 (master1.RDATA),
	.RRESP_M1 (master1.RRESP),
	.RLAST_M1 (master1.RLAST),
	.RVALID_M1(master1.RVALID),
	.RREADY_M1(master1.RREADY),
	.RID_S0   (slave0.RID),
	.RDATA_S0 (slave0.RDATA),
	.RRESP_S0 (slave0.RRESP),
	.RLAST_S0 (slave0.RLAST),
	.RVALID_S0(slave0.RVALID),
	.RREADY_S0(slave0.RREADY),
	.RID_S1   (slave1.RID),
	.RDATA_S1 (slave1.RDATA),
	.RRESP_S1 (slave1.RRESP),
	.RLAST_S1 (slave1.RLAST),
	.RVALID_S1(slave1.RVALID),
	.RREADY_S1(slave1.RREADY),
	.RID_S2   (RID_DEFAULT),
	.RDATA_S2 (RDATA_DEFAULT),
	.RRESP_S2 (RRESP_DEFAULT),
	.RLAST_S2 (RLAST_DEFAULT),
	.RVALID_S2(RVALID_DEFAULT),
	.RREADY_S2(RREADY_DEFAULT)
);

endmodule
