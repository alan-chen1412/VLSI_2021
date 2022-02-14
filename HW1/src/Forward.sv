`include "CPU_DEF.svh"

module Forward(
    input [4:0] EXE_rs1_addr,
    input [4:0] EXE_rs2_addr,
    input [4:0] MEM_rd_addr,
    input [4:0] WB_rd_addr, 
    input MEM_RegWrite,
    input WB_RegWrite, 
    output logic [`FORWARD_BITS-1:0] EXE_forward_rs1,
    output logic [`FORWARD_BITS-1:0] EXE_forward_rs2,
    output logic                     MEM_forward_mem
);

logic MEM_zero;
logic WB_zero;
assign MEM_zero = (|MEM_rd_addr);
assign WB_zero = (|WB_rd_addr);


always_comb begin
    if(MEM_RegWrite & MEM_zero & (EXE_rs1_addr == MEM_rd_addr)) begin
        EXE_forward_rs1 = `FORWARD_MEM; 
    end
    else if (WB_RegWrite & WB_zero & (EXE_rs1_addr == WB_rd_addr)) begin
        EXE_forward_rs1 = `FORWARD_WB;
    end
    else begin
        EXE_forward_rs1 = `FORWARD_REG;
    end
end

always_comb begin
    if(MEM_RegWrite & MEM_zero & (EXE_rs2_addr == MEM_rd_addr)) begin
        EXE_forward_rs2 = `FORWARD_MEM; 
    end
    else if (WB_RegWrite & WB_zero & (EXE_rs2_addr == WB_rd_addr)) begin
        EXE_forward_rs2 = `FORWARD_WB;
    end
    else begin
        EXE_forward_rs2 = `FORWARD_REG;
    end
end

always_comb begin
    if (WB_RegWrite & WB_zero & (EXE_rs2_addr == WB_rd_addr)) begin
        MEM_forward_mem = 1'b0;
    end
    else begin
        MEM_forward_mem = 1'b1;
    end
end

endmodule
