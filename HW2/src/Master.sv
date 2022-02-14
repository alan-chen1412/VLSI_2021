`include "AXI_define.svh"


module Master(
    input clk,
    input rst,
	output logic [`AXI_ID_BITS-1:0] AWID_M,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_M,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_M,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_M,
	output logic [1:0] AWBURST_M,
	output logic AWVALID_M,
	input AWREADY_M,
	//WRITE DATA
	output logic [`AXI_DATA_BITS-1:0] WDATA_M,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_M,
	output logic WLAST_M,
	output logic WVALID_M,
	input WREADY_M,
	//WRITE RESPONSE
	input [`AXI_ID_BITS-1:0] BID_M,
	input [1:0] BRESP_M,
	input BVALID_M,
	output logic BREADY_M,

	//READ ADDRESS1
	output logic [`AXI_ID_BITS-1:0] ARID_M,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_M,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_M,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M,
	output logic [1:0] ARBURST_M,
	output logic ARVALID_M,
	input ARREADY_M,
	//READ DATA1
	input [`AXI_ID_BITS-1:0] RID_M,
	input [`AXI_DATA_BITS-1:0] RDATA_M,
	input [1:0] RRESP_M,
	input RLAST_M,
	input RVALID_M,
	output logic RREADY_M,

    //interface for cpu
    input read,
    input write,
    input [`AXI_STRB_BITS-1:0] w_type,
    input [`AXI_DATA_BITS-1:0] data_in,
    input [`AXI_ADDR_BITS-1:0] addr,
    output logic [`AXI_DATA_BITS-1:0] data_out,
    output logic stall
);

logic [`AXI_ID_BITS-1:0] ID;
logic ARfin;
logic lockAR;
logic Rfin;
logic Rfull;
logic lockRREADY;
logic AWfin;
logic Wfin;
logic Bfin;
logic lockAW;
logic lockW;
logic Wfull;
logic lockBREADY;
logic [`AXI_ADDR_BITS-1:0] ARADDR;
logic write_stall;
logic read_stall;
logic r;
logic [`AXI_DATA_BITS-1:0] tmp_data;
assign data_out = (Rfin)?RDATA_M:tmp_data;
assign ID = `AXI_ID_BITS'b0;
assign ARID_M = ID;
assign ARLEN_M = `AXI_LEN_BITS'b0;
assign ARSIZE_M = `AXI_SIZE_BITS'b10;
assign ARBURST_M = 2'b0;
assign ARADDR_M = addr;
assign AWID_M = ID;
assign AWLEN_M = `AXI_LEN_BITS'b0;
assign AWSIZE_M = `AXI_SIZE_BITS'b10;
assign AWBURST_M = 2'b0;
assign AWADDR_M = addr;
assign WSTRB_M = w_type;
assign WLAST_M = 1'b1;
assign WDATA_M = data_in;
assign ARfin = ARREADY_M & ARVALID_M;
assign Rfin = RREADY_M & RVALID_M;
assign ARVALID_M = (Rfull) ? 1'b0 : (lockAR | read) & r;
assign RREADY_M = (AWfin | lockRREADY);
assign AWfin = AWREADY_M & AWVALID_M;
assign Wfin = WREADY_M & WVALID_M;
assign Bfin = BREADY_M & BVALID_M;
assign AWVALID_M = (Wfull) ? 1'b0 : (write | lockAW);
assign WVALID_M = AWfin | lockW;
assign BREADY_M = lockBREADY | Wfin;
assign write_stall = write & ~Wfin;
assign read_stall = read & ~Rfin ;
assign stall = read_stall | write_stall ;

always_ff@(posedge clk or negedge rst) begin
    if(~rst) begin
        lockAR <= 1'b0;
        Rfull <= 1'b0;
        lockRREADY <= 1'b0;
        lockAW <= 1'b0;
        lockW <= 1'b0;
        Wfull <= 1'b0;
        lockBREADY <= 1'b0;
        r <= 1'b0;
        tmp_data <= `AXI_DATA_BITS'b0;
    end
    else begin
        tmp_data <= (Rfin) ? RDATA_M : tmp_data;
        r <= 1'b1;
        lockBREADY <= (lockBREADY & BVALID_M) ? 1'b0 : (Wfin)? 1'b1 : lockBREADY;
        Wfull <= (Wfull & Bfin) ? 1'b0 : (AWfin & ~Bfin) ? 1'b1 : Wfull;
        lockAW <= (lockAW & AWREADY_M) ? 1'b0 : (AWVALID_M & ~AWREADY_M) ? 1'b1 : lockAW;
        lockW <= (lockW & WREADY_M) ? 1'b0 : (WVALID_M & ~WREADY_M) ? 1'b1 : lockW;
        lockAR <= (lockAR & ARREADY_M) ? 1'b0 : (ARVALID_M & ~ARREADY_M) ? 1'b1 : lockAR ; // if ARVALID is high , but ARREADY is low, then will make ARVALID high
        Rfull <= (Rfull & Rfin) ? 1'b0 : (ARfin & ~Rfin) ? 1'b1 : Rfull;
        lockRREADY <= (lockRREADY & RVALID_M) ? 1'b0 : (ARfin) ? 1'b1 : lockRREADY;
    end
end


endmodule
