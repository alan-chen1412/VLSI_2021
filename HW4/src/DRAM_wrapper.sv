`include "AXI_slave_p.sv"
`include "FIFO.sv"
`define DRAM_STATE_BITS 2
module DRAM_wrapper(
    AXI_slave_p.slave slave,
    input [31:0]DRAM_Q,
	input DRAM_valid,
    input clk,
    input rst,
    output logic DRAM_CSn,
    output logic [3:0]DRAM_WEn,
    output logic DRAM_RASn,
    output logic DRAM_CASn,
    output logic [10:0]DRAM_A,
    output logic [31:0]DRAM_D
);

parameter STATE_IDLE   = `DRAM_STATE_BITS'b0,
          STATE_SETCOL = `DRAM_STATE_BITS'b1,
          STATE_SETROW = `DRAM_STATE_BITS'b10; 

FIFO_IF mem();
logic [`DRAM_STATE_BITS-1:0] state;
logic [`DRAM_STATE_BITS-1:0] nxt_state;
logic [`AXI_IDS_BITS-1:0] prevID;
logic [20:0] prevADDR;
logic [20:0] DRAM_ADDR;
logic [`AXI_LEN_BITS-1:0] prevLEN;
logic [`AXI_SIZE_BITS-1:0] prevSIZE;
logic [1:0] prevBURST;
logic [`AXI_LEN_BITS-1:0] cnt_data;
logic [`AXI_LEN_BITS-1:0] cnt_addr;
logic ARFin;
logic AWFin;
logic WFin;
logic RFin;
logic BFin;
logic finish;
logic write;
logic prevWFin;
logic [`AXI_DATA_BITS-1:0] prevData;
logic [`AXI_LEN_BITS-1:0] rcnt;
logic [`AXI_LEN_BITS-1:0] addrcnt;
logic [`AXI_LEN_BITS-1:0] rcnt_add;
logic [`AXI_LEN_BITS-1:0] addrcnt_add;
logic [10:0] ROW;
logic [10:0] prevROW;
logic [9:0] COL;
logic prevCASn;
logic [`AXI_STRB_BITS-1:0] prevWSTRB;
logic [`AXI_LEN_BITS-1:0] prev_cnt;

assign ROW = DRAM_ADDR[20:10];
assign COL = DRAM_ADDR[9:0];
assign ARFin = slave.ARREADY & slave.ARVALID;
assign AWFin = slave.AWREADY & slave.AWVALID;
assign WFin = slave.WREADY & slave.WVALID;
assign BFin = slave.BREADY & slave.BVALID;
assign RFin = slave.RREADY & slave.RVALID;
assign slave.BID = prevID;
assign slave.RID = prevID;
assign slave.RDATA = (mem.read) ? mem.rdata : prevData;
assign slave.BRESP = `AXI_RESP_OKAY;
assign slave.RRESP = `AXI_RESP_OKAY;
assign slave.RLAST = rcnt == prevLEN;
assign rcnt_add = rcnt + `AXI_LEN_BITS'b1;
assign addrcnt_add = addrcnt + `AXI_LEN_BITS'b1 ;
assign changeRow = prevROW != ROW;
assign finish = (BFin & slave.WLAST) | (RFin & slave.RLAST);
assign mem.wdata = DRAM_Q;
assign DRAM_D = slave.WDATA;

always_ff@(posedge clk or negedge rst) begin
    if(~rst) 
        state <= STATE_IDLE;
    else 
        state <= nxt_state;
end

always_comb begin
    case(state)
        STATE_IDLE : nxt_state   = (slave.AWVALID | slave.ARVALID) ? STATE_SETROW : STATE_IDLE;
        STATE_SETROW : nxt_state = (STATE_SETCOL) ;
        STATE_SETCOL : nxt_state = (finish) ? STATE_IDLE : (changeRow) ? STATE_SETROW : STATE_SETCOL;
        default :nxt_state = STATE_IDLE;
    endcase
end

