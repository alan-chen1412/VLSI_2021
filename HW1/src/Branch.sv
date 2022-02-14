`include "CPU_DEF.svh"
module Branch(
    input [2:0] EXE_funct3,
    input [`JUMP_BITS-1:0] EXE_jump_type,
    input EXE_ALUout,
    input EXE_iszero,
    output logic [`JUMP_BITS-1:0] EXE_branch
);

always_comb begin
    case(EXE_jump_type)
        `JUMP_NEXT:EXE_branch = `BRANCH_NEXT;
        `JUMP_REG :EXE_branch = `BRANCH_REG;
        `JUMP_IMM :EXE_branch = `BRANCH_IMM;
        `JUMP_BRA : begin
            case(EXE_funct3)
                3'b001:begin
                    EXE_branch = EXE_iszero ? `BRANCH_IMM :`BRANCH_NEXT; 
                end
                3'b000:begin
                    EXE_branch = EXE_iszero ? `BRANCH_NEXT:`BRANCH_IMM;
                end
                3'b100:begin
                    EXE_branch = EXE_ALUout ? `BRANCH_IMM :`BRANCH_NEXT;
                end
                3'b101:begin
                    EXE_branch = EXE_ALUout ? `BRANCH_NEXT:`BRANCH_IMM;
                end
                3'b110:begin
                    EXE_branch = EXE_ALUout ? `BRANCH_IMM :`BRANCH_NEXT;
                end
                3'b111:begin
                    EXE_branch = EXE_ALUout ? `BRANCH_NEXT:`BRANCH_IMM;
                end
                default:begin
                    EXE_branch = `BRANCH_NEXT;
                end
            endcase
        end
        //default:begin
        //    EXE_branch = `BRANCH_NEXT;
        //end
    endcase
end

endmodule
