`timescale 1ns / 1ps
`default_nettype none

module cpu_top #(parameter DIV = 25000000) (
        input wire clk,
        input wire rst,
        input wire [15:0] sw,
        output wire [15:0] regd,
        output wire [15:0] r2
    );
    
    wire [15:0] pcout;
    wire [15:0] instr;
    
    wire [2:0] aluop;
    wire aluopsel;
    wire alubsel;
    wire [1:0] wbsel;
    wire addr2sel;
    wire [1:0] branchtype;
    wire jump;
    wire regwrite;
    wire memwrite;
    
    wire [2:0] addr2;
    assign addr2 = addr2sel ? instr[11:9] : instr[5:3];
    wire [15:0] out1;
    wire [15:0] out2;
    
    wire [15:0] out;
    
    wire [15:0] b;
    assign b = alubsel ? out : out2;
    wire [2:0] op;
    assign op = aluopsel ? instr[2:0] : aluop;
    wire [15:0] result;
    wire zero;
    wire lt;
    
    wire [7:0] hi;
    assign hi = instr[8] ? instr[7:0] : out2[15:8];
    wire [7:0] lo;
    assign lo = instr[8] ? out2[7:0] : instr[7:0];
    wire [15:0] splice;
    assign splice = {hi, lo};
    
    wire [15:0] dataout;
    wire [15:0] dataw;
    assign dataw = (wbsel == 2'b00) ? result : (wbsel == 2'b01) ? dataout : splice;
    
    assign regd = dataw;
    
    wire taken;
    assign taken = (branchtype == 2'b01) ? zero : (branchtype == 2'b10) ? ~zero : (branchtype == 2'b11) ? lt : 1'b0;
    wire [1:0] pcsel;
    assign pcsel = jump ? 2'b10 : (taken ? 2'b01 : 2'b00);
    
    wire ce;
    
    pc a0(.clk(clk), .rst(rst), .pcsel(pcsel), .pcout(pcout), .offset(out), .jaddr(instr[11:0]), .ce(ce));
    instruction_mem b0(.addr(pcout[7:0]), .instr(instr));
    control c0(.opcode(instr[15:12]), .aluop(aluop), .aluopsel(aluopsel), .alubsel(alubsel), .wbsel(wbsel), .addr2sel(addr2sel), .branchtype(branchtype), .jump(jump), .regwrite(regwrite), .memwrite(memwrite));
    register_file d0(.addr1(instr[8:6]), .addr2(addr2), .addrw(instr[11:9]), .enablew(regwrite), .clk(clk), .rst(rst), .out1(out1), .out2(out2), .dataw(dataw), .ce(ce), .r2out(r2));
    sign_extend e0(.in(instr[5:0]), .out(out));
    alu f0(.a(out1), .b(b), .op(op), .result(result), .zero(zero), .lt(lt));
    data_mem g0(.dataw(out2), .addr(result), .enablew(memwrite), .clk(clk), .dataout(dataout), .sw(sw));
    tick #(.DIV(DIV)) h0(.clk(clk), .ce(ce));
    
endmodule
