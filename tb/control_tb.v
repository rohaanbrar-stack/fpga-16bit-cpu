`timescale 1ns / 1ps

module control_tb();
    reg [3:0] opcode;
    wire [2:0] aluop;
    wire aluopsel;
    
    control dut(.opcode(opcode), .aluop(aluop), .aluopsel(aluopsel));
    
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
