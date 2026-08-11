`timescale 1ns / 1ps

module basys_top(
        input wire clk,
        input wire rst,
        input wire [15:0] sw,
        output wire [15:0] regd,
        output wire [6:0] seg,
        output wire [3:0] an,
        output wire dp
    );
    
    wire [15:0] r2;
    
    cpu_top j0(.clk(clk), .rst(rst), .sw(sw), .regd(regd), .r2(r2));
    seg7 k0(.clk(clk), .value(r2), .seg(seg), .an(an), .dp(dp));
    
endmodule
