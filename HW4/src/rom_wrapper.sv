`include "AXI_define.svh"
`define ROM_STATE_BITS 2
module rom_wrapper(
    AXI_slave_p.slave slave,
    input clk,
    input rst,
    input [31:0]ROM_out,
    output logic ROM_read,
    output logic ROM_enable,
    output logic [13:0]ROM_address
);

parameter STATE_IDLE = `ROM_STATE_BITS'b0,
          STATE_WAIT = `ROM_STATE_BITS'b1,
          STATE_READ = `ROM_STATE_BITS'b10,
          STATE_WAIT2 = `ROM_STATE_BITS'b11;

logic [`ROM_STATE_BITS-1:0] state;
logic [`ROM_STATE_BITS-1:0] nxt_state;
logic [`AXI_IDS_BITS-1:0] prevID;
logic [`AXI_BURST_BITS-1:0] prevBurst;
logic [`AXI_LEN_BITS-1:0] prevLEN;
logic [`AXI_LEN_BITS-1:0] cnt;
logic [`AXI_LEN_BITS-1:0] cnt_add;
logic [`AXI_SIZE_BITS-1:0] prevSIZE;
logic [31:0] data_reg;
logic ARFin;
logic RFin;
logic incr;
logic prev_incr;

assign ARFin = slave.ARREADY & slave.ARVALID;
assign RFin = slave.RREADY & slave.RVALID;
assign slave.BID = prevID;
assign slave.BRESP = `AXI_RESP_SLVERR;
assign slave.RID = prevID;
assign slave.RLAST = cnt == prevLEN | (prevBurst == 2'b0); 
assign slave.RRESP = `AXI_RESP_OKAY;
assign slave.RDATA = data_reg;
assign cnt_add = cnt + `AXI_LEN_BITS'b1;


always_ff@(posedge clk or negedge rst) begin
    if(~rst) begin
        state <= STATE_IDLE;
    end
    else begin
        state <= nxt_state;
    end
end

always_comb begin
    case(state)
        STATE_IDLE:nxt_state = (slave.ARVALID) ? STATE_WAIT2: STATE_IDLE;
        STATE_WAIT2:nxt_state = STATE_WAIT;
        STATE_WAIT:nxt_state =STATE_READ;
        STATE_READ:nxt_state = (slave.RLAST & RFin) ? STATE_IDLE : STATE_READ;
        default:nxt_state = STATE_IDLE;
    endcase
end

always_comb begin
    case(state)
        STATE_IDLE:begin 
            slave.ARREADY = 1'b1;
            slave.AWREADY = 1'b1;
            slave.WREADY = 1'b1;
            slave.RVALID = 1'b0;
            incr = 1'b0;
        end 
        STATE_WAIT2:begin
            slave.ARREADY = 1'b0;
            slave.AWREADY = 1'b0;
            slave.WREADY = 1'b0;
            slave.RVALID = 1'b0;
            incr = 1'b1;
        end
        STATE_WAIT:begin
            slave.ARREADY = 1'b0;
            slave.AWREADY = 1'b0;
            slave.WREADY = 1'b0;
            slave.RVALID = 1'b1;
            incr = 1'b1;
        end
        STATE_READ:begin
            slave.ARREADY = 1'b0;
            slave.AWREADY = 1'b0;
            slave.WREADY = 1'b0;
            slave.RVALID = 1'b1;
            incr = RFin;
        end
        default:begin
            slave.ARREADY = 1'b0;
            slave.AWREADY = 1'b0;
            slave.WREADY = 1'b0;
            slave.RVALID = 1'b0;
            incr = 1'b0;
        end
    endcase
end

always_ff@(posedge clk or negedge rst) begin
    if(~rst) begin
        prevID      <= `AXI_IDS_BITS'b0;
        prevBurst   <= `AXI_BURST_BITS'b0;
        prevLEN     <= `AXI_LEN_BITS'b0;
        cnt         <= `AXI_LEN_BITS'b0;
        prevSIZE    <= `AXI_SIZE_BITS'b0;
        ROM_read    <= 1'b0;
        ROM_enable  <= 1'b0;
        ROM_address <= 14'b0;
        data_reg <= 32'b0; 
        prev_incr   <= 1'b0;
	slave.BVALID <= 1'b0;
    end
    else begin
        prev_incr   <= incr;
        prevID      <= (ARFin) ? slave.ARID :(slave.AWVALID) ? slave.AWID : prevID;
        prevBurst   <= (ARFin) ? slave.ARBURST : prevBurst;
        prevLEN     <= (ARFin) ? slave.ARLEN : prevLEN;
        prevSIZE    <= (ARFin) ? slave.ARSIZE : prevSIZE;
        ROM_read    <= (slave.RLAST & RFin) ? 1'b0 : (ARFin) ? 1'b1 : ROM_read;
        ROM_enable  <= (slave.RLAST & RFin) ? 1'b0 : (ARFin) ? 1'b1 : ROM_enable;
        cnt         <= (slave.RLAST & RFin) ? `AXI_LEN_BITS'b0 : (RFin) ? cnt_add : cnt;
        ROM_address <= (ARFin) ? slave.ARADDR[2+:14] : (incr) ? ROM_address + {6'b0,cnt_add} : ROM_address; 
        data_reg <= (prev_incr & incr) ? ROM_out : data_reg; 
	slave.BVALID <= (slave.BVALID & slave.BREADY) ? 1'b0 : (slave.WREADY & slave.WVALID) ? 1'b1 : slave.BVALID;
    end
end

endmodule
