`ifndef FIFO
`define FIFO
`include "interface.sv"
module FIFO#(
parameter SIZE_P = 4

)(
    input clk,
    input rst,
    FIFO_IF.fifoif FIFOif
);

logic [31:0] mem[(2**SIZE_P)-1:0];
logic [SIZE_P-1:0] rptr;
logic [SIZE_P-1:0] wptr;
logic [SIZE_P-1:0] wptr_add;
logic [SIZE_P-1:0] one;
integer i;

assign one = 1;
assign wptr_add = wptr + one;
assign FIFOif.rdata = mem[rptr];
assign FIFOif._empty = rptr == wptr;
assign FIFOif._full = (wptr_add) == rptr;

always_ff@(posedge clk or negedge rst) begin
    if(~rst) begin
        for(i = 0;i<2**SIZE_P;i++)
            mem[i] <= 32'b0;
    end
    else begin
        if(FIFOif.write & ~FIFOif._full) begin
            mem[wptr] <= FIFOif.wdata;
        end
    end
end

always_ff@(posedge clk or negedge rst) begin
    if(~rst) begin
        rptr <= 0;
        wptr <= 0;
    end
    else begin
        rptr <= (FIFOif.read & ~FIFOif._empty) ? rptr + one : rptr;
        wptr <= (FIFOif.write & ~FIFOif._full) ? wptr_add: wptr;
    end
end

endmodule
`endif
