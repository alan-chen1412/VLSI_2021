`include "AXI_define.svh"
module DR(
	input clk,
	input rst,
	output [`AXI_ID_BITS-1:0] RID_M0,
	output [`AXI_DATA_BITS-1:0] RDATA_M0,
	output [1:0] RRESP_M0,
	output logic RLAST_M0,
	output logic RVALID_M0,
	input RREADY_M0,

	output [`AXI_ID_BITS-1:0] RID_M1,
	output [`AXI_DATA_BITS-1:0] RDATA_M1,
	output [1:0] RRESP_M1,
	output logic RLAST_M1,
	output logic RVALID_M1,
	input RREADY_M1,

	input [`AXI_IDS_BITS-1:0] RID_S0,
	input [`AXI_DATA_BITS-1:0] RDATA_S0,
	input [1:0] RRESP_S0,
	input RLAST_S0,
	input RVALID_S0,
	output logic RREADY_S0,

	input [`AXI_IDS_BITS-1:0] RID_S1,
	input [`AXI_DATA_BITS-1:0] RDATA_S1,
	input [1:0] RRESP_S1,
	input RLAST_S1,
	input RVALID_S1,
	output logic RREADY_S1,

	input [`AXI_IDS_BITS-1:0] RID_S2,
	input [`AXI_DATA_BITS-1:0] RDATA_S2,
	input [1:0] RRESP_S2,
	input RLAST_S2,
	input RVALID_S2,
	output logic RREADY_S2
);

logic [`AXI_SLAVE_BITS-1:0] slave;
logic [`AXI_SLAVE_BITS-1:0] next_slave;
logic [`AXI_MASTER_BITS-1:0] master;
logic READY;
logic [`AXI_ID_BITS-1:0] RID_M;
logic [`AXI_DATA_BITS-1:0] RDATA_M;
logic [1:0] RRESP_M;
logic RLAST_M;
logic RVALID_M;
logic lock_s0;
logic lock_s1;
logic lock_s2;


assign RID_M0 = RID_M;
assign RDATA_M0 = RDATA_M;
assign RRESP_M0 = RRESP_M;
assign RLAST_M0 = RLAST_M;

assign RID_M1 = RID_M;
assign RDATA_M1 = RDATA_M;
assign RRESP_M1 = RRESP_M;
assign RLAST_M1 = RLAST_M;


always_ff@(posedge clk or negedge rst) begin
	if(~rst) begin
		lock_s0 <= 1'b0;
		lock_s1 <= 1'b0;
		lock_s2 <= 1'b0;
	end
	else begin
		lock_s0 <= (lock_s0 & READY)? 1'b0 : (RVALID_S0 & ~RVALID_S1 & ~RVALID_S2 & ~READY) ? 1'b1 : lock_s0;
		lock_s1 <= (lock_s1 & READY)? 1'b0 : (~lock_s0 & RVALID_S1 & ~RVALID_S2 & ~READY) ? 1'b1 : lock_s1;
		lock_s2 <= (lock_s2 & READY)? 1'b0 : (~lock_s0 & ~lock_s1 & RVALID_S2 & ~READY) ? 1'b1 : lock_s2;
	end
end

always_comb begin
    if((RVALID_S2 & ~(lock_s1 | lock_s0)) | lock_s2) slave = `AXI_SLAVE2;
    else if ((RVALID_S1 & ~lock_s0) | lock_s1) slave = `AXI_SLAVE1;
    else if (RVALID_S0 | lock_s0) slave = `AXI_SLAVE0;
    else slave = `AXI_SLAVE_BITS'b0;
end


always_comb begin
	case(master)
		`AXI_MASTER0:begin
			READY = RREADY_M0; 
			RVALID_M0 = RVALID_M;
			RVALID_M1 = 1'b0 ;
		end
		`AXI_MASTER1:begin
			READY = RREADY_M1;
			RVALID_M1 = RVALID_M;
			RVALID_M0 = 1'b0 ;
		end
		default:begin
			READY = 1'b1;
			RVALID_M1 = 1'b0;
			RVALID_M0 = 1'b0;
		end
	endcase
end

always_comb begin
	case(slave)
		`AXI_SLAVE0:begin
			master = RID_S0[(`AXI_IDS_BITS-1)-:`AXI_MASTER_BITS];
			RID_M = RID_S0[`AXI_ID_BITS-1:0];
			RDATA_M = RDATA_S0;
			RRESP_M = RRESP_S0;
			RLAST_M = RLAST_S0;
			RVALID_M = RVALID_S0;
			RREADY_S2 = 1'b0;
			RREADY_S1 = 1'b0;
			RREADY_S0 = READY & RVALID_S0;
		end
		`AXI_SLAVE1:begin
			master = RID_S1[(`AXI_IDS_BITS-1)-:`AXI_MASTER_BITS];
			RID_M = RID_S1[`AXI_ID_BITS-1:0];
			RDATA_M = RDATA_S1;
			RRESP_M = RRESP_S1;
			RLAST_M = RLAST_S1;
			RVALID_M = RVALID_S1;
			RREADY_S2 = 1'b0;
			RREADY_S0 = 1'b0;
			RREADY_S1 = READY & RVALID_S1;
		end
		`AXI_SLAVE2:begin
			master = RID_S2[(`AXI_IDS_BITS-1)-:`AXI_MASTER_BITS];
			RID_M = RID_S2[`AXI_ID_BITS-1:0];
			RDATA_M = RDATA_S2;
			RRESP_M = RRESP_S2;
			RLAST_M = RLAST_S2;
			RVALID_M = RVALID_S2;
			RREADY_S0 = 1'b0;
			RREADY_S1 = 1'b0;
			RREADY_S2 = READY & RVALID_S2;
		end
		default:begin
			master = `AXI_DEFAULT_MASTER; 
			RID_M = `AXI_ID_BITS'b0;
			RDATA_M = `AXI_DATA_BITS'b0;
			RRESP_M = 2'b0;
			RLAST_M = 1'b0;
			RVALID_M = 1'b0;
			RREADY_S0 = 1'b0;
			RREADY_S1 = 1'b0;
			RREADY_S2 = 1'b0;
		end
	endcase
end

endmodule
