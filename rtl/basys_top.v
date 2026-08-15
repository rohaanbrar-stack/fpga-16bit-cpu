`timescale 1ns / 1ps
`default_nettype none

module basys_top(
        input wire clk,
        input wire rst,
        input wire [15:0] sw,
        output wire [15:0] regd,
        output wire [6:0] seg,
        output wire [3:0] an,
        output wire dp,
        output wire tx
    );
    
    wire [15:0] r2;
    reg [15:0] r2_prev;
    reg send;
    wire [7:0] s_data;
    wire s_start;
    wire tx_busy;
    
    cpu_top j0(.clk(clk), .rst(rst), .sw(sw), .regd(regd), .r2(r2));
    seg7 k0(.clk(clk), .value(r2), .seg(seg), .an(an), .dp(dp));
    uart_sequencer l0(.clk(clk), .rst(rst), .send(send), .load(r2), .busy(tx_busy), .data(s_data), .start(s_start));
    uart_tx #(.DIV(10417)) m0(.clk(clk), .rst(rst), .start(s_start), .data(s_data), .tx_out(tx), .busy(tx_busy));
    
    always @(posedge clk) begin
        send <= 0;
        r2_prev <= r2;
        if(rst) begin
            send <= 0;
            r2_prev <= 0;
        end
        else if(r2 != r2_prev) begin
            send <= 1;
        end
    end
    
endmodule
