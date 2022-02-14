`include "CPU_DEF.svh"
`include "def.svh"
`include "PC.sv"
`include "IFREG.sv"
`include "IDREG.sv"
`include "EXEREG.sv"
`include "MEMREG.sv"
`include "registerfile.sv"
`include "ControlUnit.sv"
`include "Hazard.sv"
`include "IMM_generator.sv"
`include "ALUCtrl.sv"
`include "ALU.sv"
`include "Branch.sv"
`include "Forward.sv"
module CPU(
    input clk,
    input rst,
    input [`SRAM_DATA_BITS-1:0] data_in,
    input [`SRAM_DATA_BITS-1:0] instr_in,
    input DM_stall,
    input IM_stall, 
    output logic write,
    output logic [31:0] instr_addr,
    output logic [31:0] data_addr,
    output logic [`CACHE_TYPE_BITS-1:0] write_type,
    output logic [`CACHE_TYPE_BITS-1:0] read_type,
    output logic [`SRAM_DATA_BITS-1:0] data_out,
    output logic IM_req,
    output logic DM_req,
    output logic [`SRAM_WRITE_BITS-1:0] data_write,
    output logic IM_read,
    output logic DM_read
);


//IF stage 
logic [`PC_BITS-1:0] IF_PC_in;
logic [`PC_BITS-1:0] IF_PC_out;
logic [`SRAM_DATA_BITS-1:0] IF_instr;
logic [`PC_BITS-1:0] addr;
logic IF_PCFlush;
logic pc_write;
logic IFRegWrite;
assign IF_instr = IF_PCFlush ? `SRAM_DATA_BITS'b0 : instr_in;

//ID stage
logic ID_flush;
logic [`PC_BITS-1:0] ID_PC;
logic [`IMM_TYPE_BITS-1:0] ID_IMMType;
logic [`SRAM_DATA_BITS-1:0] ID_instr;
logic IDRegWrite;
logic flush;
logic [2:0] ID_funct3;
logic [6:0] ID_funct7;
logic ID_PCtoRegSrc;
logic ID_ALUSrc;
logic ID_RDSrc;
logic ID_MemRead;
logic ID_MemWrite;
logic ID_MemtoReg;
logic [`CPU_DATA_BITS-1:0] ID_rs1_data;
logic [`CPU_DATA_BITS-1:0] ID_rs2_data;
logic [4:0] ID_rd_addr;
logic [4:0] ID_rs1_addr;
logic [4:0] ID_rs2_addr;
logic [`CPU_DATA_BITS-1:0] ID_imm;
logic ID_RegWrite;
logic [4:0] ID_shamt;
logic [`ALUOP_BITS-1:0] ID_ALUop;
logic ID_i_type;
logic [`JUMP_BITS-1:0 ] ID_JumpType; 
logic [`LW_TYPE_BITS-1:0]ID_lw_type;
logic [`LW_TYPE_BITS-1:0]ID_sw_type;
logic [`OPCODE_BITS-1:0 ]ID_opcode;
assign ID_opcode = ID_instr[6:0];
assign ID_funct3 = ID_instr[14:12];
assign ID_funct7 = ID_instr[31:25];
assign ID_shamt  = ID_instr[20+:5];
assign ID_rs1_addr = ID_instr[19:15];
assign ID_rs2_addr = ID_instr[24:20];
assign ID_rd_addr = ID_instr[11:7];
//EXE stage
logic [2:0               ] EXE_funct3;
logic [6:0               ] EXE_funct7;
logic                      EXE_PCtoRegSrc;
logic                      EXE_ALUSrc;
logic                      EXE_RDSrc;
logic                      EXE_MemRead;
logic                      EXE_MemWrite;
logic                      EXE_MemtoReg;
logic [`CPU_DATA_BITS-1:0] EXE_ALUout;
logic [`CPU_DATA_BITS-1:0] EXE_rs1_data;
logic [`CPU_DATA_BITS-1:0] EXE_rs2_data;
logic [`CPU_DATA_BITS-1:0] EXE_alu1_data;
logic [`CPU_DATA_BITS-1:0] EXE_alu2_data;
logic [`CPU_DATA_BITS-1:0] EXE_tmp2_data;
logic [4:0               ] EXE_rd_addr;
logic [4:0               ] EXE_rs1_addr;
logic [4:0               ] EXE_rs2_addr;
logic [`CPU_DATA_BITS-1:0] EXE_imm;
logic                      EXE_RegWrite;
logic [4:0               ] EXE_shamt;
logic [`ALUOP_BITS-1:0   ] EXE_ALUop;
logic                      EXE_i_type;
logic                      EXERegWrite;
logic [`JUMP_BITS-1:0 ]    EXE_JumpType; 
logic [`ALUCTRL_BITS-1:0]  EXE_ALUCtrl;
logic [`PC_BITS-1:0     ]  EXE_PCtoReg;
logic EXE_iszero;
logic [`FORWARD_BITS-1:0]EXE_forward_rs1;  
logic [`FORWARD_BITS-1:0]EXE_forward_rs2;
logic [`JUMP_BITS-1:0] EXE_branch;
logic [`PC_BITS-1:0  ] EXE_PCIMM; 
logic [`PC_BITS-1:0  ] EXE_PC4;
logic [`LW_TYPE_BITS-1:0 ] EXE_lw_type;
logic [`LW_TYPE_BITS-1:0 ] EXE_sw_type;
logic [`PC_BITS-1:0] EXE_PC;
assign EXE_PCIMM = EXE_PC + EXE_imm;
assign EXE_PC4   = EXE_PC + `PC_BITS'b100;
assign EXE_PCtoReg = (EXE_PCtoRegSrc) ? EXE_PCIMM : EXE_PC4;
//MEM stage 
logic [`PC_BITS-1:0        ] MEM_PCtoReg;
logic [`CPU_DATA_BITS-1:0  ] MEM_ALUout;
logic [`CPU_DATA_BITS-1:0  ] MEM_mem_data;
logic [`CPU_DATA_BITS-1:0  ] MEM_forward_rs2_data;
logic [`CPU_DATA_BITS-1:0  ] MEM_data;
logic [4:0                 ] MEM_rd_addr;
logic                        MEM_RDsrc;
logic                        MEM_Memread;
logic                        MEM_Memwrite;
logic                        MEM_MemtoReg;
logic                        MEM_RegWrite;
logic                        MEMRegWrite;
logic                        MEM_forward_mem;
logic [`CPU_DATA_BITS-1:0  ] MEM_rd_data;
logic [`LW_TYPE_BITS-1:0   ] MEM_lw_type;
logic [`LW_TYPE_BITS-1:0   ] MEM_sw_type;
logic mem_flush;
assign MEM_rd_data = MEM_RDsrc ? MEM_PCtoReg : MEM_ALUout;
assign data_addr   = MEM_ALUout;
assign DM_req = MEM_Memwrite | MEM_Memread;
assign write = MEM_Memwrite;
always_comb begin
    if(MEM_Memwrite)begin
        data_write = `SRAM_WRITE_BITS'hf;
        case(MEM_sw_type)
            `SW_WORD:data_write = `SRAM_WRITE_BITS'h0;
            `SW_BYTE:data_write[MEM_ALUout[1:0]] = 1'b0;
            default:data_write = `SRAM_WRITE_BITS'h0;
        endcase
    end
    else begin
        data_write = `SRAM_WRITE_BITS'hf;
    end
end

always_comb begin
    MEM_mem_data = `DATA_BITS'b0;
    case(MEM_lw_type)
        `LW_WORD:MEM_mem_data = data_in;
        `LW_S_BYTE:begin
            MEM_mem_data[7:0] = data_in[{MEM_ALUout[1:0],3'b0}+:8];
            MEM_mem_data[31:8] = {24{MEM_mem_data[7]}};
        end
        `LW_U_BYTE:begin
            MEM_mem_data[7:0] = data_in[{MEM_ALUout[1:0],3'b0}+:8];
        end
        `LW_HWORD_S:begin
            MEM_mem_data[15:0] = data_in[{MEM_ALUout[1],4'b0}+:16];
            MEM_mem_data[31:16] = {16{MEM_mem_data[15]}};
        end
        `LW_HWORD_U:begin
            MEM_mem_data[15:0] = data_in[{MEM_ALUout[1],4'b0}+:16];
        end
        default:MEM_mem_data = data_in;
    endcase
end

//WB stage 
logic                       WB_Memtoreg;
logic [`CPU_DATA_BITS-1:0 ] WB_rd_data;
logic [`CPU_DATA_BITS-1:0 ] WB_write_data;
logic [4:0                ] WB_rd_addr;
logic [`SRAM_DATA_BITS-1:0] WB_mem_data;
logic                       WB_RegWrite;

assign WB_write_data = WB_Memtoreg ? WB_mem_data : WB_rd_data;
assign instr_addr = IF_PC_out;
assign DM_read = MEM_Memread;
always_comb begin
    case(EXE_branch)
        `BRANCH_NEXT:begin
            IF_PC_in = IF_PC_out + `PC_BITS'b100;
        end
        `BRANCH_REG:begin
            IF_PC_in = EXE_ALUout;
        end
        `BRANCH_IMM:begin
            IF_PC_in = EXE_PCIMM;
        end
        default:begin
            IF_PC_in = IF_PC_out + `PC_BITS'b100;
        end
    endcase
end

always_comb begin
    case({EXE_forward_rs1})
        `FORWARD_MEM: EXE_alu1_data = MEM_rd_data;
        `FORWARD_WB:  EXE_alu1_data = WB_write_data;
        default:      EXE_alu1_data = EXE_rs1_data; 
    endcase
end

always_comb begin
    case({EXE_forward_rs2})
        `FORWARD_MEM: EXE_tmp2_data = MEM_rd_data;
        `FORWARD_WB:  EXE_tmp2_data = WB_write_data;
        default:      EXE_tmp2_data = EXE_rs2_data; 
    endcase
end
assign EXE_alu2_data = (EXE_ALUSrc) ? EXE_tmp2_data: EXE_imm;
assign MEM_data    = MEM_forward_mem ? MEM_forward_rs2_data: WB_write_data;
assign write_type = MEM_sw_type;
assign read_type = MEM_lw_type;
always_comb begin
    data_out = `SRAM_DATA_BITS'b0;
    case(MEM_sw_type)
        `SW_WORD:  data_out = MEM_data;
        `SW_BYTE:  begin
            data_out[{MEM_ALUout[1:0],3'b0}+:8] = MEM_data[7:0];
        end
        `SW_HWORD:begin
            data_out[{MEM_ALUout[1],4'b0}+:16] = MEM_data[15:0];
        end
        default:data_out = MEM_data;
    endcase
end
PC pc(
    .clk(clk),
    .rst(rst),
    .PC_in(IF_PC_in),
    .PC_write(pc_write),
    .PC_out(IF_PC_out),
    .IM_req(IM_req),
    .IM_read(IM_read),
    .DM_stall(DM_stall),
    .IM_stall(IM_stall)
);

IFREG IF_REG(
    .clk(clk),
    .rst(rst),
    .IF_pc(IF_PC_out),
    .IF_instr(IF_instr),
    .IF_reg_Write(IFRegWrite),
    .ID_pc(ID_PC),
    .ID_instr(ID_instr)
);

IDREG ID_REG(
    .clk(clk),
    .rst(rst),
    .IDRegWrite(IDRegWrite),
    .ID_flush(ID_flush),
    .ID_funct3(ID_funct3),
    .ID_funct7(ID_funct7),
    .ID_PCtoRegSrc(ID_PCtoRegSrc),
    .ID_ALUSrc(ID_ALUSrc),
    .ID_RDSrc(ID_RDSrc),
    .ID_MemRead(ID_MemRead),
    .ID_MemWrite(ID_MemWrite),
    .ID_MemtoReg(ID_MemtoReg),
    .ID_rs1_data(ID_rs1_data),
    .ID_rs2_data(ID_rs2_data),
    .ID_rd(ID_rd_addr),
    .ID_rs1_addr(ID_rs1_addr),
    .ID_rs2_addr(ID_rs2_addr),
    .ID_imm(ID_imm),
    .ID_RegWrite(ID_RegWrite),
    .ID_shamt(ID_shamt),
    .ID_ALUop(ID_ALUop),
    .ID_i_type(ID_i_type),
    .ID_JumpType(ID_JumpType),
    .ID_lw_type(ID_lw_type),
    .ID_sw_type(ID_sw_type),
    .ID_PC(ID_PC),
    .EXE_PC(EXE_PC),
    .EXE_funct3(EXE_funct3),
    .EXE_funct7(EXE_funct7),
    .EXE_PCtoRegSrc(EXE_PCtoRegSrc),
    .EXE_ALUSrc(EXE_ALUSrc),
    .EXE_RDSrc(EXE_RDSrc),
    .EXE_MemRead(EXE_MemRead),
    .EXE_MemWrite(EXE_MemWrite),
    .EXE_MemtoReg(EXE_MemtoReg),
    .EXE_rs1_data(EXE_rs1_data),
    .EXE_rs2_data(EXE_rs2_data),
    .EXE_rd(EXE_rd_addr),
    .EXE_rs1_addr(EXE_rs1_addr),
    .EXE_rs2_addr(EXE_rs2_addr),
    .EXE_imm(EXE_imm),
    .EXE_RegWrite(EXE_RegWrite),
    .EXE_shamt(EXE_shamt),
    .EXE_ALUop(EXE_ALUop),
    .EXE_i_type(EXE_i_type),
    .EXE_JumpType(EXE_JumpType),
    .EXE_lw_type(EXE_lw_type),
    .EXE_sw_type(EXE_sw_type)

);
EXEREG EXE_REG(
    .clk(clk),
    .rst(rst),
    .EXE_lw_type(EXE_lw_type),
    .EXE_sw_type(EXE_sw_type),
    .EXERegWrite(EXERegWrite),
    .EXE_PCtoReg(EXE_PCtoReg),
    .EXE_ALUout(EXE_ALUout),
    .EXE_forward_rs2_data(EXE_tmp2_data),
    .EXE_rd_addr(EXE_rd_addr),
    .EXE_RDsrc(EXE_RDSrc),
    .EXE_Memread(EXE_MemRead),
    .EXE_Memwrite(EXE_MemWrite),
    .EXE_MemtoReg(EXE_MemtoReg),
    .EXE_RegWrite(EXE_RegWrite),
    .MEM_PCtoReg(MEM_PCtoReg),
    .MEM_ALUout(MEM_ALUout),
    .MEM_forward_rs2_data(MEM_forward_rs2_data),
    .MEM_rd_addr(MEM_rd_addr),
    .MEM_RDsrc(MEM_RDsrc),
    .MEM_Memread(MEM_Memread),
    .MEM_Memwrite(MEM_Memwrite),
    .MEM_MemtoReg(MEM_MemtoReg),
    .MEM_RegWrite(MEM_RegWrite),
    .MEM_lw_type(MEM_lw_type),
    .MEM_sw_type(MEM_sw_type),
    .MEM_flush(mem_flush)
);
MEMREG MEM_REG(
    .clk(clk),
    .rst(rst),
    .MEMRegWrite(MEMRegWrite),
    .MEM_Memtoreg(MEM_MemtoReg),
    .MEM_rd_data(MEM_rd_data),
    .MEM_mem_data(MEM_mem_data),
    .MEM_rd_addr(MEM_rd_addr),
    .MEM_RegWrite(MEM_RegWrite),
    .WB_Memtoreg(WB_Memtoreg),
    .WB_rd_data(WB_rd_data),
    .WB_rd_addr(WB_rd_addr),
    .WB_mem_data(WB_mem_data),
    .WB_RegWrite(WB_RegWrite)
);
registerfile regfile(
    .clk(clk),
    .rst(rst),
    .ID_rs1_addr(ID_rs1_addr),
    .ID_rs2_addr(ID_rs2_addr),
    .WB_rd_addr(WB_rd_addr),
    .WB_RegWrite(WB_RegWrite),
    .WB_rd_data(WB_write_data),
    .ID_rs1_data(ID_rs1_data),
    .ID_rs2_data(ID_rs2_data) 
);
ControlUnit controller(
    .opcode(ID_opcode),
    .mem_read(ID_MemRead),
    .mem_write(ID_MemWrite),
    .reg_write(ID_RegWrite),
    .Imm_type(ID_IMMType),
    .ALU_op(ID_ALUop),
    .PCtoRegSrc(ID_PCtoRegSrc),
    .ALUSrc(ID_ALUSrc),
    .Jump_type(ID_JumpType),
    .RDsrc(ID_RDSrc),
    .MemtoReg(ID_MemtoReg),
    .i_type(ID_i_type),
    .lw_type(ID_lw_type),
    .sw_type(ID_sw_type),
    .funct3(ID_funct3)
);
Hazard hazard(
    .IM_stall(IM_stall),
    .DM_stall(DM_stall),
    .EXE_Memread(EXE_MemRead),
    .EXE_branch_type(EXE_branch),
    .ID_rs1_addr(ID_rs1_addr),
    .ID_rs2_addr(ID_rs2_addr),
    .EXE_rd_addr(EXE_rd_addr), 
    .pc_flush(IF_PCFlush),
    .IFRegWrite(IFRegWrite),
    .IDRegWrite(IDRegWrite),
    .EXERegWrite(EXERegWrite),
    .MEMRegWrite(MEMRegWrite),
    .control_flush(ID_flush),
    .pc_write(pc_write),
    .mem_flush(mem_flush)
);
IMM_generator immgen(
    .IMM_TYPE(ID_IMMType),
    .IMM_part1(ID_instr[11:7]),
    .IMM_part2(ID_instr[31:12]),
    .ID_IMM(ID_imm)
);

ALUCtrl ALUCtrl (
    .EXE_ALUop(EXE_ALUop),
    .EXE_funct3(EXE_funct3),
    .EXE_funct7(EXE_funct7),
    .EXE_i_type(EXE_i_type),
    .EXE_ALUCtrl(EXE_ALUCtrl)
);    
ALU ALU(
    .EXE_rs1_data(EXE_alu1_data),
    .EXE_rs2_data(EXE_alu2_data),
    .EXE_ALUCtrl(EXE_ALUCtrl),
    .EXE_shamt(EXE_shamt),
    .EXE_i_type(EXE_i_type),
    .EXE_ALUout(EXE_ALUout),
    .EXE_iszero(EXE_iszero)
);

Forward forward(
    .EXE_rs1_addr(EXE_rs1_addr),
    .EXE_rs2_addr(EXE_rs2_addr),
    .MEM_rd_addr(MEM_rd_addr),
    .WB_rd_addr(WB_rd_addr), 
    .MEM_RegWrite(MEM_RegWrite),
    .WB_RegWrite(WB_RegWrite), 
    .EXE_forward_rs1(EXE_forward_rs1),
    .EXE_forward_rs2(EXE_forward_rs2),
    .MEM_forward_mem(MEM_forward_mem)
);
Branch branch(
    .EXE_funct3(EXE_funct3),
    .EXE_jump_type(EXE_JumpType),
    .EXE_ALUout(EXE_ALUout[0]),
    .EXE_iszero(EXE_iszero),
    .EXE_branch(EXE_branch)
);
endmodule
