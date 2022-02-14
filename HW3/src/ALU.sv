`include "CPU_DEF.svh"
module ALU(
    input [`CPU_DATA_BITS-1:0] EXE_rs1_data,
    input [`CPU_DATA_BITS-1:0] EXE_rs2_data,
    input [`ALUCTRL_BITS-1 :0] EXE_ALUCtrl,
    input [4:0] EXE_shamt,
    input EXE_i_type,
    output logic [`CPU_DATA_BITS-1:0] EXE_ALUout,
    output logic                      EXE_iszero
);

logic signed [`CPU_DATA_BITS-1:0] EXE_signed_rs1_data;
logic signed [`CPU_DATA_BITS-1:0] EXE_signed_rs2_data;
logic [4:0] shift;
assign EXE_signed_rs1_data = EXE_rs1_data;
assign EXE_signed_rs2_data = EXE_rs2_data;
assign shift = EXE_i_type ? EXE_shamt : EXE_rs2_data[4:0];
assign EXE_iszero = |EXE_ALUout;
always_comb begin
    case(EXE_ALUCtrl)
        `ALU_ADD:begin
            EXE_ALUout = EXE_rs1_data + EXE_rs2_data;
        end
        `ALU_SUB:begin
            EXE_ALUout = EXE_rs1_data - EXE_rs2_data;
        end
        `ALU_SLL:begin
            EXE_ALUout = EXE_rs1_data << shift;
        end
        `ALU_SLT:begin
            EXE_ALUout = EXE_signed_rs1_data < EXE_signed_rs2_data ? `CPU_DATA_BITS'b1: `CPU_DATA_BITS'b0; 
        end
        `ALU_SLTU:begin
            EXE_ALUout = EXE_rs1_data < EXE_rs2_data ? `CPU_DATA_BITS'b1:`CPU_DATA_BITS'b0;
        end
        `ALU_XOR:begin
            EXE_ALUout = EXE_rs1_data ^ EXE_rs2_data;
        end
        `ALU_SRL:begin
            EXE_ALUout = EXE_rs1_data >>> shift;
        end
        `ALU_OR:begin
            EXE_ALUout = EXE_rs1_data | EXE_rs2_data;
        end
        `ALU_AND:begin
            EXE_ALUout = EXE_rs1_data & EXE_rs2_data;
        end
        `ALU_SRA:begin
            EXE_ALUout = EXE_signed_rs1_data >>> shift;
        end
        `ALU_IMM:begin
            EXE_ALUout = EXE_rs2_data;
        end
        default:begin
            EXE_ALUout = `CPU_DATA_BITS'b0;
        end
    endcase
end
endmodule
