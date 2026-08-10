`timescale 1ns / 1ps

module cpu_top_tb();

    reg clk = 0;
    reg rst;
    wire [15:0] regd;
    
    always #5 clk = ~clk;
    
    cpu_top dut(.clk(clk), .rst(rst), .regd(regd));
    
    initial begin
        rst = 1;
        #20
        rst = 0;
        #400
        $finish;
    end
endmodule
