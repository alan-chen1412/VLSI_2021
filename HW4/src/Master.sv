`include "AXI_define.svh"
`include "def.svh"
`define M_STATE_BITS 2

module Master(
    AXI_master_p.master master,
    //interface for cpu
    input clk,
    input rst,
    input req,
    input write,
    input [2:0] w_type,
    input [`AXI_DATA_BITS-1:0] data_in,
    input [`AXI_ADDR_BITS-1:0] addr,
    input volatile,
    output logic [`AXI_DATA_BITS-1:0] data_out,
    output logic stall
);

parameter STATE_IDLE  = `M_STATE_BITS'b0,
          STATE_READ  = `M_STATE_BITS'b1,
          STATE_WRITE = `M_STATE_BITS'b10;

logic [`M_STATE_BITS-1:0] state;
logic [`M_STATE_BITS-1:0] nxt_state;
logic AWFin;
logic WFin;
logic BFin;
logic RFin;
logic ARFin;
logic lockAW;
logic lockAR;
logic lockR;
logic lockW;
logic lockB;
logic reset;
logic lockVol;

assign master.AWID = `AXI_ID_BITS'b0;
assign master.AWLEN = `AXI_LEN_BITS'b0;
assign master.AWSIZE = `AXI_SIZE_BITS'b10;
assign master.AWBURST = 2'b0;
assign master.WLAST = 1'b1;
assign master.ARID = `AXI_ID_BITS'b0;
assign master.ARLEN = (volatile | lockVol) ? `AXI_LEN_BITS'b0:`AXI_LEN_BITS'b11;
assign master.ARSIZE = `AXI_SIZE_BITS'b10;
assign master.ARBURST = 2'b1;
assign master.AWADDR = addr;
assign master.ARADDR = {addr[31:4],4'b0};
assign master.WDATA = data_in;
assign data_out = master.RDATA;

assign AWFin = master.AWVALID & master.AWREADY;
assign WFin  = master.WVALID  & master.WREADY;
assign BFin  = master.BVALID  & master.BREADY;
assign ARFin = master.ARVALID & master.ARREADY;
assign RFin  = master.RVALID  & master.RREADY;

always_ff@(posedge clk or negedge rst) begin
    if(~rst)
        reset <= 1'b0;
    else 
        reset <= 1'b1;
end

always_ff@(posedge clk or negedge rst) begin
    if(~rst)
        state <= STATE_IDLE;
    else 
        state <= nxt_state;
end

always_comb begin
    case(state)
        STATE_IDLE:
            nxt_state = (req & write & reset) ? STATE_WRITE: (req & reset) ? STATE_READ: STATE_IDLE;
        STATE_READ:
            nxt_state = (RFin & master.RLAST) ? STATE_IDLE:STATE_READ;             
        STATE_WRITE: 
            nxt_state = BFin ? STATE_IDLE : STATE_WRITE; 
        default: begin
            nxt_state = state;
        end
    endcase
end

always_comb begin
    case(state)
        STATE_IDLE: begin
           master.AWVALID = req & write & reset;
           master.ARVALID = req & ~write & reset;
           master.WVALID = 1'b0;
           master.BREADY = 1'b0;
           master.RREADY = 1'b0; 
           stall = req;
        end
        STATE_READ: begin
           master.AWVALID = 1'b0; 
           master.ARVALID = lockAR;
           master.WVALID  = 1'b0;
           master.BREADY  = 1'b0;
           master.RREADY  = lockR; 
           stall = ~RFin;
        end
        STATE_WRITE: begin
           master.AWVALID = lockAW;
           master.ARVALID = 1'b0;
           master.WVALID  = lockW;
           master.RREADY  = 1'b0;
           master.BREADY  = lockB | WFin; 
           stall = ~BFin;
        end
        default : begin
           master.AWVALID = 1'b0;
           master.ARVALID = 1'b0;
           master.WVALID  = 1'b0;
           master.BREADY  = 1'b0;
           master.RREADY  = 1'b0; 
           stall = 1'b0;
        end
    endcase
end

always_comb begin
    case(w_type)
        `CACHE_BYTE:  master.WSTRB = `AXI_STRB_BYTE; 
        `CACHE_HWORD: master.WSTRB = `AXI_STRB_HWORD;
        default:      master.WSTRB = `AXI_STRB_WORD;
    endcase
end

always_ff@(posedge clk or negedge rst) begin
    if(~rst) begin
        lockAW <= 1'b0;
        lockAR <= 1'b0;
        lockR  <= 1'b0;
        lockW  <= 1'b0;
        lockB  <= 1'b0;
        lockVol <= 1'b0;
    end
    else begin
        lockVol <= (ARFin) ? 1'b0 : (volatile & ~ARFin) ? 1'b1 : lockVol;
        lockAW <= (AWFin)? 1'b0 : (master.AWVALID & ~master.AWREADY) ? 1'b1 : lockAW;
        lockAR <= (ARFin)? 1'b0 : (master.ARVALID & ~master.ARREADY) ? 1'b1 : lockAR;
        lockR  <= (RFin & master.RLAST)? 1'b0 : (ARFin) ? 1'b1 : lockR;
        lockW  <= (WFin)? 1'b0 : (AWFin) ? 1'b1 : lockW;
        lockB  <= (BFin)? 1'b0 : (WFin) ? 1'b1 : lockB;
    end
end

endmodule
