`include "AXI_define.svh"
`define STATE_BITS 2


module SRAM_wrapper(
        AXI_slave_p.slave slave,
        input clk,
        input rst
);

parameter STATE_IDLE = `STATE_BITS'b0,
          STATE_READ = `STATE_BITS'b1,
          STATE_WRITE = `STATE_BITS'b10,
          STATE_WAIT = `STATE_BITS'b11;

logic [13:0] A;
logic [`AXI_DATA_BITS-1:0] DI;
logic [`AXI_DATA_BITS-1:0] DO;
logic [`AXI_STRB_BITS-1:0] WEB;
logic CS;
logic OE;
logic [`STATE_BITS-1:0] state;
logic [`STATE_BITS-1:0] nxt_state; 
logic AWFin;
logic WFin;
logic BFin;
logic RFin;
logic ARFin;
logic lockWFin;
logic lockAWFin;
logic lockBFin;
logic [13:0] prev_A;
logic [`AXI_IDS_BITS-1:0] prev_ID;
logic [`AXI_LEN_BITS-1:0] prev_LEN;
logic [`AXI_SIZE_BITS-1:0] prev_SIZE;
logic [1:0] prev_BURST;
logic [`AXI_LEN_BITS-1:0] rcnt;
logic [`AXI_LEN_BITS-1:0] rcnt_add;
logic [1:0] w_offset;
logic write;

assign AWFin = slave.AWVALID & slave.AWREADY;
assign WFin  = slave.WVALID  & slave.WREADY;
assign BFin  = slave.BVALID  & slave.BREADY;
assign ARFin = slave.ARVALID & slave.ARREADY;
assign RFin  = slave.RVALID  & slave.RREADY;
assign slave.RLAST = rcnt == prev_LEN;
assign slave.BID = prev_ID;
assign slave.RID = prev_ID;
assign slave.RRESP = `AXI_RESP_OKAY;
assign slave.BRESP = `AXI_RESP_OKAY;
assign slave.RDATA = DO;
assign DI = slave.WDATA;
assign rcnt_add = rcnt + `AXI_LEN_BITS'b1;

always_ff@(posedge clk or negedge rst)begin
	if(~rst)
		state <= STATE_IDLE;
	else 
		state <= nxt_state;
end

always_comb begin
    case(state)
        STATE_IDLE: begin
            nxt_state = (slave.AWVALID) ? STATE_WRITE : (slave.ARVALID) ? STATE_WAIT : STATE_IDLE;
        end
        STATE_WAIT: begin
            nxt_state = STATE_READ;
        end
        STATE_READ: begin
            nxt_state = (RFin & slave.RLAST) ? STATE_IDLE : STATE_READ;
        end
        STATE_WRITE:
            nxt_state = (BFin & slave.WLAST) ? STATE_IDLE : STATE_WRITE;
        //default:
        //    nxt_state = state;
    endcase
end

always_comb begin
    case(state)
        STATE_IDLE:begin
            slave.AWREADY = 1'b1;
            slave.ARREADY = ~slave.AWVALID;
            slave.RVALID = 1'b0;
            slave.WREADY = 1'b0;
            slave.BVALID = 1'b0;
            CS = slave.AWVALID | slave.ARVALID;
            OE = ~slave.AWVALID & slave.ARVALID;
        end
        STATE_WAIT:begin
            slave.AWREADY = 1'b0;
            slave.ARREADY = 1'b0;
            slave.RVALID = 1'b0;
            slave.WREADY  = 1'b0;
            slave.BVALID = 1'b0;
            CS = 1'b1;
            OE = 1'b1;
        end
        STATE_READ:begin
            slave.AWREADY = 1'b0;
            slave.ARREADY = 1'b0;
            slave.RVALID = 1'b1;
            slave.WREADY  = 1'b0;
            slave.BVALID = 1'b0;
            CS = 1'b1;
            OE = 1'b1;
        end
        STATE_WRITE:begin
            slave.AWREADY = 1'b0;
            slave.ARREADY = 1'b0;
            slave.RVALID  = 1'b0;
            slave.WREADY  = (~(slave.WLAST & BFin) & (BFin | lockBFin)) | lockAWFin;
            slave.BVALID  = lockWFin;
            CS = 1'b1;
            OE = 1'b0;
        end
        //default:begin
        //    slave.AWREADY = 1'b0;
        //    slave.ARREADY = 1'b0;
        //    slave.RVALID = 1'b0;
        //    slave.WREADY  = 1'b0;
        //    slave.BVALID = 1'b0;
        //    CS = 1'b0;
        //    OE = 1'b0;
        //end
    endcase
end

always_ff@(posedge clk or negedge rst) begin
    if(~rst) begin
        prev_A       <=  14'b0;
        prev_ID      <=  `AXI_IDS_BITS'b0;
        prev_LEN     <=  `AXI_LEN_BITS'b0;
        prev_SIZE    <=  `AXI_SIZE_BITS'b0;
        prev_BURST   <=  2'b0;
        rcnt <= `AXI_LEN_BITS'b0;
        lockWFin <= 1'b0;
        lockAWFin <= 1'b0;
        lockBFin <= 1'b0;
        w_offset <= 2'b0;
        write <= 1'b0;
    end
    else begin
        write    <= (write & BFin & slave.WLAST) ? 1'b0 : (AWFin) ? 1'b1 : write;
        w_offset <= (AWFin) ? slave.AWADDR[1:0] : w_offset;
        lockAWFin    <= (lockAWFin & WFin) ? 1'b0 : (AWFin) ? 1'b1 : lockAWFin;
        lockBFin     <= (BFin ) ? 1'b1 : (lockBFin & WFin) ? 1'b0 : lockBFin; 
        lockWFin     <= (WFin ) ? 1'b1 : (lockWFin & BFin) ? 1'b0 : lockWFin;
        prev_A       <= (AWFin) ? slave.AWADDR [15:2] : (ARFin) ? slave.ARADDR [15:2] : prev_A;
        prev_ID      <= (AWFin) ? slave.AWID          : (ARFin) ? slave.ARID          : prev_ID;
        prev_LEN     <= (AWFin) ? slave.AWLEN         : (ARFin) ? slave.ARLEN         : prev_LEN;
        prev_SIZE    <= (AWFin) ? slave.AWSIZE        : (ARFin) ? slave.ARSIZE        : prev_SIZE;
        prev_BURST   <= (AWFin) ? slave.AWBURST       : (ARFin) ? slave.ARBURST       : prev_BURST;
        rcnt <= ((BFin & slave.WLAST) | (RFin & slave.RLAST)) ? `AXI_LEN_BITS'b0 : (RFin | WFin) ? rcnt_add : rcnt;
    end
