`ifndef UNCAHCE
`define UNCAHCE
module addrfilter(
    input [31:0] addr,
    output logic volatile
);

assign volatile = ((addr > 32'h3fffffff) & (addr < 32'h40000014));

endmodule

`endif
