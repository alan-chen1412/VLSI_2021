`include "AXI_define.svh"
module Decoder(
    input clk, 
    input rst,
    input [`AXI_ADDR_BITS-1:0] ADDR,
    input READY_S0,
    input READY_S1,
    input READY_S2,
    input READY_S3,
    input READY_S4,
    input READY_S5,
    input READY_S6,
    input VALID,
    output logic VALID_S0,
    output logic VALID_S1,
    output logic VALID_S2,
    output logic VALID_S3,
    output logic VALID_S4,
    output logic VALID_S5,
    output logic VALID_S6,
    output logic READY
);

logic [`AXI_SLAVE_BITS-1:0] slave;
logic [`AXI_SLAVE_BITS-1:0] slave_ready;
logic [`AXI_SLAVE_BITS-1:0] slave_Prevready;
logic [`AXI_SLAVE_BITS-1:0] slave_lock;
logic [`AXI_SLAVE_BITS-1:0] slave_lock_reg;
integer i ;

//~((slave_lock_reg & ~slave_ready) | slave_lock)

//if slave_ready ? slave_lock_reg==0 : slave_lock_reg ;

assign {VALID_S6,VALID_S5,VALID_S4,VALID_S3,VALID_S2,VALID_S1,VALID_S0} = (slave) & ~((slave_lock_reg & ~slave_ready) | slave_lock);
assign slave_ready = {READY_S6,READY_S5,READY_S4,READY_S3,READY_S2,READY_S1,READY_S0};


assign slave_lock = slave_Prevready & (~slave_ready);

always_ff@(posedge clk or negedge rst) begin
	if(~rst) begin
		slave_Prevready <= `AXI_SLAVE_BITS'b0;
		slave_lock_reg <= `AXI_SLAVE_BITS'b0;
	end
	else begin
		slave_Prevready <= slave_ready;
		for(i=0;i<`AXI_SLAVE_BITS;i++)
			slave_lock_reg[i] <= (slave_lock_reg[i] & slave_ready[i]) ? 1'b0 : (slave_lock[i]) ? 1'b1 : slave_lock_reg[i]; 	
	end
end

always_comb begin
    if (VALID) begin
        unique if(ADDR < `AXI_ADDR_BITS'h2000 & ADDR >= `AXI_ADDR_BITS'b0)begin
            slave = `AXI_SLAVE0;
            READY = READY_S0 ;
        end
        else if(ADDR < `AXI_ADDR_BITS'h20000 & ADDR > `AXI_ADDR_BITS'hFFFF)begin
            slave = `AXI_SLAVE1;
            READY = READY_S1 ;
        end
        else if(ADDR < `AXI_ADDR_BITS'h30000 & ADDR > `AXI_ADDR_BITS'h1FFFF)begin
            slave = `AXI_SLAVE2;
            READY = READY_S2 ;
        end
        else if(ADDR < `AXI_ADDR_BITS'h10000400 & ADDR > `AXI_ADDR_BITS'h0FFFFFFF)begin
            slave = `AXI_SLAVE3;
            READY = READY_S3 ;
        end
        else if(ADDR < `AXI_ADDR_BITS'h20200000 & ADDR > `AXI_ADDR_BITS'h1FFFFFFF)begin
            slave = `AXI_SLAVE4;
            READY = READY_S4 ;
        end
        else if(ADDR < `AXI_ADDR_BITS'h40000014 & ADDR > `AXI_ADDR_BITS'h3FFFFFFF)begin
            slave = `AXI_SLAVE5;
            READY = READY_S5 ;
        end
        else begin
            slave = `AXI_SLAVE6;
            READY = READY_S6 ;
        end
    end
    else begin
        slave = `AXI_SLAVE_BITS'b0;
        READY = 1'b1;
    end
end

endmodule
