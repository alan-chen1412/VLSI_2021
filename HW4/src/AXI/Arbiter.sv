`include "AXI_define.svh"
`ifndef Arbiter_define
`define Arbiter_define
module Arbiter(
    input clk,
    input rst,
    
    input READY,

	input [`AXI_ID_BITS-1:0   ]ID_M0,
	input [`AXI_ADDR_BITS-1:0 ]ADDR_M0,
	input [`AXI_LEN_BITS-1:0  ]LEN_M0,
	input [`AXI_SIZE_BITS-1:0 ]SIZE_M0,
	input [`AXI_BURST_BITS-1:0]BURST_M0,
	input VALID_M0,
    output logic READY_M0,

	input [`AXI_ID_BITS-1:0   ]ID_M1,
	input [`AXI_ADDR_BITS-1:0 ]ADDR_M1,
	input [`AXI_LEN_BITS-1:0  ]LEN_M1,
	input [`AXI_SIZE_BITS-1:0 ]SIZE_M1,
	input [`AXI_BURST_BITS-1:0]BURST_M1,
	input VALID_M1,
    output logic READY_M1,

	input [`AXI_ID_BITS-1:0   ]ID_M2,
	input [`AXI_ADDR_BITS-1:0 ]ADDR_M2,
	input [`AXI_LEN_BITS-1:0  ]LEN_M2,
	input [`AXI_SIZE_BITS-1:0 ]SIZE_M2,
	input [`AXI_BURST_BITS-1:0]BURST_M2,
	input VALID_M2,
    output logic READY_M2,

    output logic [`AXI_ID_BITS-1:0   ]ID,
    output logic [`AXI_ADDR_BITS-1:0 ]ADDR,
    output logic [`AXI_LEN_BITS-1:0  ]LEN,
    output logic [`AXI_SIZE_BITS-1:0 ]SIZE,
    output logic [`AXI_BURST_BITS-1:0]BURST,
    output logic VALID,
    output logic [`AXI_MASTER_BITS-1:0] Master

);

logic [`AXI_MASTER_BITS-1:0] nxtMaster;
logic prevVALID_M0;
logic prevVALID_M1;
logic prevVALID_M2;


always_ff@(posedge clk or negedge rst) begin
    if(~rst)
        Master <= `AXI_DEFAULT_MASTER;
    else 
        Master <= (READY) ? nxtMaster : Master;
end

always_comb begin
    if(VALID_M2)
        nxtMaster = `AXI_MASTER2;
    else if (VALID_M1)
        nxtMaster = `AXI_MASTER1;
    else if (VALID_M0)
        nxtMaster = `AXI_MASTER0;
    else 
        nxtMaster = `AXI_DEFAULT_MASTER;
end

always_comb begin
    case(Master)
        `AXI_MASTER0:begin
            ID    = ID_M0;
            ADDR  = ADDR_M0;
            LEN   = LEN_M0;
            SIZE  = SIZE_M0;
            BURST = BURST_M0;
            VALID = VALID_M0;
            READY_M0 = READY & VALID_M0;
            READY_M1 = 1'b0;
            READY_M2 = 1'b0;
        end
        `AXI_MASTER1:begin
            ID    = ID_M1;
            ADDR  = ADDR_M1;
            LEN   = LEN_M1;
            SIZE  = SIZE_M1;
            BURST = BURST_M1;
            VALID = VALID_M1;
            READY_M0 = 1'b0;
            READY_M1 = READY & VALID_M1;
            READY_M2 = 1'b0;
        end
        `AXI_MASTER2:begin
            ID    = ID_M2;
            ADDR  = ADDR_M2;
            LEN   = LEN_M2;
            SIZE  = SIZE_M2;
            BURST = BURST_M2;
            VALID = VALID_M2;
            READY_M0 = 1'b0;
            READY_M2 = READY & VALID_M2;
            READY_M1 = 1'b0;
        end
        default:begin
            ID    = `AXI_ID_BITS'b0;
            ADDR  = `AXI_ADDR_BITS'b0;
            LEN   = `AXI_LEN_BITS'b0;
            SIZE  = `AXI_SIZE_BITS'b0;
            BURST = 2'b0;
            VALID = 1'b0;
            READY_M0 = 1'b0;
            READY_M1 = 1'b0;
            READY_M2 = 1'b0;
        end
    endcase
end

endmodule
`endif
