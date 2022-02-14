`include "AXI_define.svh"
module Default_Slave( 
    input clk,
    input rst,
    AXI_slave_p.slave slave
);

parameter STATE_IDLE = 2'b0,
	  STATE_READ = 2'b1,
	  STATE_WRITE = 2'b10;

logic [1:0] state;
logic [1:0] nxt_state;
logic AWFin;
logic RFin;
logic BFin;
logic WFin;
logic ARFin;
logic [`AXI_IDS_BITS-1:0] prevID;
logic lockW;
logic lockAW;

assign AWFin = slave.AWVALID & slave.AWREADY;
assign RFin = slave.RVALID & slave.RREADY;
assign BFin = slave.BVALID & slave.BREADY;
assign WFin = slave.WVALID & slave.WREADY;
assign ARFin = slave.ARVALID & slave.ARREADY;
assign slave.RDATA = 32'b0;
assign slave.RID = prevID;
assign slave.RRESP = `AXI_RESP_DECERR;
assign slave.BID = prevID;
assign slave.BRESP = `AXI_RESP_DECERR;
assign slave.RLAST = 1'b1;

always_ff@(posedge clk or negedge rst) begin
	if(~rst)
		state <= STATE_IDLE;
	else 
		state <= nxt_state;
end

always_comb begin
	case(state)
		STATE_IDLE:begin
			nxt_state = (slave.AWVALID) ? STATE_WRITE  : (slave.ARVALID) ?STATE_READ:STATE_IDLE;
		end
		STATE_READ:begin
			nxt_state = (RFin) ? STATE_IDLE : STATE_READ;
		end
		STATE_WRITE:begin
			nxt_state = (BFin) ? STATE_IDLE:STATE_WRITE;
		end
		default:nxt_state = STATE_IDLE;
	endcase
end

always_comb begin
	case(state)
		STATE_IDLE:begin
			slave.ARREADY = ~slave.AWVALID;
			slave.AWREADY = 1'b1;
			slave.WREADY = 1'b0;
			slave.BVALID = 1'b0;
			slave.RVALID = 1'b0;
		end
		STATE_READ:begin
			slave.ARREADY = 1'b0;
			slave.AWREADY = 1'b0;
			slave.WREADY = 1'b0;
			slave.BVALID = 1'b0;
			slave.RVALID = 1'b1;
		end
		STATE_WRITE:begin
			slave.ARREADY = 1'b0;
			slave.AWREADY = 1'b0;
			slave.WREADY = ~lockW;
			slave.BVALID = lockAW & lockW;
			slave.RVALID = 1'b0;
		end
		default:begin
			slave.ARREADY = 1'b0;
			slave.AWREADY = 1'b0;
			slave.WREADY = 1'b0;
			slave.BVALID = 1'b0;
			slave.RVALID = 1'b0;
		end
	endcase
end
always_ff@(posedge clk or negedge rst) begin
    if(~rst)begin
        prevID    <= `AXI_IDS_BITS'b0;
	lockW <= 1'b0;
	lockAW <= 1'b0;
    end
    else begin
        prevID       <=(ARFin)?slave.ARID    :(AWFin)?slave.AWID   :prevID;
	lockW <= (lockW & BFin) ? 1'b0 : (WFin) ? 1'b1 : lockW;
	lockAW <= (lockAW & BFin) ? 1'b0 : (AWFin) ? 1'b1 : lockAW;
    end
end


endmodule
