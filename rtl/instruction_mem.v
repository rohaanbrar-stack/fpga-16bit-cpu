`timescale 1ns / 1ps

module instruction_mem(
        input wire [7:0] addr,
        output wire [15:0] instr
    );
    
    reg [15:0] mem [0:255];
    initial $readmemh("imem.mem", mem);
    assign instr = mem[addr];
endmodule
