`include "CPU_DEF.svh"
module ALUCtrl(
    input [`ALUOP_BITS-1:0] EXE_ALUop,
    input [2:0            ] EXE_funct3,
    input [6:0            ] EXE_funct7,
    input                   EXE_i_type,
    output logic [`ALUCTRL_BITS-1:0] EXE_ALUCtrl
);


always_comb begin
    case(EXE_ALUop)
        `ALUOP_R_TYPE:begin
            case(EXE_funct3)
                3'b000:begin
                    EXE_ALUCtrl = (|EXE_funct7) & ~EXE_i_type ? `ALU_SUB:`ALU_ADD;
                end
                3'b001:begin
                    EXE_ALUCtrl = `ALU_SLL;
                end
                3'b010:begin
                    EXE_ALUCtrl = `ALU_SLT;
                end
                3'b011:begin
                    EXE_ALUCtrl = `ALU_SLTU;
                end
                3'b100:begin
                    EXE_ALUCtrl = `ALU_XOR;
                end
                3'b101:begin
                    EXE_ALUCtrl = (|EXE_funct7)?`ALU_SRA:`ALU_SRL;
                end
                3'b110:begin
                    EXE_ALUCtrl = `ALU_OR;
                end
                3'b111:begin
                    EXE_ALUCtrl = `ALU_AND;
                end
            endcase
        end
        `ALUOP_ADD:begin
            EXE_ALUCtrl = `ALU_ADD;
        end
        `ALUOP_LUI:begin
            EXE_ALUCtrl = `ALU_IMM;
        end
        `ALUOP_B_TYPE:begin
            case(EXE_funct3)
                3'b000:begin
                    EXE_ALUCtrl = `ALU_XOR;
                end 
                3'b001:begin
                    EXE_ALUCtrl = `ALU_XOR;
                end
                3'b100:begin
                    EXE_ALUCtrl = `ALU_SLT;
                end
                3'b101:begin
                    EXE_ALUCtrl = `ALU_SLT;
                end
                3'b110:begin
                    EXE_ALUCtrl = `ALU_SLTU;
                end
                3'b111:begin
                    EXE_ALUCtrl = `ALU_SLTU;
                end
                default:begin
                    EXE_ALUCtrl = `ALU_SLT;
                end
            endcase
        end
        //default:begin
        //    EXE_ALUCtrl = `ALU_ADD;
        //end
    endcase
end

endmodule
