`timescale 1ns / 1ps

module control_tb();
    reg [3:0] opcode;
    wire [2:0] aluop;
    wire aluopsel;
    wire alubsel;
    wire [1:0] wbsel;
    wire addr2sel;
    wire [1:0] branchtype;
    wire jump;
    wire regwrite;
    wire memwrite;
    
    control dut(.opcode(opcode), .aluop(aluop), .aluopsel(aluopsel), .alubsel(alubsel), .wbsel(wbsel), .addr2sel(addr2sel), .branchtype(branchtype), .jump(jump), .regwrite(regwrite), .memwrite(memwrite));
    
    initial begin
    opcode = 4'b0000;
    #10
    opcode = 4'b0001;
    #10
    opcode = 4'b0010;
    #10
    opcode = 4'b0011;
    #10
    opcode = 4'b0100;
    #10
    opcode = 4'b0101;
    #10
    opcode = 4'b0110;
    #10
    opcode = 4'b0111;
    #10
    opcode = 4'b1000;
    #10
    opcode = 4'b1001;
    #10
    $finish;
    end
endmodule
