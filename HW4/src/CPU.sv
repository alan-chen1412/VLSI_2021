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
`include "CSR.sv"
module CPU(
    input clk,
    input rst,
    input [`SRAM_DATA_BITS-1:0] data_in,
    input [`SRAM_DATA_BITS-1:0] instr_in,
    input DM_stall,
    input IM_stall,
    input interrupt, 
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

IFID_REG IFIF();
IFID_REG IFID();
IDEXE_REG IDID();
IDEXE_REG IDEXE();
EXEMEM_REG EXEEXE();
EXEMEM_REG EXEMEM();
MEMWB_REG MEMMEM();
MEMWB_REG MEMWB();
logic [`PC_BITS-1:0        ] IF_PC_in;
logic [`SRAM_DATA_BITS-1:0 ] IF_instr;
logic [`PC_BITS-1:0]         addr;
logic                        IF_PCFlush;
logic                        pc_write;
logic                        IFRegWrite;
logic                        ID_flush;
logic [`IMM_TYPE_BITS-1:0  ] ID_IMMType;
logic [`SRAM_DATA_BITS-1:0 ] ID_instr;
logic                        IDRegWrite;
logic                        flush;
logic [`OPCODE_BITS-1:0    ] ID_opcode;
logic [`CPU_DATA_BITS-1:0  ] EXE_alu1_data;
logic [`CPU_DATA_BITS-1:0  ] EXE_alu2_data;
logic                        EXERegWrite;
logic [`ALUCTRL_BITS-1:0   ] EXE_ALUCtrl;
logic                        EXE_iszero;
logic [`FORWARD_BITS-1:0   ] EXE_forward_rs1;  
logic [`FORWARD_BITS-1:0   ] EXE_forward_rs2;
logic [`JUMP_BITS-1:0      ] EXE_branch;
logic [`PC_BITS-1:0        ] EXE_PCIMM; 
logic [`PC_BITS-1:0        ] EXE_PC4;
logic [`CPU_DATA_BITS-1:0  ] MEM_data_;
logic                        MEMRegWrite;
logic                        MEM_forward_mem;
logic                        mem_flush;
logic [`CPU_DATA_BITS-1:0  ] WB_write_data;
logic [31:0                ] ALU_out;
logic [31:0                ] CSR_wdata;
logic [31:0                ] CSR_rdata;
logic [31:0                ] CSR_retPC;
logic [31:0                ] CSR_PC;
logic                        CSR_control;
logic                        CSR_stall;
assign IFIF.instr      = IF_PCFlush ? `SRAM_DATA_BITS'b0 : instr_in;
assign IDID.funct3     = IFID.instr[14:12];
assign IDID.funct7     = IFID.instr[31:25];
assign IDID.shamt      = IFID.instr[20+:5];
assign IDID.rs1_addr   = IFID.instr[19:15];
assign IDID.rs2_addr   = IFID.instr[24:20];
assign IDID.rd         = IFID.instr[11:7];
assign IDID.PC         = IFID.pc;
assign EXE_PCIMM       = IDEXE.PC + IDEXE.imm;
assign EXE_PC4         = IDEXE.PC + `PC_BITS'b100;
assign EXEEXE.PCtoReg  = (IDEXE.PCtoRegSrc) ? EXE_PCIMM : EXE_PC4;
assign EXEEXE.lw_type  = IDEXE.lw_type;
assign EXEEXE.sw_type  = IDEXE.sw_type;
assign EXEEXE.rd_addr  = IDEXE.rd;
assign EXEEXE.RDsrc    = IDEXE.RDSrc;
assign EXEEXE.Memread  = IDEXE.MemRead;
assign EXEEXE.Memwrite = IDEXE.MemWrite;
assign EXEEXE.MemtoReg = IDEXE.MemtoReg;
assign EXEEXE.RegWrite = IDEXE.RegWrite;
assign MEMMEM.Memtoreg = EXEMEM.MemtoReg;
assign MEMMEM.rd_addr  = EXEMEM.rd_addr;
assign MEMMEM.RegWrite = EXEMEM.RegWrite;
assign MEMMEM.rd_data  = EXEMEM.RDsrc ? EXEMEM.PCtoReg : EXEMEM.ALUout;
assign ID_opcode       = IFID.instr[6:0];
assign data_addr       = EXEMEM.ALUout;
assign DM_req          = EXEMEM.Memwrite | EXEMEM.Memread;
assign write           = EXEMEM.Memwrite;
assign WB_write_data   = MEMWB.Memtoreg ? MEMWB.mem_data : MEMWB.rd_data;
assign instr_addr      = IFIF.pc;
assign DM_read         = EXEMEM.Memread;
assign EXE_alu2_data   = (IDEXE.ALUSrc) ? EXEEXE.forward_rs2_data: IDEXE.imm;
assign MEM_data_        = MEM_forward_mem ? EXEMEM.forward_rs2_data: WB_write_data;
assign write_type      = EXEMEM.sw_type;
assign read_type       = EXEMEM.lw_type;
assign EXEEXE.ALUout   = (IDEXE.CSR) ?CSR_rdata : ALU_out;
//CSR
assign IDID.CSR_addr = IFID.instr[31:20];
assign CSR_wdata = IDEXE.ALUSrc ? EXE_alu1_data : IDEXE.imm;
assign EXEEXE.pc = IDEXE.PC;

always_comb begin
    if(EXEMEM.Memwrite)begin
        data_write = `SRAM_WRITE_BITS'hf;
        case(EXEMEM.sw_type)
            `SW_WORD:data_write = `SRAM_WRITE_BITS'h0;
            `SW_BYTE:data_write[EXEMEM.ALUout[1:0]] = 1'b0;
            default:data_write = `SRAM_WRITE_BITS'h0;
        endcase
    end
    else begin
        data_write = `SRAM_WRITE_BITS'hf;
    end
end

always_comb begin
    MEMMEM.mem_data = `DATA_BITS'b0;
    case(EXEMEM.lw_type)
        `LW_WORD:MEMMEM.mem_data   = data_in;
        `LW_S_BYTE:begin
            MEMMEM.mem_data[7:0]   = data_in[{EXEMEM.ALUout[1:0],3'b0}+:8];
            MEMMEM.mem_data[31:8]  = {24{MEMMEM.mem_data[7]}};
        end
        `LW_U_BYTE:begin
            MEMMEM.mem_data[7:0]   = data_in[{EXEMEM.ALUout[1:0],3'b0}+:8];
        end
        `LW_HWORD_S:begin
            MEMMEM.mem_data[15:0]  = data_in[{EXEMEM.ALUout[1],4'b0}+:16];
            MEMMEM.mem_data[31:16] = {16{MEMMEM.mem_data[15]}};
        end
        `LW_HWORD_U:MEMMEM.mem_data[15:0]  = data_in[{EXEMEM.ALUout[1],4'b0}+:16];
        default:MEMMEM.mem_data    = data_in;
    endcase
end

always_comb begin
    if(IDEXE.CSR_ret) begin
        IF_PC_in = CSR_retPC; 
    end
    else if(CSR_control)begin
        IF_PC_in = CSR_PC;
    end
    else begin
        case(EXE_branch)
            `BRANCH_NEXT:IF_PC_in = IFIF.pc + `PC_BITS'b100;
            `BRANCH_REG :IF_PC_in = EXEEXE.ALUout;
            `BRANCH_IMM :IF_PC_in = EXE_PCIMM;
            default     :IF_PC_in = IFIF.pc + `PC_BITS'b100;
        endcase
    end
end

always_comb begin
    case({EXE_forward_rs1})
        `FORWARD_MEM: EXE_alu1_data = MEMMEM.rd_data;
        `FORWARD_WB : EXE_alu1_data = WB_write_data;
        default     : EXE_alu1_data = IDEXE.rs1_data; 
    endcase
end

always_comb begin
    case({EXE_forward_rs2})
        `FORWARD_MEM: EXEEXE.forward_rs2_data = MEMMEM.rd_data;
        `FORWARD_WB : EXEEXE.forward_rs2_data = WB_write_data;
        default     : EXEEXE.forward_rs2_data = IDEXE.rs2_data; 
    endcase
end
always_comb begin
    data_out = `SRAM_DATA_BITS'b0;
    case(EXEMEM.sw_type)
        `SW_WORD : data_out                               = MEM_data_;
        `SW_BYTE : data_out[{EXEMEM.ALUout[1:0],3'b0}+:8] = MEM_data_[7:0];
        `SW_HWORD: data_out[{EXEMEM.ALUout[1],4'b0}+:16]  = MEM_data_[15:0];
        default  : data_out                               = MEM_data_;
    endcase
end
PC pc(
    .clk(clk),
    .rst(rst),
    .PC_in(IF_PC_in),
    .PC_write(pc_write),
    .PC_out(IFIF.pc),
    .IM_req(IM_req),
    .IM_read(IM_read),
    .DM_stall(DM_stall),
    .IM_stall(IM_stall)
);

IFREG IF_REG(
    .clk(clk),
    .rst(rst),
    .IF(IFIF),
    .ID(IFID),
    .IF_reg_Write(IFRegWrite)
);

IDREG ID_REG(
    .clk(clk),
    .rst(rst),
    .IDRegWrite(IDRegWrite),
    .ID_flush(ID_flush),
    .ID(IDID),
    .EXE(IDEXE)

);


EXEREG EXE_REG(
    .clk(clk),
    .rst(rst),
    .EXERegWrite(EXERegWrite),
    .MEM_flush(mem_flush),
    .EXE(EXEEXE),
    .MEM(EXEMEM)
);
MEMREG MEM_REG(
    .clk(clk),
    .rst(rst),
    .MEMRegWrite(MEMRegWrite),
    .WB(MEMWB),
    .MEM(MEMMEM)
);
registerfile regfile(
    .clk(clk),
    .rst(rst),
    .ID_rs1_addr(IDID.rs1_addr),
    .ID_rs2_addr(IDID.rs2_addr),
    .WB_rd_addr(MEMWB.rd_addr),
    .WB_RegWrite(MEMWB.RegWrite),
    .WB_rd_data(WB_write_data),
    .ID_rs1_data(IDID.rs1_data),
    .ID_rs2_data(IDID.rs2_data) 
);
ControlUnit controller(
    .opcode(ID_opcode),
    .funct7(IDID.funct7),
    .mem_read(IDID.MemRead),
    .mem_write(IDID.MemWrite),
    .reg_write(IDID.RegWrite),
    .Imm_type(ID_IMMType),
    .ALU_op(IDID.ALUop),
    .PCtoRegSrc(IDID.PCtoRegSrc),
    .ALUSrc(IDID.ALUSrc),
    .Jump_type(IDID.JumpType),
    .RDsrc(IDID.RDSrc),
    .MemtoReg(IDID.MemtoReg),
    .i_type(IDID.i_type),
    .lw_type(IDID.lw_type),
    .sw_type(IDID.sw_type),
    .funct3(IDID.funct3),
    .CSR(IDID.CSR),
    .CSR_write(IDID.CSR_write),
    .CSR_set(IDID.CSR_set),
    .CSR_clear(IDID.CSR_clear),
    .CSR_ret(IDID.CSR_ret),
    .CSR_wait(IDID.CSR_wait)
);
Hazard hazard(
    .IM_stall(IM_stall),
    .DM_stall(DM_stall),
    .EXE_Memread(IDEXE.MemRead),
    .EXE_branch_type(EXE_branch),
    .ID_rs1_addr(IDID.rs1_addr),
    .ID_rs2_addr(IDID.rs2_addr),
    .EXE_rd_addr(IDEXE.rd), 
    .pc_flush(IF_PCFlush),
    .IFRegWrite(IFRegWrite),
    .IDRegWrite(IDRegWrite),
    .EXERegWrite(EXERegWrite),
    .MEMRegWrite(MEMRegWrite),
    .control_flush(ID_flush),
    .pc_write(pc_write),
    .mem_flush(mem_flush),
    .CSR_stall(CSR_stall),
    .CSR_control(CSR_control),
    .CSR_ret(IDEXE.CSR_ret)
);
IMM_generator immgen(
    .IMM_TYPE(ID_IMMType),
    .IMM_part1(IFID.instr[11:7]),
    .IMM_part2(IFID.instr[31:12]),
    .ID_IMM(IDID.imm)
);

ALUCtrl ALUCtrl (
    .EXE_ALUop(IDEXE.ALUop),
    .EXE_funct3(IDEXE.funct3),
    .EXE_funct7(IDEXE.funct7),
    .EXE_i_type(IDEXE.i_type),
    .EXE_ALUCtrl(EXE_ALUCtrl)
);    
ALU ALU(
    .EXE_rs1_data(EXE_alu1_data),
    .EXE_rs2_data(EXE_alu2_data),
    .EXE_ALUCtrl(EXE_ALUCtrl),
    .EXE_shamt(IDEXE.shamt),
    .EXE_i_type(IDEXE.i_type),
    .EXE_ALUout(ALU_out),
    .EXE_iszero(EXE_iszero)
);

Forward forward(
    .EXE_rs1_addr(IDEXE.rs1_addr),
    .EXE_rs2_addr(IDEXE.rs2_addr),
    .MEM_rd_addr(EXEMEM.rd_addr),
    .WB_rd_addr(MEMWB.rd_addr), 
    .MEM_RegWrite(EXEMEM.RegWrite),
    .WB_RegWrite(MEMWB.RegWrite), 
    .EXE_forward_rs1(EXE_forward_rs1),
    .EXE_forward_rs2(EXE_forward_rs2),
    .MEM_forward_mem(MEM_forward_mem)
);
Branch branch(
    .EXE_funct3(IDEXE.funct3),
    .EXE_jump_type(IDEXE.JumpType),
    .EXE_ALUout(EXEEXE.ALUout[0]),
    .EXE_iszero(EXE_iszero),
    .EXE_branch(EXE_branch)
);

CSR CSR( 
    .clk(clk),
    .rst(rst),
    .CSR_wdata(CSR_wdata),
    .CSR_addr(IDEXE.CSR_addr),
    .CSR_write(IDEXE.CSR_write),
    .CSR_clear(IDEXE.CSR_clear),
    .CSR_set(IDEXE.CSR_set),
    .interrupt(interrupt),
    .CSR_wait(IDEXE.CSR_wait),
    .CSR_ret(IDEXE.CSR_ret),
    .EXE_PC(IDEXE.PC),
    .CSR_rdata(CSR_rdata),
    .CSR_retPC(CSR_retPC),
    .CSR_PC(CSR_PC),
    .CSR_stall(CSR_stall),
    .IDRegWrite(IDRegWrite),
    .CSR_control(CSR_control)
);

endmodule
