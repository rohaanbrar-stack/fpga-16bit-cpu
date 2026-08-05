`timescale 1ns / 1ps

module sign_extend(
        input wire [5:0] in,
        output wire [15:0] out
    );
    
    assign out = {{10{in[5]}}, in};
    
endmodule
