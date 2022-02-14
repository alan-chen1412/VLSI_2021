`include "DMA_slave.sv"
`include "DMA_master.sv"
module DMA(
    input clk,
    input rst,
    AXI_master_p.master master,
    AXI_slave_p.slave slave
);
logic clear_reg;
logic start;
logic [`AXI_ADDR_BITS-1:0] source_addr;
logic [`AXI_ADDR_BITS-1:0] dest_addr;
logic [`AXI_DATA_BITS-1:0] length;

DMA_slave DMAslave(
    .clk(clk),
    .rst(rst),
    .slave(slave),
    .clear_reg(clear_reg),
    .start(start),
    .source_addr(source_addr),
    .dest_addr(dest_addr),
    .length(length)
);
DMA_master DMAmaster(
    .clk(clk),
    .rst(rst),
    .master(master),
    .clear_reg(clear_reg),
    .start(start),
    .source_addr(source_addr),
    .dest_addr(dest_addr),
    .length(length)
);
endmodule
