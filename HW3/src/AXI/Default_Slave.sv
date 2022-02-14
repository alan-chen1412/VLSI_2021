`include "AXI_define.svh"
module Default_Slave( 
    input clk,
    input rst,
    input [`AXI_IDS_BITS-1:0 ] ARID_DEFAULT,
    input [`AXI_ADDR_BITS-1:0] ARADDR_DEFAULT,
    input [`AXI_LEN_BITS-1:0 ] ARLEN_DEFAULT,
    input [`AXI_SIZE_BITS-1:0] ARSIZE_DEFAULT,
    input [1:0               ] ARBURST_DEFAULT,
    input                      ARVALID_DEFAULT,
    output logic               ARREADY_DEFAULT,

    input [`AXI_IDS_BITS-1:0 ] AWID_DEFAULT,
    input [`AXI_ADDR_BITS-1:0] AWADDR_DEFAULT,
    input [`AXI_LEN_BITS-1:0 ] AWLEN_DEFAULT,
    input [`AXI_SIZE_BITS-1:0] AWSIZE_DEFAULT,
    input [1:0               ] AWBURST_DEFAULT,
    input                      AWVALID_DEFAULT,
    output logic               AWREADY_DEFAULT,

	input [`AXI_DATA_BITS-1:0] WDATA_DEFAULT,
	input [`AXI_STRB_BITS-1:0] WSTRB_DEFAULT,
	input WLAST_DEFAULT,
	input WVALID_DEFAULT,
	output logic WREADY_DEFAULT,
    output logic [`AXI_IDS_BITS-1:0] BID_DEFAULT,
    output logic [1:0] BRESP_DEFAULT,
    output logic BVALID_DEFAULT,
    input  BREADY_DEFAULT,

    output logic [`AXI_IDS_BITS-1:0] RID_DEFAULT,
    output logic [`AXI_DATA_BITS-1:0] RDATA_DEFAULT,
    output logic [1:0] RRESP_DEFAULT,
    output logic RLAST_DEFAULT,
    output logic RVALID_DEFAULT,
    input RREADY_DEFAULT
);

logic lockAR;
logic [`AXI_IDS_BITS-1:0] ARID_DEFAULT_REG;
logic [`AXI_IDS_BITS-1:0] AWID_DEFAULT_REG;
logic lockAW;
logic lockW;
logic AW_FIN;
logic W_FIN;
logic lockB;
logic AR_FIN;

assign AR_FIN = ARREADY_DEFAULT & ARVALID_DEFAULT;
assign RRESP_DEFAULT = `AXI_RESP_DECERR;
assign RDATA_DEFAULT = `AXI_DATA_BITS'b0;
assign RLAST_DEFAULT = 1'b1; 

assign BRESP_DEFAULT = `AXI_RESP_DECERR;
//assign BVALID_DEFAULT = (AW_FIN & W_FIN) | (lockAW & W_FIN) | (lockAW & lockW) | lockB; 
//assign BID_DEFAULT = (lockB) ? AWID_DEFAULT_REG : AWID_DEFAULT;


assign AW_FIN = AWREADY_DEFAULT & AWVALID_DEFAULT;
assign W_FIN = WREADY_DEFAULT & WVALID_DEFAULT;
 
always_ff@(posedge clk or negedge rst) begin
	if(~rst) begin
		RVALID_DEFAULT <= 1'b0;
		RID_DEFAULT <= {`AXI_DEFAULT_MASTER,`AXI_ID_BITS'b0};
		ARREADY_DEFAULT <= 1'b1;
		lockAR <= 1'b0;
	end
	else begin
		ARREADY_DEFAULT <= ((lockAR & ~RREADY_DEFAULT) |AR_FIN ) ? 1'b0 :1'b1;
		RVALID_DEFAULT <= (RVALID_DEFAULT & RREADY_DEFAULT) ? 1'b0 : (AR_FIN) ? 1'b1 : RVALID_DEFAULT;
		RID_DEFAULT <= (AR_FIN) ? ARID_DEFAULT: RID_DEFAULT;
		lockAR <=(lockAR & RREADY_DEFAULT)?1'b0: (AR_FIN) ? 1'b1 :lockAR;
	end
end

always_ff@(posedge clk or negedge rst) begin
	if(~rst) begin
		BVALID_DEFAULT <= 1'b0;
		BID_DEFAULT <= {`AXI_DEFAULT_MASTER,`AXI_ID_BITS'b0};
		AWREADY_DEFAULT <= 1'b0;
		WREADY_DEFAULT <= 1'b0;
		lockAW <= 1'b0;
		lockW <= 1'b0;
	end
	else begin
		lockAW <= (lockAW & BREADY_DEFAULT) ? 1'b0: (AW_FIN) ? 1'b1:lockAW;
		lockW <= (lockW & BREADY_DEFAULT) ? 1'b0: (W_FIN) ? 1'b1:lockW;
		AWREADY_DEFAULT <= ((lockAW & ~BREADY_DEFAULT) |AW_FIN) ? 1'b0:1'b1;
		WREADY_DEFAULT <= ((lockW & ~BREADY_DEFAULT) | W_FIN)? 1'b0 : 1'b1;
		BID_DEFAULT <= (AW_FIN) ? AWID_DEFAULT:BID_DEFAULT;
		BVALID_DEFAULT <= (BVALID_DEFAULT & BREADY_DEFAULT) ? 1'b0 : ((AW_FIN & W_FIN) | (lockAW & W_FIN) | (lockW & AW_FIN)) ? 1'b1: BVALID_DEFAULT;

	end
end


endmodule
