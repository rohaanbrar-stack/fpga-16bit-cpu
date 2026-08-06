`timescale 1ns / 1ps

module register_file_tb();
    reg [2:0] addr1;
    reg [2:0] addr2;
    reg [2:0] addrw;
    reg enablew;
    reg clk = 0;
    reg rst;
    reg [15:0] dataw;
    wire [15:0] out1;
    wire [15:0] out2;
    
    always #5 clk = ~clk;
    
    register_file dut(.addr1(addr1), .addr2(addr2), .addrw(addrw), .enablew(enablew), .clk(clk), .rst(rst), .dataw(dataw), .out1(out1), .out2(out2));
    
    initial begin
        addr1 = 3'b000; addr2 = 3'b001; addrw = 3'b111; enablew = 1'b1; rst = 1'b0; dataw = 16'hFFF8;
        #10
        addrw = 3'b110; dataw = 16'hC3A7;
        #10
        addrw = 3'b101; dataw = 16'h1E96;
        #10
        addrw = 3'b100; dataw = 16'h8765;
        #10
        addrw = 3'b011; dataw = 16'hF034;
        #10
        addrw = 3'b010; dataw = 16'h0FC3;
        #10
        addrw = 3'b001; dataw = 16'h5AF2;
        #10
        addrw = 3'b000; dataw = 16'hA001;
        #10
        addr1 = 3'b010; addr2 = 3'b011;
        #10
        addr1 = 3'b100; addr2 = 3'b101;
        #10
        addr1 = 3'b110; addr2 = 3'b111;
        #10
        addr1 = 3'b000; addr2 = 3'b001; enablew = 1'b0; dataw =  16'hDEAD;
        #10
        enablew = 1'b1; dataw = 16'h2B5C;
        #10
        addrw = 3'b001; dataw = 16'h2B5D;
        #10
        addr1 = 3'b010; addr2 = 3'b010;
        #10
        rst = 1'b1;
        #10
        rst = 1'b0; enablew = 1'b0;
        #10
        addr1 = 3'b000; addr2 = 3'b001;
        #10
        addr1 = 3'b010; addr2 = 3'b011;
        #10
        addr1 = 3'b100; addr2 = 3'b101;
        #10
        addr1 = 3'b110; addr2 = 3'b111;
        #10
        $finish;
    end
endmodule
