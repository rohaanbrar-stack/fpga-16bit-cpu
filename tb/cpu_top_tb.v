`timescale 1ns / 1ps

module cpu_top_tb();

    reg clk = 0;
    reg rst;
    reg [15:0] sw;
    wire [15:0] regd;
    
    always #5 clk = ~clk;
    
    cpu_top #(.DIV(3)) dut(.clk(clk), .rst(rst), .regd(regd), .sw(sw));
    
    initial begin
        rst = 1; sw = 16'h0000;
        #20
        rst = 0; sw = 16'h000A;
        #2000
        rst = 1; sw = 16'h0000;
        #20
        rst = 0; sw = 16'h0005;
        #2000
        rst = 1; sw = 16'h0000;
        #20
        rst = 0; sw = 16'h0003;
        #2000
        $finish;
    end
endmodule
