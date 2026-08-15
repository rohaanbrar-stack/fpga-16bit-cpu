`timescale 1ns / 1ps

module uart_sequencer_tb();
    reg clk = 0;
    reg rst;
    reg send;
    reg [15:0] load;
    wire [7:0] s_data;
    wire s_start;
    wire tx_busy;
    wire tx_out;
    
    always #5 clk = ~clk;
    
    uart_sequencer seq(.clk(clk), .rst(rst), .send(send), .load(load), .busy(tx_busy), .data(s_data), .start(s_start));
    uart_tx #(.DIV(10)) tx(.clk(clk), .rst(rst), .start(s_start), .data(s_data), .tx_out(tx_out), .busy(tx_busy));
    
    initial begin
        rst = 1; send = 0; load = 16'h0037;
        #10
        rst = 0; send = 1;
        #10
        send = 0;
        #7000
        send = 1; load = 16'hBEEF;
        #10
        send = 0;
        #2000;
        rst = 1;
        #10
        rst = 0; send = 1;
        #10
        send = 0;
        #7000;
        send = 0;
        #10
        $finish;
    end
    
endmodule
