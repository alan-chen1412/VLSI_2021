`define MIE 3
`define MPIE 7
`define MPP 11
`define MEIP 11
`define MEIE 11

module CSR(
    input clk,
    input rst,
    input [31:0] CSR_wdata,
    input [11:0] CSR_addr,
    input CSR_write,
    input CSR_clear,
    input CSR_set,
    input interrupt,
    input CSR_wait,
    input CSR_ret,
    input [31:0] EXE_PC,
    input IDRegWrite,
    output logic [31:0] CSR_rdata,
    output logic [31:0] CSR_retPC,
    output logic [31:0] CSR_PC,
    output logic CSR_control,
    output logic CSR_stall
);

logic [31:0] mstatus;
logic [31:0] mie;
logic [31:0] mtvec;
logic [31:0] mepc;
logic [31:0] mip;
logic [31:0] mcycle;
logic [31:0] mcycleh;
logic [31:0] minstret;
logic [31:0] minstreth;
logic zero;
logic stall;

assign mtvec = 32'h10000;
assign CSR_retPC = mepc;
assign CSR_PC = mtvec;
assign zero = ~(|CSR_wdata);
assign CSR_control = mstatus[3] & interrupt & mip[11] & mie[11];
assign stall = CSR_wait & mie[11];

always_ff@(posedge clk or posedge  rst) begin
    if(rst) begin
        {mcycleh,mcycle} <= 64'b0;
        {minstreth,minstreth} <= 64'b0;
    end
    else begin
        {mcycleh,mcycle} <= {mcycleh,mcycle} + 64'b1;
        {minstreth,minstreth} <= {minstreth,minstreth} + 64'b1;
    end
end

always_ff@(posedge clk or posedge rst) begin
    if(rst) begin
        mstatus <= 32'b0;
        mie <= 32'b0;
        mip <= 32'b0;
        mepc <= 32'b0;
    end
    else if(CSR_ret) begin
        mstatus[`MPIE] <= 1'b1;
        mstatus[`MIE]  <= mstatus[`MPIE];
        mstatus[`MPP+:2]  <= 2'b11;
    end
    else if(CSR_wait) begin
        mepc <= EXE_PC + 32'b100;
        mip[`MEIP] <= mie[`MEIE] ? 1'b1 : mip[`MEIP]; 
    end
    else if (interrupt) begin
        mstatus[`MPIE] <= mip[`MEIP] ? mstatus[`MIE] : mstatus[`MPIE];
        mstatus[`MIE]  <= mip[`MEIP] ? 1'b0 : mstatus[`MIE];
        mstatus[`MPP+:2]  <= mip[`MEIP] ? 2'b11 : mstatus[`MPP+:2];
        mip [`MEIP] <= 1'b0;
    end
    else if (IDRegWrite)begin
        case(CSR_addr)
            12'h300:begin
                unique if(CSR_write) begin
                    mstatus[`MIE]    <= CSR_wdata[`MIE];
                    mstatus[`MPIE]   <= CSR_wdata[`MPIE];
                    mstatus[`MPP+:2] <= CSR_wdata[`MPP+:2]; 
                end
                else if(CSR_set & ~zero) begin
                    mstatus[`MIE]    <= CSR_wdata[`MIE   ] | mstatus[`MIE   ]; 
                    mstatus[`MPIE]   <= CSR_wdata[`MPIE  ] | mstatus[`MPIE  ];
                    mstatus[`MPP+:2] <= CSR_wdata[`MPP+:2] | mstatus[`MPP+:2]; 
                end
                else if(CSR_clear & ~zero) begin
                    mstatus[`MIE]    <= ~CSR_wdata[`MIE   ] & mstatus[`MIE   ]; 
                    mstatus[`MPIE]   <= ~CSR_wdata[`MPIE  ] & mstatus[`MPIE  ];
                    mstatus[`MPP+:2] <= ~CSR_wdata[`MPP+:2] & mstatus[`MPP+:2]; 
                end
                else begin
                    mstatus <= mstatus;
                end
            end
            12'h304:begin
                unique if(CSR_write) begin
                    mie[`MEIE] <= CSR_wdata[`MEIE];
                end
                else if(CSR_set & ~zero) begin
                    mie[`MEIE] <= CSR_wdata[`MEIE] | mie[`MEIE];
                end
                else if(CSR_clear & ~zero) begin
                    mie[`MEIE] <= ~CSR_wdata[`MEIE] & mie[`MEIE];
                end
                else begin
                    mie <= mie;
                end
            end
            12'h341:begin
                unique if(CSR_write) begin
                    mepc[31:2] <= CSR_wdata[31:2];
                end
                else if(CSR_set & ~zero) begin
                    mepc[31:2] <= CSR_wdata[31:2] | mepc[31:2];
                end
                else if(CSR_clear & ~zero) begin
                    mepc[31:2] <= ~CSR_wdata[31:2] | mepc[31:2];
                end
                else begin
                    mepc <= mepc;
                end
            end
        endcase
    end
end


always_comb begin
    case(CSR_addr)
        12'h300:CSR_rdata = mstatus;
        12'h304:CSR_rdata = mie;
        12'h305:CSR_rdata = mtvec;
        12'h341:CSR_rdata = mepc;
        12'h344:CSR_rdata = mip;
        12'hB00:CSR_rdata = mcycle;
        12'hB02:CSR_rdata = minstret;
        12'hB80:CSR_rdata = mcycleh;
        12'hB82:CSR_rdata = minstreth;
        default:CSR_rdata = 32'b0;
    endcase
end

always_ff@(posedge clk or posedge rst) begin
    if(rst) 
        CSR_stall <= 1'b0;
    else if(IDRegWrite) 
        CSR_stall <= (stall) ? 1'b1 : CSR_stall;
    else if (CSR_control)
        CSR_stall <= 1'b0;
end

endmodule
