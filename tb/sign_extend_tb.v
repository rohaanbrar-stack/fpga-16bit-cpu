`timescale 1ns / 1ps

module sign_extend_tb();
    reg [5:0] in;
    wire [15:0] out;
    
    sign_extend dut1(.in(in), .out(out));
    
    initial begin
        in = 6'b000000;
        #10
        in = 6'b011111;
        #10
        in = 6'b100000;
        #10
        in = 6'b111111;
        #10
        in = 6'b001111;
        #10
        $finish;
    end
endmodule