end

always_comb begin
    unique if(prev_BURST == `AXI_BURST_FIXED)begin
        A = prev_A;
    end
    else if(prev_BURST == `AXI_BURST_INC)begin
        if(write)
            A = /*((RFin | WFin) & ~lockAWFin) ? prev_A + {6'b0,rcnt_add} :*/ prev_A + {6'b0,rcnt};
        else 
            A = ((RFin | WFin) & ~lockAWFin) ? prev_A + {6'b0,rcnt_add} : prev_A + {6'b0,rcnt};
            
    end
    else begin
        A = prev_A;
    end
end

always_comb begin
    WEB = 4'hf;
    if(WFin) begin
        case(slave.WSTRB)
            `AXI_STRB_BYTE: WEB[w_offset] = 1'b0;
            `AXI_STRB_HWORD: WEB[{w_offset[1],1'b0}+:2] = 2'b0;
            default:WEB = 4'h0;
        endcase
    end
    else WEB = 4'hf;
end


  SRAM i_SRAM (
    .A0   (A[0]  ),
    .A1   (A[1]  ),
    .A2   (A[2]  ),
    .A3   (A[3]  ),
    .A4   (A[4]  ),
    .A5   (A[5]  ),
    .A6   (A[6]  ),
    .A7   (A[7]  ),
    .A8   (A[8]  ),
    .A9   (A[9]  ),
    .A10  (A[10] ),
    .A11  (A[11] ),
    .A12  (A[12] ),
    .A13  (A[13] ),
    .DO0  (DO[0] ),
    .DO1  (DO[1] ),
    .DO2  (DO[2] ),
    .DO3  (DO[3] ),
    .DO4  (DO[4] ),
    .DO5  (DO[5] ),
    .DO6  (DO[6] ),
    .DO7  (DO[7] ),
    .DO8  (DO[8] ),
    .DO9  (DO[9] ),
    .DO10 (DO[10]),
    .DO11 (DO[11]),
    .DO12 (DO[12]),
    .DO13 (DO[13]),
    .DO14 (DO[14]),
    .DO15 (DO[15]),
    .DO16 (DO[16]),
    .DO17 (DO[17]),
    .DO18 (DO[18]),
    .DO19 (DO[19]),
    .DO20 (DO[20]),
    .DO21 (DO[21]),
    .DO22 (DO[22]),
    .DO23 (DO[23]),
    .DO24 (DO[24]),
    .DO25 (DO[25]),
    .DO26 (DO[26]),
    .DO27 (DO[27]),
    .DO28 (DO[28]),
    .DO29 (DO[29]),
    .DO30 (DO[30]),
    .DO31 (DO[31]),
    .DI0  (DI[0] ),
    .DI1  (DI[1] ),
    .DI2  (DI[2] ),
    .DI3  (DI[3] ),
    .DI4  (DI[4] ),
    .DI5  (DI[5] ),
    .DI6  (DI[6] ),
    .DI7  (DI[7] ),
    .DI8  (DI[8] ),
    .DI9  (DI[9] ),
    .DI10 (DI[10]),
    .DI11 (DI[11]),
    .DI12 (DI[12]),
    .DI13 (DI[13]),
    .DI14 (DI[14]),
    .DI15 (DI[15]),
    .DI16 (DI[16]),
    .DI17 (DI[17]),
    .DI18 (DI[18]),
    .DI19 (DI[19]),
    .DI20 (DI[20]),
    .DI21 (DI[21]),
    .DI22 (DI[22]),
    .DI23 (DI[23]),
    .DI24 (DI[24]),
    .DI25 (DI[25]),
    .DI26 (DI[26]),
    .DI27 (DI[27]),
    .DI28 (DI[28]),
    .DI29 (DI[29]),
    .DI30 (DI[30]),
    .DI31 (DI[31]),
    .CK   (clk   ),
    .WEB0 (WEB[0]),
    .WEB1 (WEB[1]),
    .WEB2 (WEB[2]),
    .WEB3 (WEB[3]),
    .OE   (OE    ),
    .CS   (CS    )
  );

endmodule
