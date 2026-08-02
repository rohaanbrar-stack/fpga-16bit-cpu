`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/01/2026 07:23:06 PM
// Design Name: 
// Module Name: register
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


module register(
        input wire clk,
        input wire rst,
        input wire en,
        input wire [7:0] d,
        output reg [7:0] q
    );
    
    always @(posedge clk) begin
        if(rst) q <= 8'b0;
        else if(en) q <= d;
    end
endmodule
