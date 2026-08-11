`timescale 1ns / 1ps

module seg7(
        input wire clk,
        input wire [15:0] value,
        output reg [6:0] seg,
        output reg [3:0] an,
        output wire dp
    );

    reg [17:0] count = 0;
    assign dp = 1'b1;
    reg [3:0] nib;
    
    always @(posedge clk) begin
        count <= count + 1;
    end
    
    always @(*) begin
        case(count[17:16])
            2'b00: begin nib = value[3:0]; an = 4'b1110; end
            2'b01: begin nib = value[7:4]; an = 4'b1101; end 
            2'b10: begin nib = value[11:8]; an = 4'b1011;end
            2'b11: begin nib = value[15:12]; an = 4'b0111; end
        endcase
        case(nib)
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            4'hA: seg = 7'b0001000;
            4'hB: seg = 7'b0000011;
            4'hC: seg = 7'b1000110;
            4'hD: seg = 7'b0100001;
            4'hE: seg = 7'b0000110;
            4'hF: seg = 7'b0001110;
        endcase
    end
endmodule
