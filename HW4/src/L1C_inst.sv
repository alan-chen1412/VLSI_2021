//================================================
// Auther:      Chen Yun-Ru (May)
// Filename:    L1C_inst.sv
// Description: L1 Cache for instruction
// Version:     0.1
//================================================
`include "def.svh"
`include "data_array_wrapper.sv"
`include "tag_array_wrapper.sv"
`define I_STATE_BITS 2
module L1C_inst(
  input clk,
  input rst,
  // Core to CPU wrapper
  input [`DATA_BITS-1:0] core_addr,
  input core_req,
  input core_write,
  input [`DATA_BITS-1:0] core_in,
  input [`CACHE_TYPE_BITS-1:0] core_type,
  // Mem to CPU wrapper
  input [`DATA_BITS-1:0] I_out,
  input I_wait,
  // CPU wrapper to core
  output logic [`DATA_BITS-1:0] core_out,
   output logic core_wait,
  // CPU wrapper to Mem
  output logic I_req,
  output logic [`DATA_BITS-1:0] I_addr,
  output logic I_write,
  output logic [`DATA_BITS-1:0] I_in,
  output logic [`CACHE_TYPE_BITS-1:0] I_type
);

  parameter STATE_IDLE  = `I_STATE_BITS'b0,
            STATE_CHECK = `I_STATE_BITS'b1,
            STATE_MISS  = `I_STATE_BITS'b10,
            STATE_WRITE = `I_STATE_BITS'b11;

  logic [`CACHE_INDEX_BITS-1:0] index;
  logic [`CACHE_DATA_BITS-1:0] DA_out;
  logic [`CACHE_DATA_BITS-1:0] DA_in;
  logic [`CACHE_WRITE_BITS-1:0] DA_write;
  logic DA_read;
  logic [`CACHE_TAG_BITS-1:0] TA_out;
  logic [`CACHE_TAG_BITS-1:0] TA_in;
  logic TA_write;
  logic TA_read;
  logic [`CACHE_LINES-1:0] valid;
  logic [`I_STATE_BITS-1:0] state;
  logic [`I_STATE_BITS-1:0] nxt_state;
  logic [`DATA_BITS-1:0] prev_addr;
  logic [`CACHE_INDEX_BITS-1:0] prev_index;
  logic hit;
  logic sameTag;
  logic sameIndex;
  logic [1:0] cnt;
  logic rst_cnt;
  logic [1:0]r_offset;
  logic [1:0]w_offset;
  logic valid_index; // delete
  logic [3:0] write;
  logic prev_req;
  integer i;
  //--------------- complete this part by yourself -----------------//
  assign index = core_addr[(`CACHE_BLOCK_BITS+2)+:`CACHE_INDEX_BITS];
  assign sameTag = valid[index] ? TA_out == TA_in : 1'b0; 
  assign TA_in = core_addr[(`DATA_BITS-1)-:`CACHE_TAG_BITS];
  assign sameIndex = index == prev_index;
  assign r_offset = I_wait? cnt:cnt + 2'b1;
  assign valid_index = valid[index] ;//delete
  assign I_type = core_type;
  assign I_in = core_in;
  assign core_out = DA_out[{core_addr[3:2],5'b0}+:32];

  always_ff@(posedge clk or posedge rst) begin
    if(rst)
        state <= STATE_IDLE;
    else
        state <= nxt_state;
  end

  always_comb begin
    case(state)
        STATE_IDLE:begin
            if(core_req)
                if(core_write)
                    nxt_state = STATE_CHECK;//(valid[index]) ? (hit) ? STATE_WRITE : STATE_CHECK: STATE_WRITE;
                else 
                    nxt_state = (valid[index]) ? (hit) ? STATE_IDLE: STATE_CHECK : STATE_CHECK;
            else 
                nxt_state = STATE_IDLE;
        end
        STATE_CHECK:begin
            if(core_write)
                nxt_state = (I_wait)? STATE_CHECK:STATE_WRITE;
            else 
                nxt_state = (hit) ? STATE_IDLE:STATE_MISS;
        end
        STATE_MISS:begin
            nxt_state = (&cnt & ~I_wait) ? STATE_IDLE: STATE_MISS; 
        end
        STATE_WRITE:begin
            nxt_state = I_wait ? STATE_WRITE:STATE_IDLE;
        end
    endcase
  end

  always_comb begin
    DA_write = `CACHE_WRITE_BITS'hffff;
    DA_in = `CACHE_DATA_BITS'b0;
    case(state)
        STATE_IDLE:begin
            hit = valid[index] ? core_req &  prev_req & sameTag & (index == prev_index) :1'b0; 
            I_req   = 1'b0; // valid[index] & core_req ? hit & core_write :core_req;
            I_write = 1'b0; //valid[index] ? (prev_req & hit) ? core_write : 1'b0 : core_write;
            I_addr = (core_write)?{core_addr[`DATA_BITS-1:2] ,w_offset} : {core_addr[`DATA_BITS-1:4],2'b0,w_offset};
            core_wait = core_req ? core_write | ~( hit) | I_wait: 1'b0;
            rst_cnt = 1'b1;
            TA_write = 1'b1;
            TA_read = 1'b1;
            DA_read = 1'b1;
            //DA_write[{core_addr[3:2],2'b0}+:4] = (hit & core_write) ? write : `CACHE_WRITE_BITS'hffff;
            //DA_in[{core_addr[3:2],5'b0}+:32] = core_in;
        end
        STATE_CHECK:begin
            TA_read = 1'b1;
            hit = sameTag;
            I_req = core_write;
            I_write = core_write & core_req;
            I_addr = core_write ? {core_addr[`DATA_BITS-1:2],w_offset} : {core_addr[`DATA_BITS-1:4],4'b0};
            rst_cnt = 1'b1;//~(sameTag | core_write);
            core_wait = core_write ? 1'b1 : ~hit; 
            TA_write = 1'b1;
            DA_write[{core_addr[3:2],2'b0}+:4] = (hit & core_write) ? write : 4'hf;
            DA_read = 1'b1;
            DA_in[{core_addr[3:2],5'b0}+:32] = core_in;
        end
        STATE_MISS:begin
            hit = sameTag;
            I_req = ~(&cnt);
            TA_write = ~(&cnt & ~I_wait);
            I_write = 1'b0;
            I_addr = {core_addr[`DATA_BITS-1:4],4'b0};
            rst_cnt = 1'b0;
            core_wait = 1'b1;
            DA_write[{cnt,2'b0}+:4] = write; 
            DA_read = 1'b1;
            TA_read = 1'b1; 
            DA_in[{cnt,5'b0}+:32] = I_out;
        end
        STATE_WRITE:begin
            hit = sameTag;
            I_req = 1'b0;
            I_write = 1'b0;
            I_addr = core_addr;
            rst_cnt = 1'b0;
            core_wait = I_wait;
            TA_write = 1'b1;
            TA_read = 1'b1;
            DA_read = 1'b0;
            DA_in = 128'hf;
        end
    endcase
  end


  always_ff@(posedge clk or posedge rst) begin
    if(rst) begin
        for(i=0;i<`CACHE_LINES;i=i+1)
            valid[i] <= 1'b0;
        prev_index <= `CACHE_INDEX_BITS'b0;
        cnt <= 2'b0;
        prev_req <= 1'b0;
    end
    else begin
        prev_req <= core_req;
        valid[index] <= ~TA_write ? 1'b1 : valid[index];
        prev_index <= index;//(hit & core_req & ~core_wait)?index : prev_index; // modify
        cnt <= (rst_cnt) ? 2'b0 : (I_wait)? cnt : cnt + 2'b1;
    end
  end

  always_comb begin
    case(core_type)
        `CACHE_BYTE:w_offset = core_addr[1:0];
        `CACHE_HWORD:w_offset = {core_addr[1],1'b0};
        `CACHE_WORD: w_offset = 2'b0;
        `CACHE_BYTE_U: w_offset = core_addr[1:0];
        `CACHE_HWORD_U:w_offset = {core_addr[1],1'b0};
        default: w_offset = 2'b0;
    endcase
  end

  always_comb begin
    write = 4'hf;
    if(core_write)
        case(core_type)
            `CACHE_BYTE:write[core_addr[1:0]] = 1'b0;
            `CACHE_HWORD:write[{core_addr[1],1'b0}+:2] = 2'b00;
            `CACHE_WORD: write = 4'b0;
            `CACHE_BYTE_U: write[core_addr[1:0]] = 1'b0;
            `CACHE_HWORD_U:write[{core_addr[1],1'b0}+:2] = 2'b0;
            default: write = 4'b0; 
        endcase
    else
        write = I_wait ? 4'hf:4'b0;
  end

  
  data_array_wrapper DA(
    .A(index),
    .DO(DA_out),
    .DI(DA_in),
    .CK(clk),
    .WEB(DA_write),
    .OE(DA_read),
    .CS(1'b1)
  );
   
  tag_array_wrapper  TA(
    .A(index),
    .DO(TA_out),
    .DI(TA_in),
    .CK(clk),
    .WEB(TA_write),
    .OE(TA_read),
    .CS(1'b1)
  );

endmodule

