`include "Master.sv"
`include "CPU.sv"
`include "AXI_define.svh"
module CPU_wrapper(
    input clk,
    input rst,
	output logic [`AXI_ID_BITS-1:0] AWID_M1,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_M1,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_M1,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
	output logic [1:0] AWBURST_M1,
	output logic AWVALID_M1,
	input AWREADY_M1,
	//WRITE DATA
	output logic [`AXI_DATA_BITS-1:0] WDATA_M1,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_M1,
	output logic WLAST_M1,
	output logic WVALID_M1,
	input WREADY_M1,
	//WRITE RESPONSE
	input [`AXI_ID_BITS-1:0] BID_M1,
	input [1:0] BRESP_M1,
	input BVALID_M1,
	output logic BREADY_M1,

	//READ ADDRESS1
	output logic [`AXI_ID_BITS-1:0] ARID_M1,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_M1,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_M1,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
	output logic [1:0] ARBURST_M1,
	output logic ARVALID_M1,
	input ARREADY_M1,
	//READ DATA1
	input [`AXI_ID_BITS-1:0] RID_M1,
	input [`AXI_DATA_BITS-1:0] RDATA_M1,
	input [1:0] RRESP_M1,
	input RLAST_M1,
	input RVALID_M1,
	output logic RREADY_M1,

	output logic [`AXI_ID_BITS-1:0] AWID_M0,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_M0,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_M0,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_M0,
	output logic [1:0] AWBURST_M0,
	output logic AWVALID_M0,
	input AWREADY_M0,
	//WRITE DATA
	output logic [`AXI_DATA_BITS-1:0] WDATA_M0,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_M0,
	output logic WLAST_M0,
	output logic WVALID_M0,
	input WREADY_M0,
	//WRITE RESPONSE
	input [`AXI_ID_BITS-1:0] BID_M0,
	input [1:0] BRESP_M0,
	input BVALID_M0,
	output logic BREADY_M0,

	//READ ADDRESS1
	output logic [`AXI_ID_BITS-1:0] ARID_M0,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_M0,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_M0,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
	output logic [1:0] ARBURST_M0,
	output logic ARVALID_M0,
	input ARREADY_M0,
	//READ DATA1
	input [`AXI_ID_BITS-1:0] RID_M0,
	input [`AXI_DATA_BITS-1:0] RDATA_M0,
	input [1:0] RRESP_M0,
	input RLAST_M0,
	input RVALID_M0,
	output logic RREADY_M0


);

logic [`AXI_DATA_BITS-1:0] data_in;
logic [`SRAM_DATA_BITS-1:0] instr_in;
logic DM_stall;
logic IM_stall;
logic [`AXI_ADDR_BITS-1:0] instr_addr;
logic [`AXI_ADDR_BITS-1:0] data_addr;
logic [`SRAM_DATA_BITS-1:0] data_out;
logic IM_req;
logic DM_req;
logic [`SRAM_WRITE_BITS-1:0] data_write;
logic IM_read;
logic DM_read;
logic write;
logic latch_rst;

always_ff@(posedge clk or negedge rst) begin
    if(~rst) latch_rst <= rst;
    else latch_rst <= rst; 
end

CPU CPU(
    .clk(clk),
    .rst(~latch_rst),
    .data_in(data_in),
    .instr_in(instr_in),
    .DM_stall(DM_stall),
    .IM_stall(IM_stall),
    .instr_addr(instr_addr),
    .data_addr(data_addr),
    .data_out(data_out),
    .IM_req(IM_req),
    .DM_req(DM_req),
    .data_write(data_write),
    .IM_read(IM_read),
    .DM_read(DM_read),
    .write(write)
);
Master M0(
    .clk(clk),
    .rst(rst),
	.AWID_M(AWID_M0),
	.AWADDR_M(AWADDR_M0),
	.AWLEN_M(AWLEN_M0),
	.AWSIZE_M(AWSIZE_M0),
	.AWBURST_M(AWBURST_M0),
	.AWVALID_M(AWVALID_M0),
	.AWREADY_M(AWREADY_M0),
	.WDATA_M(WDATA_M0),
	.WSTRB_M(WSTRB_M0),
	.WLAST_M(WLAST_M0),
	.WVALID_M(WVALID_M0),
	.WREADY_M(WREADY_M0),
	.BID_M(BID_M0),
	.BRESP_M(BRESP_M0),
	.BVALID_M(BVALID_M0),
	.BREADY_M(BREADY_M0),
	.ARID_M(ARID_M0),
	.ARADDR_M(ARADDR_M0),
	.ARLEN_M(ARLEN_M0),
	.ARSIZE_M(ARSIZE_M0),
	.ARBURST_M(ARBURST_M0),
	.ARVALID_M(ARVALID_M0),
	.ARREADY_M(ARREADY_M0),
	.RID_M(RID_M0),
	.RDATA_M(RDATA_M0),
	.RRESP_M(RRESP_M0),
	.RLAST_M(RLAST_M0),
	.RVALID_M(RVALID_M0),
	.RREADY_M(RREADY_M0),
    .read(IM_read),
    .write(1'b0),
    .w_type(4'hf),
    .data_in(32'b0),
    .addr(instr_addr),
    .data_out(instr_in),
    .stall(IM_stall)
);

Master M1(
    .clk(clk),
    .rst(rst),
	.AWID_M(AWID_M1),
	.AWADDR_M(AWADDR_M1),
	.AWLEN_M(AWLEN_M1),
	.AWSIZE_M(AWSIZE_M1),
	.AWBURST_M(AWBURST_M1),
	.AWVALID_M(AWVALID_M1),
	.AWREADY_M(AWREADY_M1),
	.WDATA_M(WDATA_M1),
	.WSTRB_M(WSTRB_M1),
	.WLAST_M(WLAST_M1),
	.WVALID_M(WVALID_M1),
	.WREADY_M(WREADY_M1),
	.BID_M(BID_M1),
	.BRESP_M(BRESP_M1),
	.BVALID_M(BVALID_M1),
	.BREADY_M(BREADY_M1),
	.ARID_M(ARID_M1),
	.ARADDR_M(ARADDR_M1),
	.ARLEN_M(ARLEN_M1),
	.ARSIZE_M(ARSIZE_M1),
	.ARBURST_M(ARBURST_M1),
	.ARVALID_M(ARVALID_M1),
	.ARREADY_M(ARREADY_M1),
	.RID_M(RID_M1),
	.RDATA_M(RDATA_M1),
	.RRESP_M(RRESP_M1),
	.RLAST_M(RLAST_M1),
	.RVALID_M(RVALID_M1),
	.RREADY_M(RREADY_M1),
    .read(DM_read),
    .write(write),
    .w_type(data_write),
    .data_in(data_out),
    .addr(data_addr),
    .data_out(data_in),
    .stall(DM_stall)
);

endmodule

