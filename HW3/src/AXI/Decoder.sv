`include "AXI_define.svh"

module Decoder(
    input VALID, 
    input [`AXI_ADDR_BITS-1:0] ADDR,
    input READY_S0,
    input READY_S1,
    input READY_S2,
    output logic VALID_S0,
    output logic VALID_S1,
    output logic VALID_S2,
    output logic READY
);


logic [`AXI_SLAVE_BITS-1:0]SLAVE;
assign {VALID_S2,VALID_S1,VALID_S0} = SLAVE;

always_comb begin
	case(ADDR[`AXI_ADDR_BITS-1:(`AXI_ADDR_BITS/2)])
	        16'h0000 :begin
	            SLAVE = {2'b0,(VALID)};
	            READY= (VALID)?READY_S0 :1'b1;
	        end
	        16'h0001 :begin
	            SLAVE = {1'b0,(VALID),1'b0};
	            READY= (VALID)?READY_S1:1'b1;
	        end
	        default  :begin
	            SLAVE = {VALID,2'b0};
	            READY= (VALID)?READY_S2:1'b1;
	        end
	endcase
end

endmodule