always_comb begin
    case(state)
        STATE_IDLE:begin
            slave.ARREADY = ~slave.AWVALID;
            slave.AWREADY = 1'b1;
            slave.WREADY = 1'b0;
            slave.RVALID = 1'b0;
            slave.BVALID = 1'b0;
            DRAM_CSn = 1'b1;
            DRAM_RASn = 1'b1;
            DRAM_CASn = 1'b1;
            mem.read = 1'b0;
            mem.write = 1'b0;
            DRAM_A = 11'b0;
            DRAM_WEn = 4'hf;
        end
        STATE_SETROW:begin
            slave.ARREADY = 1'b0;
            slave.AWREADY = 1'b0;
            slave.WREADY = 1'b0;
            slave.RVALID = 1'b0;
            slave.BVALID = 1'b0;
            DRAM_CSn = 1'b0;
            DRAM_RASn = 1'b0;
            DRAM_CASn = 1'b1;
            mem.read = 1'b0;
            mem.write = 1'b0;
            DRAM_A = ROW;
            DRAM_WEn = 4'hf;
        end
        STATE_SETCOL:begin
            slave.ARREADY = 1'b0;
            slave.AWREADY = 1'b0;
            slave.WREADY = (~prevWFin | BFin) & write;
            slave.RVALID = ~mem._empty;
            slave.BVALID = prevWFin;
            DRAM_CSn  = 1'b0;
            DRAM_RASn = 1'b0;
            DRAM_CASn = write ? ~WFin : mem._full | ( prev_cnt== prevLEN);
            mem.read  = RFin;
            mem.write = DRAM_valid;
            DRAM_A = {1'b0,COL};
            DRAM_WEn = (slave.WVALID) ? 4'h0 : 4'hf;
        end
        default:begin
            slave.ARREADY = 1'b0;
            slave.AWREADY = 1'b0;
            slave.WREADY = 1'b0;
            slave.RVALID = 1'b0;
            slave.BVALID = 1'b0;
            DRAM_CSn = 1'b1;
            DRAM_RASn = 1'b1;
            DRAM_CASn = 1'b1;
            mem.read = 1'b0;
            mem.write = 1'b0;
            DRAM_A = 11'b0;
            DRAM_WEn = 4'hf;
        end
    endcase
end

always_ff@(posedge clk or negedge rst) begin
    if(~rst)begin
        prevADDR  <= 21'b0;
        prevID    <= `AXI_IDS_BITS'b0;
        prevBURST <= `AXI_BURST_FIXED;
        prevLEN   <= `AXI_LEN_BITS'b0;
        prevSIZE  <= `AXI_SIZE_BITS'b0;
        write <= 1'b0;
        prevWFin <= 1'b0;
        prevData <= `AXI_DATA_BITS'b0;
        rcnt <= `AXI_LEN_BITS'b0;
        addrcnt <= `AXI_LEN_BITS'b0;
        prevCASn <= 1'b0;
        prevROW <= 11'b0;
        prev_cnt <= `AXI_LEN_BITS'b0;
    end
    else begin
        prevADDR     <=(ARFin)?slave.ARADDR[2+:21]  :(AWFin)?slave.AWADDR[2+:21] :prevADDR;
        prevID       <=(ARFin)?slave.ARID    :(AWFin)?slave.AWID   :prevID;
        prevBURST    <=(ARFin)?slave.ARBURST :(AWFin)?slave.AWBURST:prevBURST;
        prevLEN      <=(ARFin)?slave.ARLEN   :(AWFin)?slave.AWLEN  :prevLEN;
        prevSIZE     <=(ARFin)?slave.ARSIZE  :(AWFin)?slave.AWSIZE :prevSIZE; 
        write <= (write & finish) ? 1'b0 : (AWFin) ? 1'b1 : write;
        prevWFin <= (WFin)? WFin : (prevWFin & BFin) ? 1'b0 : prevWFin; 
        prevData <= (mem.read) ? mem.rdata : prevData;
        rcnt <= (RFin & slave.RLAST) ? `AXI_LEN_BITS'b0 : (RFin) ? rcnt_add : rcnt;
        addrcnt <= ((RFin & slave.RLAST) | (BFin & slave.WLAST)) ? `AXI_LEN_BITS'b0 : (~DRAM_CASn) ? addrcnt_add:addrcnt;
        prevCASn <= DRAM_CASn;
        prevROW <= ROW;
        prev_cnt <= ((slave.RLAST & RFin)) | (slave.WLAST & BFin) ? `AXI_LEN_BITS'b0: (~DRAM_CASn) ? addrcnt : prev_cnt;
    end
end

always_comb begin
    unique if(prevBURST == `AXI_BURST_FIXED) begin
        DRAM_ADDR = prevADDR;
    end
    else if (prevBURST == `AXI_BURST_INC) begin
        DRAM_ADDR = (prevCASn & ~DRAM_CASn) ? prevADDR : prevADDR + {13'b0,addrcnt};  
    end
    else begin
        DRAM_ADDR = prevADDR;
    end
end

FIFO #(.SIZE_P(5))fifomem(
    .clk(clk),
    .rst(rst),
    .FIFOif(mem)
);


endmodule
