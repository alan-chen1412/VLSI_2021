`include "AXI_define.svh"
`include "Arbiter.sv"
`include "Decoder.sv"

module DW(
    input clk,
    input rst,
	input [`AXI_DATA_BITS-1:0] WDATA_M1,
	input [`AXI_STRB_BITS-1:0] WSTRB_M1,
	input WLAST_M1,
	input WVALID_M1,
	output logic WREADY_M1,
	
	input [`AXI_MASTER_BITS-1:0] MASTER,
	
	output [`AXI_DATA_BITS-1:0] WDATA_S0,
	output [`AXI_STRB_BITS-1:0] WSTRB_S0,
	output WLAST_S0,
	output WVALID_S0,
	input WREADY_S0,
    	input AWVALID_S0,

	output [`AXI_DATA_BITS-1:0] WDATA_S1,
	output [`AXI_STRB_BITS-1:0] WSTRB_S1,
	output WLAST_S1,
	output WVALID_S1,
	input WREADY_S1,
        
	output [`AXI_DATA_BITS-1:0] WDATA_S2,
	output [`AXI_STRB_BITS-1:0] WSTRB_S2,
	output WLAST_S2,
	output WVALID_S2,
	input WREADY_S2,

	input AWVALID_S1,
   	input AWVALID_S2
);

logic [`AXI_SLAVE_BITS-1:0] SLAVE;
logic [`AXI_SLAVE_BITS-1:0] VALID_SLAVE;
logic [`AXI_DATA_BITS-1:0] WDATA_M;
logic [`AXI_STRB_BITS-1:0] WSTRB_M;
logic WLAST_M;
logic WVALID_M;
logic READY;
logic WVALID_S0_REG;
logic WVALID_S1_REG;
logic WVALID_S2_REG;

assign WREADY_M1 = READY & WVALID_M1;

assign WDATA_S1 = WDATA_M;
assign WSTRB_S1 = (WVALID_S1)?WSTRB_M : `AXI_STRB_BITS'hf;
assign WLAST_S1 = WLAST_M;

assign WDATA_S0 = WDATA_M;
assign WSTRB_S0 = (WVALID_S0)?WSTRB_M : `AXI_STRB_BITS'hf;
assign WLAST_S0 = WLAST_M;

assign WDATA_S2 = WDATA_M;
assign WSTRB_S2 = WSTRB_M;
assign WLAST_S2 = WLAST_M;

assign SLAVE = {(WVALID_S2_REG | AWVALID_S2),(WVALID_S1_REG | AWVALID_S1),(WVALID_S0_REG | AWVALID_S0)};
assign {WVALID_S2,WVALID_S1,WVALID_S0} = VALID_SLAVE;

always_ff@(posedge clk or negedge rst) begin
	if(~rst)begin
		WVALID_S0_REG <= 1'b0;
		WVALID_S1_REG <= 1'b0;
		WVALID_S2_REG <= 1'b0;
	end
	else begin
		WVALID_S0_REG <= (AWVALID_S0) ?AWVALID_S0 : WVALID_M & READY ? 1'b0 :WVALID_S0_REG;
		WVALID_S1_REG <= (AWVALID_S1) ?AWVALID_S1 : WVALID_M & READY ? 1'b0 :WVALID_S1_REG;
		WVALID_S2_REG <= (AWVALID_S2) ?AWVALID_S2 : WVALID_M & READY ? 1'b0 :WVALID_S2_REG;
		
	end
end


always_comb begin
	case(SLAVE)
		`AXI_SLAVE0:begin
			READY = WREADY_S0;	
			VALID_SLAVE = {1'b0,1'b0,WVALID_M};	
		end
		`AXI_SLAVE1:begin
			READY = WREADY_S1;
			VALID_SLAVE = {1'b0,WVALID_M,1'b0};	
		end
		`AXI_SLAVE2:begin
			READY = WREADY_S2;
			VALID_SLAVE = {WVALID_M,1'b0,1'b0};	
		end
		default:begin
			READY = 1'b1;
			VALID_SLAVE = `AXI_SLAVE_BITS'b0; 
		end
	endcase
end


assign WDATA_M = WDATA_M1;
assign WSTRB_M = WSTRB_M1;
assign WLAST_M = WLAST_M1;
assign WVALID_M = WVALID_M1;

endmodule
