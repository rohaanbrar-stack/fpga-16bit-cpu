`timescale 1ns / 1ps

module alu_tb();
    reg [15:0] a;
    reg [15:0] b;
    reg [2:0] op;
    wire zero;
    wire sign;
    wire [15:0] result;
    
    alu dut1(.a(a), .b(b), .op(op), .zero(zero), .sign(sign), .result(result));
    
    initial begin
        a = 16'h3C5A; b = 16'h0F34; op = 3'b000;
        #10
        op = 3'b001;
        #10
        op = 3'b010;
        #10
        op = 3'b011;
        #10
        op = 3'b100;
        #10
        op = 3'b101;
        #10
        op = 3'b110;
        #10
        op = 3'b111;
        #10
        b = 16'h3C5A;
        #10
        op = 3'b001;
        #10
        b = 16'h3C5B;
        #10
        b = 16'h0000;
        #10
        op = 3'b110;
        #10
        a = 16'h3C5F; b = 16'h000F;
        #10
        $finish;
    end
endmodule
