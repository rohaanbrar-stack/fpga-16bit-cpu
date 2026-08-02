`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/01/2026 07:55:35 PM
// Design Name: 
// Module Name: register_tb
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


module register_tb();

    reg rst, en;
    reg [7:0] d;
    reg clk = 0;
    wire [7:0] q;

    register dut1(.clk(clk), .rst(rst), .en(en), .d(d), .q(q));
    
    always #5 clk = ~clk;
    
    initial begin
        rst = 0; en = 1; d = 8'h0;
        #10
        d = 8'h12;
        #10
        en = 0;
        #10
        d = 8'h13;
        #10
        rst = 1;
        #10
        en = 1;
        #10
        $finish;
    end
endmodule
