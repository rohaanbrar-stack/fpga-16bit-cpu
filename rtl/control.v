`timescale 1ns / 1ps

module control(
        input wire [3:0] opcode,
        output reg [2:0] aluop,
        output reg aluopsel,
        output reg alubsel,
        output reg [1:0] wbsel,
        output reg addr2sel,
        output reg [1:0] branchtype,
        output reg jump,
        output reg regwrite,
        output reg memwrite
    );
    
    always @(*) begin
        aluop = 3'b000;
        aluopsel = 1'b0;
        alubsel = 1'b0;
        wbsel = 2'b00;
        addr2sel = 1'b0;
        branchtype = 2'b00;
        jump = 1'b0;
        regwrite = 1'b0;
        memwrite = 1'b0;
        case(opcode)
            4'b0000: begin
                aluop = 3'b000; 
                aluopsel = 1'b1;
                alubsel = 1'b0;
                wbsel = 2'b00;
                addr2sel = 1'b0;
                branchtype = 2'b00;
                jump = 1'b0;
                regwrite = 1'b1;
                memwrite = 1'b0;
            end
            4'b0001: begin
                aluop = 3'b000; 
                aluopsel = 1'b0;
                alubsel = 1'b0;
                wbsel = 2'b10;
                addr2sel = 1'b1;
                branchtype = 2'b00;
                jump = 1'b0;
                regwrite = 1'b1;
                memwrite = 1'b0;
            end
            4'b0010: begin
                aluop = 3'b000; 
                aluopsel = 1'b0;
                alubsel = 1'b1;
                wbsel = 2'b00;
                addr2sel = 1'b0;
                branchtype = 2'b00;
                jump = 1'b0;
                regwrite = 1'b1;
                memwrite = 1'b0;
            end
            4'b0011: begin
                aluop = 3'b000; 
                aluopsel = 1'b0;
                alubsel = 1'b1;
                wbsel = 2'b01;
                addr2sel = 1'b0;
                branchtype = 2'b00;
                jump = 1'b0;
                regwrite = 1'b1;
                memwrite = 1'b0;
            end
            4'b0100: begin
                aluop = 3'b000; 
                aluopsel = 1'b0;
                alubsel = 1'b1;
                wbsel = 2'b00;
                addr2sel = 1'b1;
                branchtype = 2'b00;
                jump = 1'b0;
                regwrite = 1'b0;
                memwrite = 1'b1;
            end
            4'b0101: begin
                aluop = 3'b001; 
                aluopsel = 1'b0;
                alubsel = 1'b0;
                wbsel = 2'b00;
                addr2sel = 1'b1;
                branchtype = 2'b01;
                jump = 1'b0;
                regwrite = 1'b0;
                memwrite = 1'b0;
            end
            4'b0110: begin
                aluop = 3'b001; 
                aluopsel = 1'b0;
                alubsel = 1'b0;
                wbsel = 2'b00;
                addr2sel = 1'b1;
                branchtype = 2'b10;
                jump = 1'b0;
                regwrite = 1'b0;
                memwrite = 1'b0;
            end
            4'b0111: begin
                aluop = 3'b001; 
                aluopsel = 1'b0;
                alubsel = 1'b0;
                wbsel = 2'b00;
                addr2sel = 1'b1;
                branchtype = 2'b11;
                jump = 1'b0;
                regwrite = 1'b0;
                memwrite = 1'b0;
            end
            4'b1000: begin
                aluop = 3'b000; 
                aluopsel = 1'b0;
                alubsel = 1'b0;
                wbsel = 2'b00;
                addr2sel = 1'b0;
                branchtype = 2'b00;
                jump = 1'b1;
                regwrite = 1'b0;
                memwrite = 1'b0;
            end
        endcase
    end
endmodule
