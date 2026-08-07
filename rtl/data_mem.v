`timescale 1ns / 1ps

module data_mem(
        input wire [15:0] dataw,
        input wire [15:0] addr,
        input wire enablew,
        input wire clk,
        output wire [15:0] dataout
    );
    
    reg [15:0] mem [0:255];
    
    assign dataout = mem[addr];
    
    always @(posedge clk) begin
        if(enablew) mem[addr] <= dataw;
    end
    
endmodule
