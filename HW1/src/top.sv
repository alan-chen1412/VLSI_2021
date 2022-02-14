`include "CPU_DEF.svh"
`include "SRAM_wrapper.sv"
`include "CPU.sv"
module top(
    input clk,
    input rst
);

parameter STATE_READY  = 2'b0,
          STATE_WAIT   = 2'b1,
          STATE_IDLE   = 2'b10;

logic IM_REQ;
logic IM_READ;
logic [`SRAM_WRITE_BITS-1:0] IM_WRITE;
logic [`SRAM_ADDR_BITS-1 :0] IM_ADDR;
logic [`SRAM_DATA_BITS-1 :0] IM_DATA_IN;
logic [`SRAM_DATA_BITS-1 :0] IM_DATA_OUT;
logic DM_REQ;
logic DM_READ;
logic [`SRAM_WRITE_BITS-1:0] DM_WRITE;
logic [`SRAM_ADDR_BITS-1 :0] DM_ADDR;
logic [`SRAM_DATA_BITS-1 :0] DM_DATA_IN;
logic [`SRAM_DATA_BITS-1 :0] DM_DATA_OUT;
logic [1:0]DM_state;
logic [1:0]DM_nxt_state;
logic [1:0]IM_state;
logic [1:0]IM_nxt_state;
logic DM_stall;
logic IM_stall;
logic asyn2_rst;
logic asyn1_rst;
logic DM_SEL;
logic IM_SEL;

assign IM_DATA_IN = `SRAM_DATA_BITS'b0;
assign IM_WRITE = `SRAM_WRITE_BITS'hf;

always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        asyn2_rst <= 1'b1;
        asyn1_rst <= 1'b1;
    end
    else begin
        asyn1_rst <= 1'b0;
        asyn2_rst <= asyn1_rst;
    end
end

always_ff @(posedge clk or posedge asyn2_rst) begin
    if(asyn2_rst) begin
        DM_state <= STATE_IDLE;
        IM_state <= STATE_IDLE;
    end
    else begin
        DM_state <= DM_nxt_state;
        IM_state <= IM_nxt_state;
    end
end

always_comb begin
    case(DM_state)
        STATE_IDLE :DM_nxt_state = STATE_READY;
        STATE_READY:DM_nxt_state = (DM_READ & DM_REQ) ? STATE_WAIT:STATE_READY;
        STATE_WAIT :DM_nxt_state = STATE_READY;
        default    :DM_nxt_state = STATE_IDLE;
    endcase
end

always_comb begin
    case(IM_state)
        STATE_IDLE :IM_nxt_state = STATE_READY;
        STATE_READY:IM_nxt_state = (IM_READ & IM_REQ) ? STATE_WAIT:STATE_READY;
        STATE_WAIT :IM_nxt_state = (DM_stall) ? STATE_WAIT:STATE_READY;
        default    :IM_nxt_state = STATE_IDLE;
    endcase
end

always_comb begin
    case(DM_state)
        STATE_IDLE :begin
            DM_SEL   = 1'b0;
            DM_stall = 1'b0;
        end
        STATE_READY:begin
            DM_SEL   = DM_REQ;
            DM_stall = (DM_READ & DM_REQ);
        end
        STATE_WAIT :begin
            DM_SEL   = 1'b1;
            DM_stall = 1'b0;
        end
        default    :begin
            DM_SEL   = 1'b0;
            DM_stall = 1'b0;
        end
    endcase
end

always_comb begin
    case(IM_state)
        STATE_IDLE :begin
            IM_stall = 1'b1;
            IM_SEL   = 1'b0;
        end
        STATE_READY:begin
            IM_stall = (IM_READ & IM_REQ);
            IM_SEL   = IM_REQ;
        end
        STATE_WAIT :begin
            IM_stall = DM_stall;
            IM_SEL   = 1'b1;
        end
        default    :begin
            IM_stall = 1'b0;
            IM_SEL   = 1'b0;
        end
    endcase
end

SRAM_wrapper IM1(
  .CK(clk),
  .CS(IM_SEL),
  .OE(IM_READ),
  .WEB(IM_WRITE),
  .A(IM_ADDR),
  .DI(IM_DATA_IN),
  .DO(IM_DATA_OUT)
);

SRAM_wrapper DM1(
  .CK(clk),
  .CS(DM_SEL),
  .OE(DM_READ),
  .WEB(DM_WRITE),
  .A(DM_ADDR),
  .DI(DM_DATA_IN),
  .DO(DM_DATA_OUT)
);
CPU i_cpu(
    .clk(clk),
    .rst(asyn2_rst),
    .data_in(DM_DATA_OUT),
    .instr_in(IM_DATA_OUT),
    .DM_stall(DM_stall),
    .IM_stall(IM_stall),
    .instr_addr(IM_ADDR),
    .data_addr(DM_ADDR),
    .data_out(DM_DATA_IN),
    .IM_req(IM_REQ),
    .DM_req(DM_REQ),
    .data_write(DM_WRITE),
    .IM_read(IM_READ),
    .DM_read(DM_READ)
);
endmodule
