`include "Master.sv"
`include "CPU.sv"
`include "L1C_data.sv"
`include "L1C_inst.sv"
`include "AXI_define.svh"
`include "def.svh"
module CPU_wrapper(
    input clk,
    input rst,
    input interrupt,
    AXI_master_p.master master0,
    AXI_master_p.master master1
);

logic [`AXI_DATA_BITS-1:0] data_in;
logic [`SRAM_DATA_BITS-1:0] instr_in;
logic DM_stall;
logic IM_stall;
logic [`AXI_ADDR_BITS-1:0] instr_addr;
logic [`AXI_ADDR_BITS-1:0] data_addr;
logic [`SRAM_DATA_BITS-1:0] data_out;
logic IM_req;
logic DM_req;
logic [`SRAM_WRITE_BITS-1:0] data_write;
logic IM_read;
logic DM_read;
logic write;
logic [`CACHE_TYPE_BITS-1:0] core_type;
logic [`CACHE_TYPE_BITS-1:0] read_type;
logic [`DATA_BITS-1:0] D_out;
logic D_req;
logic [`DATA_BITS-1:0] D_addr;
logic D_write;
logic [`DATA_BITS-1:0] D_in;
logic [`CACHE_TYPE_BITS-1:0] D_type;
logic D_wait;
logic [`DATA_BITS-1:0] I_out;
logic I_req;
logic [`DATA_BITS-1:0] I_addr;
logic I_write;
logic [`DATA_BITS-1:0] I_in;
logic [`CACHE_TYPE_BITS-1:0] I_type;
logic I_wait;
logic volatile_D;


CPU CPU(
    .clk(clk),
    .rst(~rst),
    .data_in(data_in),
    .instr_in(instr_in),
    .DM_stall(DM_stall),
    .IM_stall(IM_stall),
    .instr_addr(instr_addr),
    .data_addr(data_addr),
    .data_out(data_out),
    .IM_req(IM_req),
    .DM_req(DM_req),
    .data_write(data_write),
    .write_type(core_type),
    .IM_read(IM_read),
    .DM_read(DM_read),
    .read_type(read_type),
    .write(write),
    .interrupt(interrupt)
);
Master M0(
    .clk(clk),
    .rst(rst),
    .master(master0),
    .req(I_req),
    .write(I_write),
    .w_type(I_type),
    .data_in(I_in),
    .addr(I_addr),
    .data_out(I_out),
    .stall(I_wait),
    .volatile(1'b0)
);

Master M1(
    .clk(clk),
    .rst(rst),
    .master(master1),
    .req(D_req),
    .write(D_write),
    .w_type(D_type),
    .data_in(D_in),
    .addr(D_addr),
    .data_out(D_out),
    .stall(D_wait),
    .volatile(valatile_D)
);

L1C_data D_cache(
    .clk(clk),
    .rst(~rst),
    .core_addr(data_addr),
    .core_req(DM_req),
    .core_write(write),
    .core_in(data_out),
    .core_type(core_type),
    .D_out(D_out),
    .D_wait(D_wait),
    .core_out(data_in),
    .core_wait(DM_stall),
    .D_req(D_req),
    .D_addr(D_addr),
    .D_write(D_write),
    .D_in(D_in),
    .D_type(D_type),
    .volatile_read(valatile_D)
);

L1C_inst I_cache(
    .clk(clk),
    .rst(~rst),
    .core_addr(instr_addr),
    .core_req(IM_req),
    .core_write(1'b0),
    .core_in(`DATA_BITS'b0),
    .core_type(`CACHE_WORD),
    .I_out(I_out),
    .I_wait(I_wait),
    .core_out(instr_in),
    .core_wait(IM_stall),
    .I_req(I_req),
    .I_addr(I_addr),
    .I_write(I_write),
    .I_in(I_in),
    .I_type(I_type)
);

endmodule

