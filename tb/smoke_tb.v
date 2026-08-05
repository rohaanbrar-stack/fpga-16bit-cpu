`timescale 1ns / 1ps

module smoke_tb();

    reg clk = 0;
    reg [3:0] count = 0;

    always #5 clk = ~clk;

    always @(posedge clk)
        count <= count + 1;

    initial begin
        $display("project is alive");
        #100;
        $display("count = %d", count);
        $finish;
    end
    
endmodule
