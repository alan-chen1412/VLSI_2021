`include "AXI_define.svh"

module DMA_slave(
    input clk,
    input rst,
    AXI_slave_p.slave slave,
    input clear_reg,
    output logic start,
    output logic [`AXI_ADDR_BITS-1:0] source_addr,
    output logic [`AXI_ADDR_BITS-1:0] dest_addr,
    output logic [`AXI_DATA_BITS-1:0] length
);


parameter STATE_IDLE = 2'b0,
          STATE_READ = 2'b1,
          STATE_WRITE = 2'b10;

logic [1:0] state;
logic [1:0] nxt_state;
logic RFin;
logic WFin;
logic BFin;
logic [2:0] prevADDR;
logic [2:0] DMA_ADDR;
logic [`AXI_LEN_BITS-1:0] prevLEN;
logic [`AXI_SIZE_BITS-1:0] prevSIZE;
logic [`AXI_IDS_BITS-1:0] prevID;
logic [1:0] prevBURST;
logic [`AXI_LEN_BITS-1:0] cnt;
logic [`AXI_LEN_BITS-1:0] cnt_add;
logic prevWLAST;
logic finish;


assign RFin = slave.RREADY & slave.RVALID;
assign BFin = slave.BREADY & slave.BVALID;
assign cnt_add = cnt + `AXI_LEN_BITS'b1;
assign slave.BID = prevID;
assign slave.BRESP = (cnt > `AXI_LEN_BITS'b11) ?`AXI_RESP_SLVERR :`AXI_RESP_OKAY;
assign slave.RID = prevID; 
assign slave.RRESP = (cnt > `AXI_LEN_BITS'b11) ?`AXI_RESP_SLVERR :`AXI_RESP_OKAY; 
assign slave.RLAST = cnt == prevLEN;

always_ff@(posedge clk or negedge rst) begin
    if(~rst)
        state <= STATE_IDLE;
    else 
        state <= nxt_state;
end


always_comb begin
    case(state)
        STATE_IDLE  : nxt_state = slave.AWVALID ? STATE_WRITE : slave.ARVALID ? STATE_READ : STATE_IDLE;
        STATE_READ  : nxt_state = (RFin & slave.RLAST) ? STATE_IDLE : STATE_READ;
        STATE_WRITE : nxt_state = (BFin & slave.WLAST) ? STATE_IDLE : STATE_WRITE;
        default : nxt_state = STATE_IDLE;
    endcase
end

always_comb begin
    case(state)
        STATE_IDLE  :begin  
            slave.ARREADY = ~slave.AWVALID;
            slave.AWREADY = 1'b1;
            slave.WREADY = 1'b0;
            slave.BVALID = 1'b0;
            slave.RVALID = 1'b0;
        end
        STATE_READ  :begin
            slave.ARREADY = 1'b0;
            slave.AWREADY = 1'b0;
            slave.WREADY = 1'b0;
            slave.BVALID = 1'b0;
            slave.RVALID = 1'b1;
        end
        STATE_WRITE :begin
            slave.ARREADY = 1'b0;
            slave.AWREADY = 1'b0;
            slave.WREADY = ~WFin | BFin;
            slave.BVALID = WFin;
            slave.RVALID = 1'b0;
        end
        default     :begin
            slave.ARREADY = 1'b0;
            slave.AWREADY = 1'b0;
            slave.WREADY = 1'b0;
            slave.BVALID = 1'b0;
            slave.RVALID = 1'b0;
        end
    endcase
end

always_ff@(posedge clk or negedge rst) begin
    if(~rst) begin
        WFin <= 1'b0;
        prevADDR  <= 3'b0;
        prevID    <= `AXI_IDS_BITS'b0;
        prevBURST <= `AXI_BURST_FIXED;
        prevLEN   <= `AXI_LEN_BITS'b0;
        prevSIZE  <= `AXI_SIZE_BITS'b0;
        cnt <= `AXI_LEN_BITS'b0;
        prevWLAST <= 1'b0;
    end
    else begin
        prevWLAST <= (WFin) ? slave.WLAST : prevWLAST;
        WFin <= (slave.WREADY & slave.WVALID) ? 1'b1 :(WFin & BFin) ? 1'b0  : WFin;
        prevADDR     <=(slave.ARVALID & slave.ARREADY)?slave.ARADDR[4:2]  :(slave.AWVALID & slave.AWREADY)?slave.AWADDR[4:2] :prevADDR;
        prevID       <=(slave.ARVALID & slave.ARREADY)?slave.ARID    :(slave.AWVALID & slave.AWREADY)?slave.AWID   :prevID;
        prevBURST    <=(slave.ARVALID & slave.ARREADY)?slave.ARBURST :(slave.AWVALID & slave.AWREADY)?slave.AWBURST:prevBURST;
        prevLEN      <=(slave.ARVALID & slave.ARREADY)?slave.ARLEN :(slave.AWVALID & slave.AWREADY)?slave.AWLEN:prevLEN;
        prevSIZE     <=(slave.ARVALID & slave.ARREADY)?slave.ARSIZE  :(slave.AWVALID & slave.AWREADY)?slave.AWSIZE :prevSIZE; 
        cnt <= ((BFin & prevWLAST) | (RFin & slave.RLAST)) ? `AXI_LEN_BITS'b0 : (BFin | RFin) ? cnt_add : cnt;
    end
end

always_ff@(posedge clk or negedge rst) begin
    if(~rst) begin
        source_addr <= `AXI_ADDR_BITS'b0;
        dest_addr <= `AXI_ADDR_BITS'b0;
        length <= `AXI_DATA_BITS'b0;
        start <= 1'b0;
        finish <= 1'b0;
    end 
    else begin
        if(clear_reg) begin
            start <= 1'b0;
            finish <= 1'b1;
        end
        else if(slave.WVALID & slave.WREADY)begin
            case(DMA_ADDR)
                3'b000:source_addr <= slave.WDATA;
                3'b001:dest_addr <= slave.WDATA;
                3'b010:length <= slave.WDATA;
                3'b011:begin
                    start <= slave.WDATA[0];
                    finish <= 1'b0;
                end
            endcase
        end
    end
end

always_comb begin
    case(DMA_ADDR)
        3'b00 :slave.RDATA = source_addr;
        3'b01 :slave.RDATA = dest_addr;
        3'b10 :slave.RDATA = length;
        3'b11 :slave.RDATA = {31'b0,start};
        3'b100 :slave.RDATA = {31'b0,finish};
        default:slave.RDATA = 32'b0;
    endcase
end

always_comb begin
    unique if(prevBURST == `AXI_BURST_FIXED) begin
        DMA_ADDR = prevADDR;
    end
    else if (prevBURST == `AXI_BURST_INC) begin
        DMA_ADDR = (BFin) ? prevADDR + cnt_add[2:0] : prevADDR + cnt[2:0];
    end
    else begin
        DMA_ADDR = prevADDR;
    end
end

endmodule
