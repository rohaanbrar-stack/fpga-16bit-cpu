`timescale 1ns / 1ps

module seg7_tb();
    reg clk = 0;
    reg [15:0] value;
    wire [6:0] seg;
    wire [3:0] an;
    wire dp;
    
    always #5 clk = ~clk;
    
    seg7 dut(.clk(clk), .value(value), .seg(seg), .an(an), .dp(dp));
    
    initial begin
    value = 16'h1234;
    #3000000
    $finish;
    end
endmodule
