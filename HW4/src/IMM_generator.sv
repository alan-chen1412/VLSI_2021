`include "CPU_DEF.svh"
module IMM_generator(
    input [`IMM_TYPE_BITS-1:0] IMM_TYPE,
    input [4:0] IMM_part1,
    input [19:0] IMM_part2,
    output logic [`CPU_DATA_BITS-1:0]ID_IMM
);


always_comb begin
    case(IMM_TYPE)
        `IMM_I_TYPE:begin
            ID_IMM[11:0] = IMM_part2[19-:12];
            ID_IMM[31:12] = {20{ID_IMM[11]}}; 
        end
        `IMM_S_TYPE:begin
            ID_IMM[4:0] = IMM_part1;
            ID_IMM[11:5] = IMM_part2[19-:7];
            ID_IMM[31:12] = {20{ID_IMM[11]}};
        end
        `IMM_B_TYPE:begin
            ID_IMM[0] = 1'b0;
            ID_IMM[4:1] = IMM_part1[4:1];
            ID_IMM[10:5]= IMM_part2[18-:6];
            ID_IMM[11] = IMM_part1[0];
            ID_IMM[12] = IMM_part2[19];
            ID_IMM[31:13] = {19{ID_IMM[12]}};
        end
        `IMM_U_TYPE:begin
            ID_IMM[11:0] = 12'b0;
            ID_IMM[31:12] = IMM_part2;
        end
        `IMM_J_TYPE:begin
            ID_IMM[20] = IMM_part2[19];
            ID_IMM[10:1] = IMM_part2[18-:10];
            ID_IMM[11] = IMM_part2[8];
            ID_IMM[19:12] = IMM_part2[7:0];
            ID_IMM[31:21] = {11{ID_IMM[20]}};
            ID_IMM[0] = 1'b0;
        end
        `IMM_C_TYPE:begin
            ID_IMM[31:5] = 27'b0;
            ID_IMM[4:0 ] = IMM_part2[3+:5]; 
        end
        default:ID_IMM = `CPU_DATA_BITS'b0;
    endcase
end

endmodule
