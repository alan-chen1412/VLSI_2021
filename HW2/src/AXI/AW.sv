`include "AXI_define.svh"
//`include "Arbiter.sv"
//`include "Decoder.sv"
module AW(
    input clk,
    input rst,
    // Master0 interface
	input [`AXI_ID_BITS-1:0] ID_M1,
	input [`AXI_ADDR_BITS-1:0] ADDR_M1,
	input [`AXI_LEN_BITS-1:0] LEN_M1,
	input [`AXI_SIZE_BITS-1:0] SIZE_M1,
	input [1:0] BURST_M1,
	input VALID_M1,
    // Slave0 resp
	input READY_S0,
	input READY_S1,
    input READY_S2,
    // Slave0
	output logic [`AXI_IDS_BITS-1:0] ID_S0,
	output logic [`AXI_ADDR_BITS-1:0] ADDR_S0,
	output logic [`AXI_LEN_BITS-1:0] LEN_S0,
	output logic [`AXI_SIZE_BITS-1:0] SIZE_S0,
	output logic [1:0] BURST_S0,
	output logic VALID_S0,
    // Slave1
	output logic [`AXI_IDS_BITS-1:0] ID_S1,
	output logic [`AXI_ADDR_BITS-1:0] ADDR_S1,
	output logic [`AXI_LEN_BITS-1:0] LEN_S1,
	output logic [`AXI_SIZE_BITS-1:0] SIZE_S1,
	output logic [1:0] BURST_S1,
	output logic VALID_S1,
    //Default Slave
	output logic [`AXI_IDS_BITS-1:0] ID_S2,
	output logic [`AXI_ADDR_BITS-1:0] ADDR_S2,
	output logic [`AXI_LEN_BITS-1:0] LEN_S2,
	output logic [`AXI_SIZE_BITS-1:0] SIZE_S2,
	output logic [1:0] BURST_S2,
	output logic VALID_S2,
    output logic READY_M1,
	output logic [`AXI_MASTER_BITS-1:0] MASTER
);

logic [`AXI_IDS_BITS-1:0] ID;
logic [`AXI_ADDR_BITS-1:0] ADDR;
logic [`AXI_LEN_BITS-1:0] LEN;
logic [`AXI_SIZE_BITS-1:0] SIZE;
logic [1:0] BURST;
logic VALID;
logic READY;
//logic [`AXI_MASTER_BITS-1:0] MASTER;
// fake Master
logic [`AXI_ID_BITS-1:0] ID_M0;
logic [`AXI_ADDR_BITS-1:0] ADDR_M0;
logic [`AXI_LEN_BITS-1:0] LEN_M0;
logic [`AXI_SIZE_BITS-1:0] SIZE_M0;
logic [1:0] BURST_M0;
logic VALID_M0;
logic READY_M0;
assign ID_M0 = `AXI_ID_BITS'b0;
assign ADDR_M0= `AXI_ADDR_BITS'b0;
assign LEN_M0 = `AXI_LEN_BITS'b0;
assign SIZE_M0 = `AXI_SIZE_BITS'b0;
assign BURST_M0 = 2'b0;
assign VALID_M0 = 1'b0;
// slave0
assign ID_S0 = ID;
assign ADDR_S0 = ADDR;
assign LEN_S0 = LEN;
assign SIZE_S0 = SIZE;
assign BURST_S0 = BURST;

// slave1
assign ID_S1 = ID;
assign ADDR_S1 = ADDR;
assign LEN_S1 = LEN;
assign SIZE_S1 = SIZE;
assign BURST_S1 = BURST;
//default slave
assign ID_S2 = ID;
assign ADDR_S2 = ADDR;
assign LEN_S2 = LEN;
assign SIZE_S2 = SIZE;
assign BURST_S2 = BURST;



Arbiter AR_Arbiter(
    .clk(clk),
    .rst(rst),
    // Master0 interface
	.ID_M0(ID_M0),
	.ADDR_M0(ADDR_M0),
	.LEN_M0(LEN_M0),
	.SIZE_M0(SIZE_M0),
	.BURST_M0(BURST_M0),
	.VALID_M0(VALID_M0),
    // Master1 interface
	.ID_M1(ID_M1),
	.ADDR_M1(ADDR_M1),
	.LEN_M1(LEN_M1),
	.SIZE_M1(SIZE_M1),
	.BURST_M1(BURST_M1),
	.VALID_M1(VALID_M1),
    //Slave
    .READY(READY),
    // output Master
	.ID_M(ID),
	.ADDR_M(ADDR),
	.LEN_M(LEN),
	.SIZE_M(SIZE),
	.BURST_M(BURST),
	.VALID_M(VALID),
    .READY_M0(READY_M0),
    .READY_M1(READY_M1),
	.Master(MASTER)
);

Decoder decoder(
    .VALID(VALID), 
    .ADDR(ADDR),
    .READY_S0(READY_S0),
    .READY_S1(READY_S1),
    .READY_S2(READY_S2),
	.VALID_S0(VALID_S0),
	.VALID_S1(VALID_S1),
    .VALID_S2(VALID_S2),
    .READY(READY)
);


endmodule
