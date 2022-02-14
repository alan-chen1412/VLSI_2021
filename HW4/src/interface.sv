`ifndef INTERFACE
`define INTERFACE
`include "CPU_DEF.svh"
interface FIFO_IF;
    logic read;
    logic write;
    logic [31:0] wdata;
    logic [31:0] rdata;
    logic _full;
    logic _empty; 
    
    modport fifoif(
        input read,
        input write,
        input wdata,
        output rdata,
        output _full,
        output _empty
    );
endinterface

interface IFID_REG;
    logic [`PC_BITS-1:0] pc;
    logic [`SRAM_DATA_BITS-1:0] instr;
    modport IF(
        input pc,
        input instr
    );
    modport ID(
        output pc,
        output instr
    );
endinterface

interface IDEXE_REG;
    logic [`PC_BITS-1:0      ] PC;
    logic [2:0               ] funct3;
    logic [6:0               ] funct7;
    logic                      PCtoRegSrc;
    logic                      ALUSrc;
    logic                      RDSrc;
    logic                      MemRead;
    logic                      MemWrite;
    logic                      MemtoReg;
    logic [`CPU_DATA_BITS-1:0] rs1_data;
    logic [`CPU_DATA_BITS-1:0] rs2_data;
    logic [4:0               ] rd;
    logic [4:0               ] rs1_addr;
    logic [4:0               ] rs2_addr;
    logic [`CPU_DATA_BITS-1:0] imm;
    logic                      RegWrite;
    logic [4:0               ] shamt;
    logic [`ALUOP_BITS-1:0   ] ALUop;
    logic                      i_type;
    logic [`JUMP_BITS-1:0    ] JumpType;
    logic [`LW_TYPE_BITS-1:0 ] lw_type;
    logic [`LW_TYPE_BITS-1:0 ] sw_type;
    logic CSR;
    logic CSR_write;
    logic CSR_set;
    logic CSR_clear;
    logic CSR_ret;
    logic CSR_wait;
    logic [11:0] CSR_addr;
    
    modport ID(
        input PC,
        input funct3,
        input funct7,
        input PCtoRegSrc,
        input ALUSrc,
        input RDSrc,
        input MemRead,
        input MemWrite,
        input MemtoReg,
        input rs1_data,
        input rs2_data,
        input rd,
        input rs1_addr,
        input rs2_addr,
        input imm,
        input RegWrite,
        input shamt,
        input ALUop,
        input i_type,
        input JumpType,
        input lw_type,
        input sw_type,
        input CSR,
        input CSR_write,
        input CSR_set,
        input CSR_clear,
        input CSR_ret,
        input CSR_wait,
        input CSR_addr
    );

    modport EXE(
        output PC,
        output funct3,
        output funct7,
        output PCtoRegSrc,
        output ALUSrc,
        output RDSrc,
        output MemRead,
        output MemWrite,
        output MemtoReg,
        output rs1_data,
        output rs2_data,
        output rd,
        output rs1_addr,
        output rs2_addr,
        output imm,
        output RegWrite,
        output shamt,
        output ALUop,
        output i_type,
        output JumpType,
        output lw_type,
        output sw_type,
        output CSR,
        output CSR_write,
        output CSR_set,
        output CSR_clear,
        output CSR_ret,
        output CSR_wait,
        output CSR_addr
    );
endinterface

interface EXEMEM_REG;
    logic [`PC_BITS-1:0        ] PCtoReg;
    logic [`CPU_DATA_BITS-1:0  ] ALUout;
    logic [`CPU_DATA_BITS-1:0  ] forward_rs2_data;
    logic [4:0                 ] rd_addr;
    logic                        RDsrc;
    logic                        Memread;
    logic                        Memwrite;
    logic                        MemtoReg;
    logic                        RegWrite;
    logic [`LW_TYPE_BITS-1:0   ] lw_type;
    logic [`LW_TYPE_BITS-1:0   ] sw_type;
    logic [31:0] pc;
    modport EXE(
        input PCtoReg,
        input ALUout,
        input forward_rs2_data,
        input rd_addr,
        input RDsrc,
        input Memread,
        input Memwrite,
        input MemtoReg,
        input RegWrite,
        input lw_type,
        input sw_type,
        input pc
    );

    modport MEM(
        output PCtoReg,
        output ALUout,
        output forward_rs2_data,
        output rd_addr,
        output RDsrc,
        output Memread,
        output Memwrite,
        output MemtoReg,
        output RegWrite,
        output lw_type,
        output sw_type,
        output pc
    );
endinterface

interface MEMWB_REG;
    logic                       Memtoreg;
    logic [`CPU_DATA_BITS-1:0 ] rd_data;
    logic [4:0                ] rd_addr;
    logic [`SRAM_DATA_BITS-1:0] mem_data;
    logic                       RegWrite;
    modport MEM(
        input Memtoreg,
        input rd_data,
        input rd_addr,
        input mem_data,
        input RegWrite
    );
    modport WB(
        output Memtoreg,
        output rd_data,
        output rd_addr,
        output mem_data,
        output RegWrite
    );
endinterface

`endif
