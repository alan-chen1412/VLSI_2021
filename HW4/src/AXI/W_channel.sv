`include "AXI_define.svh"
module W_channel(
    input clk,
    input rst,

    input [`AXI_SLAVE_BITS-1:0] AW_slave,

	input [`AXI_DATA_BITS-1:0] WDATA_M0,
	input [`AXI_STRB_BITS-1:0] WSTRB_M0,
	input WLAST_M0,
	input WVALID_M0,
        input AWVALID_M0,
	input AWREADY_M0,
	output logic WREADY_M0,

	input [`AXI_DATA_BITS-1:0] WDATA_M1,
	input [`AXI_STRB_BITS-1:0] WSTRB_M1,
	input WLAST_M1,
	input WVALID_M1,
    input AWVALID_M1,
	input AWREADY_M1,
	output logic WREADY_M1,

	input [`AXI_DATA_BITS-1:0] WDATA_M2,
	input [`AXI_STRB_BITS-1:0] WSTRB_M2,
	input WLAST_M2,
	input WVALID_M2,
	input AWREADY_M2,
    input AWVALID_M2,
	output logic WREADY_M2,

	output logic [`AXI_DATA_BITS-1:0] WDATA_S0,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S0,
	output logic WLAST_S0,
	output logic WVALID_S0,
	input WREADY_S0,

	output logic [`AXI_DATA_BITS-1:0] WDATA_S1,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S1,
	output logic WLAST_S1,
	output logic WVALID_S1,
	input WREADY_S1,

	output logic [`AXI_DATA_BITS-1:0] WDATA_S2,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S2,
	output logic WLAST_S2,
	output logic WVALID_S2,
	input WREADY_S2,

	output logic [`AXI_DATA_BITS-1:0] WDATA_S3,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S3,
	output logic WLAST_S3,
	output logic WVALID_S3,
	input WREADY_S3,

	output logic [`AXI_DATA_BITS-1:0] WDATA_S4,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S4,
	output logic WLAST_S4,
	output logic WVALID_S4,
	input WREADY_S4,

	output logic [`AXI_DATA_BITS-1:0] WDATA_S5,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S5,
	output logic WLAST_S5,
	output logic WVALID_S5,
	input WREADY_S5,

	output logic [`AXI_DATA_BITS-1:0] WDATA_S6,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S6,
	output logic WLAST_S6,
	output logic WVALID_S6,
	input WREADY_S6
);

logic [`AXI_MASTER_BITS-1:0] Master;
logic [`AXI_DATA_BITS-1:0] WDATA;
logic [`AXI_STRB_BITS-1:0] WSTRB;
logic WLAST;
logic WVALID;
logic WREADY;
logic [`AXI_MASTER_BITS-1:0] nxtMaster;
logic [`AXI_SLAVE_BITS-1:0] slave_m0;
logic [`AXI_SLAVE_BITS-1:0] slave_m1;
logic [`AXI_SLAVE_BITS-1:0] slave_m2;
logic [`AXI_SLAVE_BITS-1:0] slave;
logic lockAW0;
logic lockAW1;
logic lockAW2;
logic lockMaster0;
logic lockMaster1;
logic lockMaster2;
logic lockMaster;
assign WDATA_S0 = WDATA;
assign WSTRB_S0 = WSTRB;
assign WLAST_S0 = WLAST;
assign WDATA_S1 = WDATA;
assign WSTRB_S1 = WSTRB;
assign WLAST_S1 = WLAST;
assign WDATA_S2 = WDATA;
assign WSTRB_S2 = WSTRB;
assign WLAST_S2 = WLAST;
assign WDATA_S3 = WDATA;
assign WSTRB_S3 = WSTRB;
assign WLAST_S3 = WLAST;
assign WDATA_S4 = WDATA;
assign WSTRB_S4 = WSTRB;
assign WLAST_S4 = WLAST;
assign WDATA_S5 = WDATA;
assign WSTRB_S5 = WSTRB;
assign WLAST_S5 = WLAST;
assign WDATA_S6 = WDATA;
assign WSTRB_S6 = WSTRB;
assign WLAST_S6 = WLAST;
assign lockMaster = lockMaster0 | lockMaster1 | lockMaster2;

always_ff@(posedge clk or negedge rst) begin
    if(~rst)begin
        slave_m0 <= `AXI_SLAVE_BITS'b0;
        slave_m1 <= `AXI_SLAVE_BITS'b0;
        slave_m2 <= `AXI_SLAVE_BITS'b0;
	    lockAW0 <= 1'b0;
	    lockAW1 <= 1'b0;
	    lockAW2 <= 1'b0;
	    lockMaster0 <= 1'b0;
	    lockMaster1 <= 1'b0;
	    lockMaster2 <= 1'b0;
    end
    else begin
        slave_m0 <= (AWVALID_M0 & AWREADY_M0) ? AW_slave : slave_m0;
        slave_m1 <= (AWVALID_M1 & AWREADY_M1) ? AW_slave : slave_m1;
        slave_m2 <= (AWVALID_M2 & AWREADY_M2) ? AW_slave : slave_m2;
	    lockAW0 <= (lockAW0 & WVALID_M0 & WREADY_M0 & WLAST_M0) ? 1'b0 : (AWVALID_M0 & AWREADY_M0) ? 1'b1 : lockAW0;
	    lockAW1 <= (lockAW1 & WVALID_M1 & WREADY_M1 & WLAST_M1) ? 1'b0 : (AWVALID_M1 & AWREADY_M1) ? 1'b1 : lockAW1;
	    lockAW2 <= (lockAW2 & WVALID_M2 & WREADY_M2 & WLAST_M2) ? 1'b0 : (AWVALID_M2 & AWREADY_M2) ? 1'b1 : lockAW2;
	    lockMaster0 <= (lockMaster0 & WVALID_M0 & WREADY_M0 &WLAST_M0) ? 1'b0 : (WVALID_M0 & ~WREADY_M0 & ~lockMaster & ~WVALID_M1 & ~WVALID_M2)?1'b1:lockMaster0;
	    lockMaster1 <= (lockMaster1 & WVALID_M1 & WREADY_M1 &WLAST_M1) ? 1'b0 : (WVALID_M1 & ~WREADY_M1 & ~lockMaster & ~WVALID_M2)?1'b1:lockMaster1;
	    lockMaster2 <= (lockMaster2 & WVALID_M2 & WREADY_M2 &WLAST_M2) ? 1'b0 : (WVALID_M0 & ~WREADY_M0 & ~lockMaster)?1'b1:lockMaster2;
    end
end




always_comb begin
    if((WVALID_M2 & ~lockMaster) |lockMaster2 ) begin
        Master = `AXI_MASTER2;
    end
    else if ((WVALID_M1 & ~lockMaster) | lockMaster1) begin
        Master = `AXI_MASTER1;
    end
    else if ((WVALID_M0 & ~lockMaster)|lockMaster0) begin
        Master = `AXI_MASTER2;
    end
    else begin
        Master = `AXI_DEFAULT_MASTER;
    end
end

always_comb begin
   WVALID_S0 = 1'b0;
   WVALID_S1 = 1'b0;
   WVALID_S2 = 1'b0;
   WVALID_S3 = 1'b0;
   WVALID_S4 = 1'b0;
   WVALID_S5 = 1'b0;
   WVALID_S6 = 1'b0;
   if(WVALID) begin
    case(slave)
        `AXI_SLAVE0:begin
            WREADY = WREADY_S0;
	         WVALID_S0 = WVALID;
        end
        `AXI_SLAVE1:begin
            WREADY = WREADY_S1;
	        WVALID_S1 = WVALID;
        end
        `AXI_SLAVE2:begin
            WREADY = WREADY_S2;
	        WVALID_S2 = WVALID;
        end
        `AXI_SLAVE3:begin
            WREADY = WREADY_S3;
	        WVALID_S3 = WVALID;
        end
        `AXI_SLAVE4:begin
            WREADY = WREADY_S4;
	        WVALID_S4 = WVALID;
        end
        `AXI_SLAVE5:begin
            WREADY = WREADY_S5;
	        WVALID_S5 = WVALID;
        end
        `AXI_SLAVE6:begin
            WREADY = WREADY_S6;
	        WVALID_S6 = WVALID;
        end
        default:begin
            WREADY = 1'b1;
        end
    endcase
   end
   else begin
     WREADY = 1'b1;
   WVALID_S0 = 1'b0;
   WVALID_S1 = 1'b0;
   WVALID_S2 = 1'b0;
   WVALID_S3 = 1'b0;
   WVALID_S4 = 1'b0;
   WVALID_S5 = 1'b0;
   WVALID_S6 = 1'b0;
   end
end

always_comb begin
    case(Master)
        `AXI_MASTER0:begin
            WDATA = WDATA_M0;
            WSTRB = WSTRB_M0;
            WLAST = WLAST_M0;
            WVALID = WVALID_M0 & (lockAW0 | (AWVALID_M0 & AWREADY_M0));
            WREADY_M0 = WREADY & WVALID_M0;
            WREADY_M1 = 1'b0;
            WREADY_M2 = 1'b0;
            slave = (AWVALID_M0 & AWREADY_M0) ? AW_slave: slave_m0;
        end
        `AXI_MASTER1:begin
            WDATA = WDATA_M1;
            WSTRB = WSTRB_M1;
            WLAST = WLAST_M1;
            WVALID = WVALID_M1 & (lockAW1 | (AWVALID_M1 & AWREADY_M1));
            WREADY_M1 = WREADY & WVALID_M1;
            WREADY_M0 = 1'b0;
            WREADY_M2 = 1'b0;
            slave = (AWVALID_M1 & AWREADY_M1) ? AW_slave: slave_m1;
        end
        `AXI_MASTER2:begin
            WDATA = WDATA_M2;
            WSTRB = WSTRB_M2;
            WLAST = WLAST_M2;
            WVALID =WVALID_M2 & (lockAW2 | (AWVALID_M2 & AWREADY_M2));
            WREADY_M2 = WREADY & WVALID_M2;
            WREADY_M1 = 1'b0;
            WREADY_M0 = 1'b0;
            slave = slave_m2;
            slave = (AWVALID_M2 & AWREADY_M2) ? AW_slave: slave_m2;
        end
        default:begin
            WDATA = WDATA_M0;
            WSTRB = WSTRB_M0;
            WLAST = 1'b1;
            WVALID = 1'b0;
            WREADY_M0 = 1'b0;
            WREADY_M1 = 1'b0;
            WREADY_M2 = 1'b0;
            slave = `AXI_SLAVE_BITS'b0;
            slave = (AWVALID_M0 & AWREADY_M0) ? AW_slave: slave_m0;
        end
    endcase
end

endmodule
