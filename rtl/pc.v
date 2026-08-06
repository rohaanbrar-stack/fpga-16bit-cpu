`timescale 1ns / 1ps

module pc(
        input wire clk,
        input wire rst,
        input wire [15:0] offset,
        input wire [11:0] jaddr,
        input wire [1:0] pcsel,
        output reg [15:0] pcout
    );
    
    wire [15:0] pcin; wire [15:0] pcoff;
    
    assign pcin = pcout + 1;
    assign pcoff = pcout + offset;
    
    always @(posedge clk) begin
        if(rst) begin
            pcout <= 0;
        end
        else if(pcsel == 2'b00) pcout <= pcin;
        else if(pcsel == 2'b01) pcout <= pcoff;
        else if(pcsel == 2'b10) pcout <= {4'b0000 ,jaddr};
    end
endmodule
