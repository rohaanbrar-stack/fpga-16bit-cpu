`timescale 1ns / 1ps

module pc_tb();
    reg clk = 0;
    reg rst;
    reg ce;
    reg [15:0] offset;
    reg [11:0] jaddr;
    reg [1:0] pcsel;
    wire [15:0] pcout;
    
    always #5 clk = ~clk;
    
    pc dut(.clk(clk), .rst(rst), .offset(offset), .jaddr(jaddr), .pcsel(pcsel), .pcout(pcout), .ce(ce));
    
    initial begin
    rst = 1; offset = 0; pcsel = 0; jaddr = 0; ce = 1;
    #10
    rst = 0;
    #50
    offset = 7; pcsel = 1;
    #10
    pcsel = 0;
    #10
    offset = -9; pcsel = 1;
    #10
    pcsel = 0;
    #10
    jaddr = 49; pcsel = 2;
    #10
    pcsel = 0;
    #10
    rst = 1;
    #30
    $finish;
    end
endmodule
