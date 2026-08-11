`timescale 1ns / 1ps

// THROWAWAY - board test harness for seg7. Delete after 5.2 closes.

module seg7_test(
        input  wire        clk,
        input  wire [15:0] sw,
        output wire [6:0]  seg,
        output wire [3:0]  an,
        output wire        dp
    );

    seg7 u0(
        .clk   (clk),
        .value (sw),
        .seg   (seg),
        .an    (an),
        .dp    (dp)
    );

endmodule
