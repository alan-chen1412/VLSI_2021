`include "AXI_define.svh"
module R_channel(
    input clk,
    input rst,
    
    input RREADY_M0,
	output logic [`AXI_ID_BITS-1:0] RID_M0,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M0,
	output logic [1:0] RRESP_M0,
	output logic RLAST_M0,
	output logic RVALID_M0,

    input RREADY_M1,
	output logic [`AXI_ID_BITS-1:0] RID_M1,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M1,
	output logic [1:0] RRESP_M1,
	output logic RLAST_M1,
	output logic RVALID_M1,

    input RREADY_M2,
	output logic [`AXI_ID_BITS-1:0] RID_M2,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M2,
	output logic [1:0] RRESP_M2,
	output logic RLAST_M2,
	output logic RVALID_M2,

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
	output logic RREADY_S2,

	input [`AXI_IDS_BITS-1:0] RID_S3,
	input [`AXI_DATA_BITS-1:0] RDATA_S3,
	input [1:0] RRESP_S3,
	input RLAST_S3,
	input RVALID_S3,
	output logic RREADY_S3,

	input [`AXI_IDS_BITS-1:0] RID_S4,
	input [`AXI_DATA_BITS-1:0] RDATA_S4,
	input [1:0] RRESP_S4,
	input RLAST_S4,
	input RVALID_S4,
	output logic RREADY_S4,

	input [`AXI_IDS_BITS-1:0] RID_S5,
	input [`AXI_DATA_BITS-1:0] RDATA_S5,
	input [1:0] RRESP_S5,
	input RLAST_S5,
	input RVALID_S5,
	output logic RREADY_S5,

	input [`AXI_IDS_BITS-1:0] RID_S6,
	input [`AXI_DATA_BITS-1:0] RDATA_S6,
	input [1:0] RRESP_S6,
	input RLAST_S6,
	input RVALID_S6,
	output logic RREADY_S6
);

logic [`AXI_SLAVE_BITS-1:0] slave;
logic [`AXI_SLAVE_BITS-1:0] nxt_slave;
logic RREADY;
logic [`AXI_IDS_BITS-1:0] RID;
logic [`AXI_DATA_BITS-1:0] RDATA;
logic [1:0] RRESP;
logic RLAST;
logic RVALID;
logic [`AXI_MASTER_BITS-1:0] master;

assign master = RID[(`AXI_IDS_BITS-1)-:`AXI_MASTER_BITS];
assign RID_M0 = RID[`AXI_ID_BITS-1:0];
assign RDATA_M0 = RDATA;
assign RRESP_M0 = RRESP;
assign RLAST_M0 = RLAST;
assign RID_M1 = RID[`AXI_ID_BITS-1:0];
assign RDATA_M1 = RDATA;
assign RRESP_M1 = RRESP;
assign RLAST_M1 = RLAST;
assign RID_M2 = RID[`AXI_ID_BITS-1:0];
assign RDATA_M2 = RDATA;
assign RRESP_M2 = RRESP;
assign RLAST_M2 = RLAST;

always_ff @(posedge clk or negedge rst) begin
    if(~rst)
        slave <= `AXI_SLAVE_BITS'b0;
    else 
        slave <= (RREADY & RLAST) ? nxt_slave : slave;
end

always_comb begin
    if(RVALID_S0 & ~(RLAST_S0 & RREADY_S0))
        nxt_slave = `AXI_SLAVE0;
    else if(RVALID_S1 & ~(RLAST_S1 & RREADY_S1))
       nxt_slave = `AXI_SLAVE1;
    else if(RVALID_S2 & ~(RLAST_S2 & RREADY_S2))
        nxt_slave = `AXI_SLAVE2;
    else if(RVALID_S3 & ~(RLAST_S3 & RREADY_S3))
        nxt_slave = `AXI_SLAVE3;
    else if(RVALID_S4 & ~(RLAST_S4 & RREADY_S4))
        nxt_slave = `AXI_SLAVE4;
    else if(RVALID_S5 & ~(RLAST_S5 & RREADY_S5))
        nxt_slave = `AXI_SLAVE5;
    else if(RVALID_S6 & ~(RLAST_S6 & RREADY_S6))
        nxt_slave = `AXI_SLAVE6;
    else 
        nxt_slave = `AXI_SLAVE_BITS'b0;
end

always_comb begin
    case(master)
        `AXI_MASTER0:begin
            RVALID_M0 = RVALID;
            RVALID_M1 = 1'b0;
            RVALID_M2 = 1'b0;
            RREADY = RREADY_M0;
        end
        `AXI_MASTER1:begin
            RVALID_M1 = RVALID;
            RVALID_M0 = 1'b0;
            RVALID_M2 = 1'b0;
            RREADY = RREADY_M1;
        end
        `AXI_MASTER2:begin
            RVALID_M2 = RVALID;
            RVALID_M1 = 1'b0;
            RVALID_M0 = 1'b0;
            RREADY = RREADY_M2;
        end
        default :begin
            RVALID_M0 = 1'b0;
            RVALID_M1 = 1'b0;
            RVALID_M2 = 1'b0;
            RREADY = 1'b1;
        end
    endcase
end

always_comb begin
    RREADY_S0 = 1'b0;
    RREADY_S1 = 1'b0;
    RREADY_S2 = 1'b0;
    RREADY_S3 = 1'b0;
    RREADY_S4 = 1'b0;
    RREADY_S5 = 1'b0;
    RREADY_S6 = 1'b0;
    case(slave)
        `AXI_SLAVE0:begin
            RID = RID_S0;
            RDATA = RDATA_S0;
            RRESP = RRESP_S0;
            RLAST = RLAST_S0;
            RVALID = RVALID_S0;
            RREADY_S0 = RREADY;
        end
        `AXI_SLAVE1:begin
            RID = RID_S1;
            RDATA = RDATA_S1;
            RRESP = RRESP_S1;
            RLAST = RLAST_S1;
            RVALID = RVALID_S1;
            RREADY_S1 = RREADY;
        end
        `AXI_SLAVE2:begin
            RID = RID_S2;
            RDATA = RDATA_S2;
            RRESP = RRESP_S2;
            RLAST = RLAST_S2;
            RVALID = RVALID_S2;
            RREADY_S2 = RREADY;
        end
        `AXI_SLAVE3:begin
            RID = RID_S3;
            RDATA = RDATA_S3;
            RRESP = RRESP_S3;
            RLAST = RLAST_S3;
            RVALID = RVALID_S3;
            RREADY_S3 = RREADY;
        end
        `AXI_SLAVE4:begin
            RID = RID_S4;
            RDATA = RDATA_S4;
            RRESP = RRESP_S4;
            RLAST = RLAST_S4;
            RVALID = RVALID_S4;
            RREADY_S4 = RREADY;
        end
        `AXI_SLAVE5:begin
            RID = RID_S5;
            RDATA = RDATA_S5;
            RRESP = RRESP_S5;
            RLAST = RLAST_S5;
            RVALID = RVALID_S5;
            RREADY_S5 = RREADY;
        end
        `AXI_SLAVE6:begin
            RID = RID_S6;
            RDATA = RDATA_S6;
            RRESP = RRESP_S6;
            RLAST = RLAST_S6;
            RVALID = RVALID_S6;
            RREADY_S6 = RREADY;
        end
        default: begin
            RID = `AXI_IDS_BITS'b0;
            RDATA = `AXI_DATA_BITS'b0;
            RRESP = 2'b0;
            RLAST = 1'b1;
            RVALID = 1'b0;
        end
    endcase
end

endmodule
