`include "AXI_define.svh"
`include "FIFO.sv"
module DMA_master(
    input clk,
    input rst,
    AXI_master_p.master master,
    output logic clear_reg,
    input start,
    input [`AXI_ADDR_BITS-1:0] source_addr,
    input [`AXI_ADDR_BITS-1:0] dest_addr,
    input [`AXI_DATA_BITS-1:0] length
);

parameter STATE_IDLE = 2'b0,
          STATE_SENDREAD = 2'b1,
          STATE_SENDWRITE = 2'b10,
          STATE_OPER = 2'b11;

logic [1:0] state;
logic [1:0] nxt_state;
logic ARFin;
logic AWFin;
logic RFin;
logic BFin;
logic WFin;
logic finish;
logic prevRLAST;
logic first_write;
logic prevWFin;
logic latch_read;
logic [31:0] prevRDATA;
FIFO_IF mem();

assign ARFin = master.ARVALID & master.ARREADY;
assign AWFin = master.AWVALID & master.AWREADY;
assign RFin  = master.RVALID & master.RREADY;
assign BFin = master.BVALID & master.BREADY;
assign WFin = master.WVALID & master.WREADY;
assign master.ARADDR = source_addr;
assign master.ARLEN = length[`AXI_LEN_BITS-1:0];
assign master.ARSIZE = `AXI_SIZE_BITS'b11;
assign master.ARBURST = `AXI_BURST_INC;
assign master.ARID = `AXI_ID_BITS'b0;
assign master.AWID = `AXI_ID_BITS'b0;
assign master.AWADDR = dest_addr;
assign master.AWLEN = length[`AXI_LEN_BITS-1:0];
assign master.AWSIZE = `AXI_SIZE_BITS'b11;
assign master.AWBURST = `AXI_BURST_INC;
assign master.WSTRB = 4'h0;
assign mem.wdata = master.RDATA;
assign master.WDATA = (mem.read) ? mem.rdata : prevRDATA; 
assign master.WLAST = mem._empty & prevRLAST;
assign finish = master.WLAST & BFin;
assign clear_reg = finish | (length == 32'b0 & start);

always_ff@(posedge clk or negedge rst) begin
    if(~rst)
        state <= STATE_IDLE;
    else 
        state <= nxt_state;
end

always_comb begin
    case(state)
        STATE_IDLE: nxt_state = (start & (length != 32'b0)) ? STATE_SENDREAD : STATE_IDLE;
        STATE_SENDREAD:nxt_state = (ARFin) ? STATE_SENDWRITE : STATE_SENDREAD;
        STATE_SENDWRITE:nxt_state = (AWFin) ? STATE_OPER:STATE_SENDWRITE;
        STATE_OPER :nxt_state = (finish) ? STATE_IDLE:STATE_OPER;
    endcase
end

always_comb begin
    case(state)
        STATE_IDLE:begin
            master.ARVALID = 1'b0;
            master.AWVALID = 1'b0;
            master.WVALID = 1'b0;
            master.RREADY = 1'b0;
            master.BREADY = 1'b0;
            mem.read = 1'b0;
            mem.write = 1'b0;
        end
        STATE_SENDREAD:begin
            master.ARVALID = 1'b1;
            master.AWVALID = 1'b0;
            master.WVALID = 1'b0;
            master.RREADY = 1'b0;
            master.BREADY = 1'b0;
            mem.read = 1'b0;
            mem.write = 1'b0;
        end
        STATE_SENDWRITE:begin
            master.ARVALID = 1'b0;
            master.AWVALID = 1'b1;
            master.WVALID = 1'b0;
            master.RREADY = 1'b0;
            master.BREADY = 1'b0;
            mem.read = 1'b0;
            mem.write = 1'b0;
        end
        STATE_OPER:begin
            master.ARVALID = 1'b0;
            master.AWVALID = 1'b0;
            master.WVALID =  (~mem._empty & (first_write | prevWFin)) | (latch_read);
            master.RREADY = ~mem._full;
            master.BREADY = 1'b1;
            mem.read  = ~mem._empty &(first_write | prevWFin) ;
            mem.write = RFin;
        end
    endcase
end

always_ff@(posedge clk or negedge rst) begin
    if(~rst)begin
        prevRLAST <= 1'b0;
        first_write <= 1'b0;
        latch_read <= 1'b0;
        prevWFin <= 1'b0;
        prevRDATA <= 32'b0;
    end
    else begin
        prevRDATA <= (mem.read) ? mem.rdata  : prevRDATA;
        prevWFin <= master.WREADY & master.WVALID;
        latch_read <= (WFin) ? 1'b0 : (mem.read) ? 1'b1 : latch_read; 
        first_write <= (first_write & mem.read) ? 1'b0 : (AWFin) ? 1'b1 : first_write;
        prevRLAST <= (prevRLAST & master.WLAST & BFin) ? 1'b0 : (master.RLAST & RFin) ? 1'b1 : prevRLAST;
    end
end

FIFO #(.SIZE_P(2)) fifo(
    .clk(clk),
    .rst(rst),
    .FIFOif(mem)
);

endmodule
