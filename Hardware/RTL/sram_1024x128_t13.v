
`timescale 1 ns/1 ps
//======================================================
module sram_1024x128_t13 (
   Q,
   clk,
   CEN,
   WEN,
   A,
   D
);
    output [127:0] Q;
    input clk;
    input CEN;
    input WEN;
    input [9:0] A;
    input [127:0] D;
        genvar i;
    generate

        for(i = 0; i < 16; i = i + 1)
            sram_1024x8_t13 ram_instance(.Q(Q[8*i +: 8]), .CLK(clk), .CEN(CEN), .WEN(WEN), .A(A), .D(D[8*i +: 8]));
    endgenerate
endmodule
//======================================================