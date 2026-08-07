`timescale 1ns / 1ps

module data_mem_tb();
    reg [15:0] dataw;
    reg [15:0] addr;
    reg enablew;
    reg clk = 0;
    wire [15:0] dataout;
    
    always #5 clk = ~clk;
    
    data_mem dut(.dataw(dataw), .addr(addr), .enablew(enablew), .clk(clk), .dataout(dataout));
    
    initial begin
    dataw = 16'hC3A7; addr = 0; enablew = 0;
    #10
    enablew = 1;
    #10
    enablew = 0; dataw = 16'hDEAD;
    #10
    addr = 1; dataw = 16'h1E96;
    #10
    enablew = 1;
    #10
    addr = 16'h00FF; dataw = 16'h8765;
    #10
    addr = 16'h00A5; dataw = 16'hF034;
    #10
    enablew = 0;
    #10
    addr = 0;
    #10
    $finish;
    end
endmodule
