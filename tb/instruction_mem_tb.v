`timescale 1ns / 1ps

module instruction_mem_tb();
    
    reg [7:0] addr;
    wire [15:0] instr;
   
    instruction_mem dut(.addr(addr), .instr(instr));
   
    initial begin
        addr = 0;
        #10
        addr = 1;
        #10
        addr = 2;
        #10
        addr = 3;
        #10
        addr = 4;
        #10
        addr = 5;
        #10
        addr = 6;
        #10
        addr = 3;
        #10
        $finish;
    end
endmodule
