`timescale 1ns / 1ps

module tick(
        input wire clk,
        output reg ce
    );
    
    reg [24:0] count = 0;
    parameter DIV = 25000000;
    
    always @(posedge clk) begin
        if(count == DIV) begin ce <= 1; count <= 0; end
        else begin ce <= 0; count <= count + 1; end
    end
endmodule
