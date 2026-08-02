`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/01/2026 03:55:30 PM
// Design Name: 
// Module Name: mux2_tb
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


module mux2_tb();

    reg a, b, sel;
    wire y_assign, y_always;
    
    mux2        dut1 (.a(a), .b(b), .sel(sel), .y(y_assign));
    mux2_always dut2 (.a(a), .b(b), .sel(sel), .y(y_always));
    
    initial begin
        a = 0; b = 0; sel = 0;
        #10
        a = 1;
        #10
        b = 1;
        #10
        sel = 1;
        #10
        a = 0;
        #10
        b = 0;
        #10
        a = 1;
        #10
        a = 0; b = 1; sel = 0;
        #10
        $finish;
    end
endmodule
