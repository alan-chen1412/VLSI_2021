`include "CPU_DEF.svh"
module PC(
    input clk,
    input rst,
    input [`PC_BITS-1:0] PC_in,
    input PC_write,
    output logic [`PC_BITS-1:0] PC_out,
    output logic IM_req,
    output logic IM_read,
    input DM_stall,
    input IM_stall
);


always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        PC_out <= `PC_BITS'b0;
    end
    else if (PC_write) begin
        PC_out <= PC_in;
    end
end

always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        IM_req <= 1'b1;
        IM_read <= 1'b1;
    end
    else begin
        IM_req <= 1'b1;
        IM_read <= 1'b1;
    end
end

endmodule
