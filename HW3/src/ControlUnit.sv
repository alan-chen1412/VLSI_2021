`include "CPU_DEF.svh"
module ControlUnit(
    input [6:0] opcode,
    input [2:0] funct3,
    output logic mem_read,
    output logic mem_write,
    output logic reg_write,
    output logic [`IMM_TYPE_BITS-1:0] Imm_type,
    output logic [`ALUOP_BITS-1:0] ALU_op,
    output logic PCtoRegSrc,
    output logic ALUSrc,
    output logic [`JUMP_BITS-1:0]Jump_type,
    output logic RDsrc,
    output logic MemtoReg,
    output logic i_type,
    output logic [`LW_TYPE_BITS-1:0]lw_type,
    output logic [`LW_TYPE_BITS-1:0]sw_type
);


always_comb begin
    case(opcode)
        `R_TYPE:begin
            mem_read    = 1'b0;
            mem_write   = 1'b0;
            reg_write   = 1'b1;
            PCtoRegSrc  = 1'b0;
            ALUSrc      = 1'b1;
            RDsrc       = 1'b0;
            Imm_type    = `IMM_I_TYPE; 
            MemtoReg    = 1'b0;  
            ALU_op      = `ALUOP_R_TYPE;
            Jump_type   = `JUMP_NEXT;  
            i_type      = 1'b0; 
            lw_type     = `LW_WORD;
            sw_type     = `SW_WORD;
        end
        `I_TYPE:begin
            mem_read    = 1'b0;
            mem_write   = 1'b0;
            reg_write   = 1'b1;
            PCtoRegSrc  = 1'b0;
            ALUSrc      = 1'b0;
            RDsrc       = 1'b0;
            Imm_type    = `IMM_I_TYPE; 
            ALU_op      = `ALUOP_R_TYPE;
            Jump_type   = `JUMP_NEXT;  
            MemtoReg    = 1'b0; 
            i_type      = 1'b1; 
            lw_type     = `LW_WORD;
            sw_type     = `SW_WORD;
        end
        `L_TYPE:begin
            mem_read    = 1'b1;
            mem_write   = 1'b0;
            reg_write   = 1'b1;
            PCtoRegSrc  = 1'b0;
            ALUSrc      = 1'b0;
            RDsrc       = 1'b0;
            Imm_type    = `IMM_I_TYPE; 
            ALU_op      = `ALUOP_ADD;
            Jump_type   = `JUMP_NEXT;  
            MemtoReg    = 1'b1; 
            i_type      = 1'b0; 
            sw_type     = `SW_WORD;
            case(funct3)
                3'b010:lw_type = `LW_WORD;
                3'b000:lw_type = `LW_S_BYTE;
                3'b001:lw_type = `LW_HWORD_S;
                3'b100:lw_type = `LW_U_BYTE; 
                3'b101:lw_type = `LW_HWORD_U;
                default:lw_type = `LW_WORD;
            endcase
        end
        `JALR:begin
            mem_read    = 1'b0;
            mem_write   = 1'b0;
            reg_write   = 1'b1;
            PCtoRegSrc  = 1'b0;
            ALUSrc      = 1'b0;
            RDsrc       = 1'b1;
            Imm_type    = `IMM_I_TYPE; 
            ALU_op      = `ALUOP_ADD;
            Jump_type   = `JUMP_REG;  
            MemtoReg    = 1'b0; 
            i_type      = 1'b0; 
            lw_type     = `LW_WORD;
            sw_type     = `SW_WORD;
        end
        `S_TYPE:begin
            mem_read    = 1'b0;
            mem_write   = 1'b1;
            reg_write   = 1'b0;
            PCtoRegSrc  = 1'b0;
            ALUSrc      = 1'b0;
            RDsrc       = 1'b1;
            Imm_type    = `IMM_S_TYPE; 
            ALU_op      = `ALUOP_ADD;
            Jump_type   = `JUMP_NEXT;  
            MemtoReg    = 1'b0; 
            i_type      = 1'b0; 
            lw_type     = `LW_WORD;
            case(funct3)
                3'b010:sw_type = `SW_WORD;
                3'b000:sw_type = `SW_BYTE;
                3'b001:sw_type = `SW_HWORD;
                default:sw_type = `SW_WORD;
            endcase
        end
        `B_TYPE:begin
            mem_read    = 1'b0;
            mem_write   = 1'b0;
            reg_write   = 1'b0;
            PCtoRegSrc  = 1'b1;
            ALUSrc      = 1'b1;
            RDsrc       = 1'b1;
            Imm_type    = `IMM_B_TYPE; 
            ALU_op      = `ALUOP_B_TYPE;
            Jump_type   = `JUMP_BRA;  
            MemtoReg    = 1'b0; 
            i_type      = 1'b0; 
            lw_type     = `LW_WORD;
            sw_type     = `SW_WORD;
        end
        `AUIPC:begin
            mem_read    = 1'b0;
            mem_write   = 1'b0;
            reg_write   = 1'b1;
            PCtoRegSrc  = 1'b1;
            ALUSrc      = 1'b1;
            RDsrc       = 1'b1;
            Imm_type    = `IMM_U_TYPE; 
            ALU_op      = `ALUOP_ADD;
            Jump_type   = `JUMP_NEXT;  
            MemtoReg    = 1'b0; 
            i_type      = 1'b0; 
            lw_type     = `LW_WORD;
            sw_type     = `SW_WORD;
        end
        `LUI:begin
            mem_read    = 1'b0;
            mem_write   = 1'b0;
            reg_write   = 1'b1;
            PCtoRegSrc  = 1'b1;
            ALUSrc      = 1'b0;
            RDsrc       = 1'b0;
            Imm_type    = `IMM_U_TYPE; 
            ALU_op      = `ALUOP_LUI;
            Jump_type   = `JUMP_NEXT;  
            MemtoReg    = 1'b0; 
            i_type      = 1'b0; 
            lw_type     = `LW_WORD;
            sw_type     = `SW_WORD;
        end
        `J_TYPE:begin
            mem_read    = 1'b0;
            mem_write   = 1'b0;
            reg_write   = 1'b1;
            PCtoRegSrc  = 1'b0;
            ALUSrc      = 1'b0;
            RDsrc       = 1'b1;
            Imm_type    = `IMM_J_TYPE; 
            ALU_op      = `ALUOP_LUI;
            Jump_type   = `JUMP_IMM;  
            MemtoReg    = 1'b0; 
            i_type      = 1'b0; 
            lw_type     = `LW_WORD;
            sw_type     = `SW_WORD;
        end
        default:begin
            mem_read    = 1'b0;
            mem_write   = 1'b0;
            reg_write   = 1'b0;
            PCtoRegSrc  = 1'b0;
            ALUSrc      = 1'b0;
            RDsrc       = 1'b0;
            Imm_type    = `IMM_J_TYPE; 
            ALU_op      = `ALUOP_LUI;
            Jump_type   = `JUMP_NEXT;  
            MemtoReg    = 1'b0; 
            i_type      = 1'b0; 
            lw_type     = `LW_WORD;
            sw_type     = `SW_WORD;
        end
    endcase
end

endmodule
