`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/01/2026 03:49:32 PM
// Design Name: 
// Module Name: mux2_always
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


module mux2_always(
        input wire a,
        input wire b,
        input wire sel,
        output reg y
    );
    
    always @(*) begin
        if(sel) y = b;
        else y = a;
    end
endmodule
