`timescale 1ns / 1ps
`default_nettype none

module uart_tx(
        input wire clk,
        input wire rst,
        input wire start,
        input wire [7:0] data,
        output wire tx_out,
        output reg busy
    );
    
    parameter DIV = 10417;
    reg [9:0] shreg;
    reg [13:0] baud_count;
    reg [3:0] bit_count;
    assign tx_out = shreg[0];
    
    always @(posedge clk) begin
        if(rst) begin
            shreg <= 10'h3FF;
            busy <= 0;
            baud_count <= 0;
            bit_count <= 0;
        end
        else if(start & !busy) begin
            shreg <= {1'b1, data[7:0], 1'b0};
            baud_count <= 0;
            bit_count <= 0;
            busy <= 1;
        end
        else if(busy & (baud_count == DIV - 1)) begin
            shreg <= {1'b1, shreg[9:1]};
            bit_count <= bit_count + 1;
            baud_count <= 0;
            if(bit_count == 9) busy <= 0;
        end
        else if(busy) baud_count <= baud_count + 1;
    end

endmodule
