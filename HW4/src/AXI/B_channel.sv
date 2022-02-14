`include "AXI_define.svh"
module B_channel(
    input clk,
    input rst,

	output logic [`AXI_ID_BITS-1:0] BID_M0,
	output logic [1:0] BRESP_M0,
	output logic BVALID_M0,
	input BREADY_M0,

	output logic [`AXI_ID_BITS-1:0] BID_M1,
	output logic [1:0] BRESP_M1,
	output logic BVALID_M1,
	input BREADY_M1,

	output logic [`AXI_ID_BITS-1:0] BID_M2,
	output logic [1:0] BRESP_M2,
	output logic BVALID_M2,
	input BREADY_M2,

	input [`AXI_IDS_BITS-1:0] BID_S0,
	input [1:0] BRESP_S0,
	input BVALID_S0,
	output logic  BREADY_S0,

	input [`AXI_IDS_BITS-1:0] BID_S1,
	input [1:0] BRESP_S1,
	input BVALID_S1,
	output logic  BREADY_S1,
	
    input [`AXI_IDS_BITS-1:0] BID_S2,
	input [1:0] BRESP_S2,
	input BVALID_S2,
	output logic  BREADY_S2,
	
    input [`AXI_IDS_BITS-1:0] BID_S3,
	input [1:0] BRESP_S3,
	input BVALID_S3,
	output logic  BREADY_S3,
	
    input [`AXI_IDS_BITS-1:0] BID_S4,
	input [1:0] BRESP_S4,
	input BVALID_S4,
	output logic  BREADY_S4,
	
    input [`AXI_IDS_BITS-1:0] BID_S5,
	input [1:0] BRESP_S5,
	input BVALID_S5,
	output logic  BREADY_S5,

	input [`AXI_IDS_BITS-1:0] BID_S6,
	input [1:0] BRESP_S6,
	input BVALID_S6,
	output logic  BREADY_S6

);

logic [`AXI_MASTER_BITS-1:0] master;
logic [`AXI_SLAVE_BITS-1:0] slave;
logic [`AXI_SLAVE_BITS-1:0] nxt_slave;
logic [`AXI_IDS_BITS-1:0] BID;
logic [1:0] BRESP;
logic BVALID;
logic BREADY;

assign BID_M0 = BID[`AXI_ID_BITS-1:0];
assign BRESP_M0 = BRESP;
assign BID_M1 = BID[`AXI_ID_BITS-1:0];
assign BRESP_M1 = BRESP;
assign BID_M2 = BID[`AXI_ID_BITS-1:0];
assign BRESP_M2 = BRESP;


assign master = BID[(`AXI_IDS_BITS-1)-:`AXI_MASTER_BITS];

always_ff@(posedge clk or negedge rst) begin
    if(~rst)
        slave <= `AXI_SLAVE_BITS'b0;
    else 
        slave <= (BREADY) ? nxt_slave : slave;
end

always_comb begin
    if(BVALID_S0 & ~BREADY_S0 )
        nxt_slave = `AXI_SLAVE0;
    else if(BVALID_S1 & ~BREADY_S1)
        nxt_slave = `AXI_SLAVE1;
    else if(BVALID_S2 & ~BREADY_S2)
        nxt_slave = `AXI_SLAVE2;
    else if(BVALID_S3 & ~BREADY_S3)
        nxt_slave = `AXI_SLAVE3;
    else if(BVALID_S4 & ~BREADY_S4)
        nxt_slave = `AXI_SLAVE4;
    else if(BVALID_S5 & ~BREADY_S5)
        nxt_slave = `AXI_SLAVE5;
    else if(BVALID_S6 & ~BREADY_S6)
        nxt_slave = `AXI_SLAVE6;
    else 
        nxt_slave = `AXI_SLAVE_BITS'b0;
end

always_comb begin
    BREADY_S0 = 1'b0;
    BREADY_S1 = 1'b0;
    BREADY_S2 = 1'b0;
    BREADY_S3 = 1'b0;
    BREADY_S4 = 1'b0;
    BREADY_S5 = 1'b0;
    BREADY_S6 = 1'b0;
    case(slave)
        `AXI_SLAVE0:begin
            BID = BID_S0;
            BRESP = BRESP_S0;
            BVALID = BVALID_S0;
            BREADY_S0 = BREADY;
        end
        `AXI_SLAVE1:begin
            BID = BID_S1;
            BRESP = BRESP_S1;
            BVALID = BVALID_S1;
            BREADY_S1 = BREADY;
        end
        `AXI_SLAVE2:begin
            BID = BID_S2;
            BRESP = BRESP_S2;
            BVALID = BVALID_S2;
            BREADY_S2 = BREADY;
        end
        `AXI_SLAVE3:begin
            BID = BID_S3;
            BRESP = BRESP_S3;
            BVALID = BVALID_S3;
            BREADY_S3 = BREADY;
        end
        `AXI_SLAVE4:begin
            BID = BID_S4;
            BRESP = BRESP_S4;
            BVALID = BVALID_S4;
            BREADY_S4 = BREADY;
        end
        `AXI_SLAVE5:begin
            BID = BID_S5;
            BRESP = BRESP_S5;
            BVALID = BVALID_S5;
            BREADY_S5 = BREADY;
        end
        `AXI_SLAVE6:begin
            BID = BID_S6;
            BRESP = BRESP_S6;
            BVALID = BVALID_S6;
            BREADY_S6 = BREADY;
        end
        default:begin
            BID = `AXI_IDS_BITS'b0;
            BRESP = BRESP_S6;
            BVALID = 1'b0;
            BREADY_S6 = BREADY;
        end
    endcase
end

always_comb begin
    BVALID_M0 = 1'b0;
    BVALID_M1 = 1'b0;
    BVALID_M2 = 1'b0;
    case(master)
        `AXI_MASTER0:begin
		BREADY = BREADY_M0;
		BVALID_M0 = BVALID;
	end
        `AXI_MASTER1:begin
		BREADY = BREADY_M1;
		BVALID_M1 = BVALID;
	end
        `AXI_MASTER2:begin
		BREADY = BREADY_M2;
		BVALID_M2 = BVALID;
	end
        default:begin
		BREADY = 1'b1;
    		BVALID_M0 = 1'b0;
    		BVALID_M1 = 1'b0;
    		BVALID_M2 = 1'b0;
	end
    endcase
end

endmodule
