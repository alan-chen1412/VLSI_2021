`include "CPU_DEF.svh"
module Hazard(
    input IM_stall,
    input DM_stall,
    input EXE_Memread,
    input [`JUMP_BITS-1:0] EXE_branch_type,
    input [4:0] ID_rs1_addr,
    input [4:0] ID_rs2_addr,
    input [4:0] EXE_rd_addr,
    output logic pc_write,
    output logic pc_flush,
    output logic IFRegWrite,
    output logic IDRegWrite,
    output logic EXERegWrite,
    output logic MEMRegWrite,
    output logic control_flush,
    output logic flush_mem
);

logic same_rs1;
logic same_rs2;
logic flush   ;
logic mem_hazard;

assign same_rs1 = ID_rs1_addr == EXE_rd_addr;
assign same_rs2 = ID_rs2_addr == EXE_rd_addr;
assign mem_hazard = (same_rs1 | same_rs2) & EXE_Memread;
assign flush    = ~(EXE_branch_type == `BRANCH_NEXT);
assign pc_flush = flush;
assign control_flush = flush | mem_hazard;
assign IFRegWrite = ~(mem_hazard | IM_stall | DM_stall);
assign IDRegWrite = ~ (IM_stall | DM_stall);
assign EXERegWrite =~(IM_stall | DM_stall);
assign MEMRegWrite =~(IM_stall | DM_stall);
assign pc_write    = ~(IM_stall | DM_stall | mem_hazard);
assign flush_mem = IM_stall & ~DM_stall;
endmodule
