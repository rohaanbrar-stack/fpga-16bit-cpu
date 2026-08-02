`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/01/2026 09:41:35 PM
// Design Name: 
// Module Name: alu_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module alu_tb();
    reg [7:0] a;
    reg [7:0] b;
    reg [1:0] op;
    wire zero;
    wire [7:0] result;
    
    alu dut1(.a(a), .b(b), .op(op), .zero(zero), .result(result));
    
    initial begin
        a = 8'h0C; b = 8'h0A; op = 2'b00;
        #10
        op = 2'b01;
        #10
        op = 2'b10;
        #10
        op = 2'b11;
        #10
        a = 8'h08; b = 8'h08;
        #10
        op = 2'b01;
        #10
        a = 8'hFF; b = 8'h01;
        #10
        op = 2'b00;
        #10
        $finish;
    end
endmodule
