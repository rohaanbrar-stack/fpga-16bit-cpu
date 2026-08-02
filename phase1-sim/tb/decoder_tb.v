`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/01/2026 09:20:46 PM
// Design Name: 
// Module Name: decoder_tb
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


module decoder_tb();
    
    reg [1:0] sel;
    wire [3:0] out;
    
    decoder dut1(.sel(sel), .out(out));
    
    initial begin
        #10
        sel = 2'b00;
        #10
        sel = 2'b01;
        #10
        sel = 2'b10;
        #10
        sel = 2'b11;
        #10
        $finish;
    end

endmodule
