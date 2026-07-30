`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/29/2026 08:06:54 PM
// Design Name: 
// Module Name: LED_Blink
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


module LED_Blink(
    input clk,
    output led
);
    reg [25:0] count;
        
    assign led = count[25];
        
    always @(posedge clk) begin
        count <= count + 1;
    end
endmodule
