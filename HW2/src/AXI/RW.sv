`include "AXI_define.svh"

module RW(
	input clk,
	input rst,
	output [`AXI_ID_BITS-1:0] BID_M1,
	output [1:0] BRESP_M1,
	output logic BVALID_M1,
	input BREADY_M1,

	input [`AXI_IDS_BITS-1:0] BID_S0,
	input [1:0] BRESP_S0,
	input BVALID_S0,
	output logic BREADY_S0,

	input [`AXI_IDS_BITS-1:0] BID_S1,
	input [1:0] BRESP_S1,
	input BVALID_S1,
	output logic BREADY_S1,

	input [`AXI_IDS_BITS-1:0] BID_S2,
	input [1:0] BRESP_S2,
	input BVALID_S2,
	output logic BREADY_S2

);

logic [`AXI_SLAVE_BITS-1:0] slave;
logic [`AXI_SLAVE_BITS-1:0] next_slave;
logic [`AXI_MASTER_BITS-1:0] master;
logic [`AXI_ID_BITS-1:0] BID_M;
logic [1:0] BRESP_M;
logic BVALID_M;
logic READY;
logic lock_s0;
logic lock_s1;
logic lock_s2;
assign BID_M1 = BID_M;
assign BRESP_M1 = BRESP_M;


always_ff@(posedge clk or negedge rst) begin
	if(~rst) begin
		lock_s0 <= 1'b0;
		lock_s1 <= 1'b0;
		lock_s2 <= 1'b0;
	end
	else begin
		lock_s0 <= (lock_s0 & READY)? 1'b0 : (BVALID_S0 & ~BVALID_S1 & ~BVALID_S2 & ~READY) ? 1'b1 : lock_s0;
		lock_s1 <= (lock_s1 & READY)? 1'b0 : (~lock_s0 & BVALID_S1 & ~BVALID_S2 & ~READY) ? 1'b1 : lock_s1;
		lock_s2 <= (lock_s2 & READY)? 1'b0 : (~lock_s0 & ~lock_s1 & BVALID_S2 & ~READY) ? 1'b1 : lock_s2;
	end
end

always_comb begin
	if((BVALID_S2 & ~(lock_s1 | lock_s0)) | lock_s2) slave = `AXI_SLAVE2;
	else if ((BVALID_S1 & ~lock_s0) | lock_s1) slave = `AXI_SLAVE1;
	else if (BVALID_S0 | lock_s0) slave = `AXI_SLAVE0;
	else slave = `AXI_SLAVE_BITS'b0;
end

always_comb begin
	case(master)
		`AXI_MASTER1:begin
			READY = BREADY_M1;
			BVALID_M1 = BVALID_M ;
		end
		default:begin
			READY = 1'b1;
			BVALID_M1 = 1'b0;
		end
	endcase
end

always_comb begin
	case(slave)
		`AXI_SLAVE0:begin
			master = BID_S0[(`AXI_IDS_BITS-1)-:`AXI_MASTER_BITS];
			BID_M = BID_S0[`AXI_ID_BITS-1:0];
			BRESP_M = BRESP_S0;
			BVALID_M = BVALID_S0;
			BREADY_S2 = 1'b0;
			BREADY_S1 = 1'b0;
			BREADY_S0 = READY & BVALID_S0;
		end
		`AXI_SLAVE1:begin
			master = BID_S1[(`AXI_IDS_BITS-1)-:`AXI_MASTER_BITS];
			BID_M = BID_S1[`AXI_ID_BITS-1:0];
			BRESP_M = BRESP_S1;
			BVALID_M = BVALID_S1;
			BREADY_S2 = 1'b0;
			BREADY_S0 = 1'b0;
			BREADY_S1 = READY & BVALID_S1;
		end
		`AXI_SLAVE2:begin
			master = BID_S2[(`AXI_IDS_BITS-1)-:`AXI_MASTER_BITS];
			BID_M = BID_S2[`AXI_ID_BITS-1:0];
			BRESP_M = BRESP_S2;
			BVALID_M = BVALID_S2;
			BREADY_S0 = 1'b0;
			BREADY_S1 = 1'b0;
			BREADY_S2 = READY & BVALID_S2;
		end
		default:begin
			master = `AXI_DEFAULT_MASTER; 
			BID_M = `AXI_ID_BITS'b0;
			BRESP_M = 2'b0;
			BVALID_M = 1'b0;
			BREADY_S0 = 1'b0;
			BREADY_S1 = 1'b0;
			BREADY_S2 = 1'b0;
		end
	endcase
end


endmodule
