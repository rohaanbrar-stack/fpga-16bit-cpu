`timescale 1ns / 1ps

module control(
        input wire [3:0] opcode,
        output reg [2:0] aluop,
        output reg aluopsel
    );
    
    always @(*) begin
        aluop = 3'b000;
        aluopsel = 1'b0;
        case(opcode)
            4'b0000: begin
                aluop = 3'b000; 
                aluopsel = 1'b1;
            end
            4'b0001: begin
                aluop = 3'b000; 
                aluopsel = 1'b0;
            end
            4'b0010: begin
                aluop = 3'b000; 
                aluopsel = 1'b0;
            end
            4'b0011: begin
                aluop = 3'b000; 
                aluopsel = 1'b0;
            end
            4'b0100: begin
                aluop = 3'b000; 
                aluopsel = 1'b0;
            end
            4'b0101: begin
                aluop = 3'b001; 
                aluopsel = 1'b0;
            end
            4'b0110: begin
                aluop = 3'b001; 
                aluopsel = 1'b0;
            end
            4'b0111: begin
                aluop = 3'b001; 
                aluopsel = 1'b0;
            end
            4'b1000: begin
                aluop = 3'b000; 
                aluopsel = 1'b0;
            end
        endcase
    end
endmodule
