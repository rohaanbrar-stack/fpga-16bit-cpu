`timescale 1ns / 1ps

module alu(
    input wire [15:0] a,
    input wire [15:0] b,
    input wire [2:0] op,
    output reg [15:0] result,
    output wire zero,
    output wire sign
    );
    
    assign zero = (result == 0);
    assign sign = result[15];
    
    always @(*) begin
        case(op)
            3'b000: result = a + b;
            3'b001: result = a - b;
            3'b010: result = a & b;
            3'b011: result = a | b;
            3'b100: result = a ^ b;
            3'b101: result = ~a;
            3'b110: result = a << b[3:0];
            3'b111: result = a >> b[3:0];
            default: result = a;
        endcase
    end
endmodule
