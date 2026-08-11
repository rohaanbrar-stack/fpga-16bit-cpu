`timescale 1ns / 1ps

module register_file(
        input wire [2:0] addr1,
        input wire [2:0] addr2,
        input wire [2:0] addrw,
        input wire enablew,
        input wire clk,
        input wire rst,
        input wire ce,
        input wire [15:0] dataw,
        output wire [15:0] out1,
        output wire [15:0] out2
    );
    
    reg [15:0] regs [0:7];
    integer i;
    
    assign out1 = regs[addr1];
    assign out2 = regs[addr2];
    
    always @(posedge clk) begin
        if(rst) for(i = 0; i < 8; i = i + 1) regs[i] <= 16'h0000;
        else if(ce) begin
            if(enablew) regs[addrw] <= dataw;
        end
    end
    
endmodule
