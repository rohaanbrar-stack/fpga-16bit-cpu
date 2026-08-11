`timescale 1ns / 1ps

module data_mem(
        input wire [15:0] dataw,
        input wire [15:0] addr,
        input wire enablew,
        input wire clk,
        input wire [15:0] sw,
        output wire [15:0] dataout
    );
    
    reg [15:0] mem [0:255];
    
    assign dataout = addr[8] ? sw : mem[addr[7:0]];
    
    always @(posedge clk) begin
        if(enablew & ~addr[8]) mem[addr[7:0]] <= dataw;
    end
    
endmodule
