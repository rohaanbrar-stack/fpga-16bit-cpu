`timescale 1ns / 1ps
`default_nettype none

module uart_sequencer(
        input wire clk,
        input wire rst,
        input wire send,
        input wire [15:0] load,
        input wire busy,
        output wire [7:0] data,
        output reg start
    );
    
    reg prev_busy;
    reg [2:0] index;
    reg [15:0] latch;
    
    assign data = (index == 0) ? (latch[15:12] < 10 ? 8'h30 + latch[15:12] : 8'h37 + latch[15:12]) :
                  (index == 1) ? (latch[11:8] < 10 ? 8'h30 + latch[11:8] : 8'h37 + latch[11:8])  : 
                  (index == 2) ? (latch[7:4] < 10 ? 8'h30 + latch[7:4] : 8'h37 + latch[7:4]) : 
                  (index == 3) ? (latch[3:0] < 10 ? 8'h30 + latch[3:0] : 8'h37 + latch[3:0]) : 
                  (index == 4) ? 8'h0D : 
                  (index == 5) ? 8'h0A : 8'h00;
    
    always @(posedge clk) begin
        start <= 0;
        prev_busy <= busy;
        if(rst) begin
            start <= 0;
            prev_busy <= 0;
            index <= 3'b000;
            latch <= 16'h0000;
        end
        else if(send) begin
            latch <= load;
            index <= 0;
            start <= 1;
        end
        else if(prev_busy & !busy) begin
            if(index < 5) begin
                index <= index + 1;
                start <= 1;
            end
            else if(index == 5) start <= 0;
        end
    end
endmodule
