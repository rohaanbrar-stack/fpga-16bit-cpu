`timescale 1ns / 1ps

module uart_tx_tb();
    reg clk = 0;
    reg rst;
    reg start;
    reg [7:0] data;
    wire tx_out;
    wire busy;
    
    always #5 clk = ~clk;
    
    uart_tx #(.DIV(10)) dut(.clk(clk), .rst(rst), .start(start), .data(data), .tx_out(tx_out), .busy(busy));
    
    initial begin
        rst = 1; start = 1; data = 8'h6B;
        #10
        rst = 0; start = 0;
        #10
        start = 1;
        #10
        start = 0;
        #1100
        data = 8'h5D; start = 1;
        #30
        start = 0;
        #1300
        $finish;
    end
endmodule
