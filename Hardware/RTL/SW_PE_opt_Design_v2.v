/********************************************************
********** Program Name : SW_PE__opt_Design_v2.v       **********
********** Programmer   : LEE CHENG-LIN        **********
********************************************************/

/* Description:                        
    Specified for DNA Sequence      
    parameter:6/-1(match/mismatch)  
    MAX accumulate score 256(8bit)     
*/
`timescale 1 ns/1 ps
`define ALPHA   2
`define BETA    1
`define MATCH   16'b0000_0110   // 6
`define MISMA   16'b0000_0001   // 1
module SW_PE_ARRAY (clk, rst, ripple_en_in, S_load, S_valid, S_in, T_in, max_in, V_in, V_alpha, F_in, ripple_en_out, max_out, V_out, F_out);
    input   clk, rst;
    input   ripple_en_in, S_load, S_valid;
    input   [1:0] S_in, T_in;
    input   [15:0] max_in, V_in, V_alpha, F_in;
    output  ripple_en_out;
    output  [15:0] max_out, V_out, F_out;


    wire    wire_ripple_en [0:64];
    wire    wire_S_load [0:64];
    wire    wire_S_valid [0:64];


    wire    [1:0] wire_S [0:64];
    wire    [1:0] wire_T [0:64];
    
    wire    [15:0] wire_max [0:64];
    wire    [15:0] wire_V [0:64];
    wire    [15:0] wire_V_alpha [0:64];
    wire    [15:0] wire_F [0:64];


    assign  wire_ripple_en[0] = ripple_en_in;
    assign  wire_S_valid[64] = S_valid;
    assign  wire_S_load[64] = S_load;
    assign  wire_S[64] = S_in;
    assign  wire_T[0] = T_in;
    assign  wire_max[0] = max_in;
    assign  wire_V[0] = V_in;
    assign  wire_V_alpha[0] = V_alpha;
    assign  wire_F[0] = F_in;
    assign  ripple_en_out = wire_ripple_en[64];
    assign  max_out = wire_max[64];
    assign  V_out = wire_V[64];
    assign  F_out = wire_F[64];
    
    genvar i;
    generate

        for(i = 0; i < 64; i = i + 1)
            SW_PE PE_instance(.clk(clk), .rst(rst), .in_T_en(wire_ripple_en[i]), .en_S_load(S_load), .in_S_valid(wire_S_valid[i+1]), 
                                .in_S(wire_S[i+1]), .in_T(wire_T[i]), 
                                .in_Max(wire_max[i]), .in_V(wire_V[i]), .in_V_alpha(wire_V_alpha[i]), .in_F(wire_F[i]), .out_T_en(wire_ripple_en[i+1]), .out_S_load(wire_S_load[i]), .out_S_valid(wire_S_valid[i]), .out_S(wire_S[i]), .out_T(wire_T[i+1]),
                                .out_Max(wire_max[i+1]), .out_V(wire_V[i+1]), .out_V_alpha(wire_V_alpha[i+1]), .out_F(wire_F[i+1]));
    endgenerate

endmodule


module SW_PE (clk, rst, in_T_en, en_S_load, in_S_valid, in_S, in_T, in_Max, in_V, in_V_alpha, in_F, out_T_en, out_S_load, out_S_valid, out_S, out_T, out_Max, out_V, out_V_alpha, out_F);
    input   clk, rst;
    input   in_T_en,  en_S_load, in_S_valid;
    input   [1:0] in_S, in_T;
    input   [15:0] in_Max, in_V, in_V_alpha, in_F;
    output  out_T_en, out_S_load, out_S_valid;
    output  [1:0] out_S, out_T;
    output  [15:0] out_Max, out_V, out_V_alpha, out_F;
    wire    out_LUT;
    //wire    en_s_load;
    wire    [15:0] out_v_diag, out_e_out, out_v_under_valid_s;
    wire    [15:0] out_dff1, out_dff2;
    wire    [15:0] out_max1, out_max3, out_max4, out_max5, out_max6;
    wire    [15:0] out_e_beta, out_f_beta;
    wire    [15:0] out_compare;
    
    DFF_F   S_valid (clk, en_S_load, rst, in_S_valid, out_S_valid);
    DFF_2_F S_out   (clk, en_S_load, rst, in_S, out_S);
    DFF     en_s    (clk, 1'b1, rst, en_S_load, out_S_load);
    DFF_2   T_out   (clk, in_T_en, rst, in_T, out_T);
    DFF     en_rip  (clk, 1'b1, rst, in_T_en, out_T_en);
    DFF_16  V_diag  (clk, in_T_en, rst, in_V, out_v_diag);
    DFF_MAX Max_out (clk, rst, out_max1, out_Max);
    DFF_16  V_out   (clk, in_T_en, rst, out_max6, out_V);
    LUT     lut     (out_S, in_T, out_LUT);
    DFF_16  E_out   (clk, in_T_en, rst, out_max3, out_e_out);
    DFF_16  F_out   (clk, in_T_en, rst, out_max4, out_F);
    COMPARE compare (out_LUT, out_v_diag, out_compare);
    MAX     max1    (in_Max, out_v_under_valid_s, out_max1);
    MUX16   max1mod (out_S_valid & out_T_en , 16'd0, out_V, out_v_under_valid_s);
    MAX     max3    (out_e_beta, out_V_alpha, out_max3);
    MAX     max4    (in_V_alpha, out_f_beta, out_max4);
    MAX     max5    (out_max3, out_max4, out_max5);
    MAX     max6    (out_compare, out_max5, out_max6);
    SUB_ALPHA   a1  (out_V, out_V_alpha);
    SUB_BETA    b1  (out_e_out, out_e_beta);
    SUB_BETA    b2  (in_F, out_f_beta);
endmodule

module COMPARE (in_match, in_v, out);
    input   in_match;
    input   [15:0] in_v;
    output  [15:0] out;
    assign  out = in_match ? in_v + (`MATCH) : ( in_v > (`MISMA) ? in_v - (`MISMA) : 0);
endmodule

module SUB_ALPHA (in_value, out_value);
    input   [15:0] in_value;
    output  [15:0] out_value;
    assign  out_value = in_value > (`ALPHA) ? in_value - (`ALPHA) : 0;
endmodule

module SUB_BETA (in_value, out_value);
    input   [15:0] in_value;
    output  [15:0] out_value;
    assign  out_value = in_value > (`BETA) ? in_value - (`BETA) : 0;
endmodule

module MAX (in_value1, in_value2, out_value);
    input   [15:0] in_value1;
    input   [15:0] in_value2;
    output  [15:0] out_value;
    assign  out_value = (in_value1 > in_value2) ? ( in_value1>0 ? in_value1 : 0 ) : ( in_value2>0 ? in_value2 : 0 );
endmodule

module LUT (in_seq1, in_seq2, out_match_mismatch);
    input   [1:0] in_seq1;
    input   [1:0] in_seq2;
    output  out_match_mismatch;
    reg     out_match_mismatch;
    always@(*) begin
        out_match_mismatch = (in_seq1 == in_seq2) ? 1 : 0;//6,-1 
    end

    
endmodule

module MUX (in_ctrl, in_false, in_true, out);
    input   in_ctrl;
    input   in_false;
    input   in_true;
    output  out;
    assign  out = in_ctrl ? in_true : in_false;
endmodule

module MUX16 (in_ctrl, in_false, in_true, out);
    input   in_ctrl;
    input   [15:0] in_false;
    input   [15:0] in_true;
    output  [15:0] out;
    assign  out = in_ctrl ? in_true : in_false;
endmodule
    
// module S_VALID (clk, en, rst, out_S_load, s_valid_rst, s_valid);
//     input   clk;
//     input   en;
//     input   rst;
//     input   out_S_load;
//     input   s_valid_rst;
//     output  s_valid;
//     reg     s_valid, n_s_valid;
//     always@(*) begin
//         n_s_valid = s_valid;
//         if(s_valid_rst) n_s_valid = 0;
//         if(out_S_load & en) n_s_valid = 1;
//     end

//     always@(posedge clk) begin
//         if(rst) s_valid <= 0;
//         else s_valid <= n_s_valid;
//     end
// endmodule

module DFF (clk, en, rst, in_D, out_Q);
    input   clk;
    input   en;
    input   rst;
    input   in_D;
    output  out_Q;
    reg     next_out_Q;
    reg     out_Q;
    
    always@(*) begin
        if(en) next_out_Q = in_D;
        else next_out_Q = 0;       
    end
    always@( posedge clk) begin
        if(rst) out_Q <= 0;
        else out_Q <= next_out_Q;
    end
endmodule

module DFF_F (clk, en, rst, in_D, out_Q);
    input   clk;
    input   en;
    input   rst;
    input   in_D;
    output  out_Q;
    reg     next_out_Q;
    reg     out_Q;
    
    always@(*) begin
        if(en) next_out_Q = in_D;
        else next_out_Q = out_Q;       
    end
    always@( posedge clk) begin
        if(rst) out_Q <= 0;
        else out_Q <= next_out_Q;
    end
endmodule

module DFF_2_F (clk, en, rst, in_D, out_Q);
    input   clk;
    input   en;
    input   rst;
    input   [1:0] in_D;
    output  [1:0] out_Q;
    reg     [1:0] next_out_Q;
    reg     [1:0] out_Q;
    
    always@(*) begin
        if(en) next_out_Q = in_D;
        else next_out_Q = out_Q;       
    end
    always@( posedge clk) begin
        if(rst) out_Q <= 0;
        else out_Q <= next_out_Q;
    end
endmodule



module DFF_2 (clk, en, rst, in_D, out_Q);
    input   clk;
    input   en;
    input   rst;
    input   [1:0] in_D;
    output  [1:0] out_Q;
    reg     [1:0] next_out_Q;
    reg     [1:0] out_Q;
    
    always@(*) begin
        if(en) next_out_Q = in_D;
        else next_out_Q = 0;       
    end
    always@( posedge clk) begin
        if(rst) out_Q <= 0;
        else out_Q <= next_out_Q;
    end
endmodule

module DFF_16 (clk, en, rst, in_D, out_Q);
    input   clk;
    input   en;
    input   rst;
    input   [15:0] in_D;
    output  [15:0] out_Q;
    reg     [15:0] next_out_Q;
    reg     [15:0] out_Q;
    always@(*) begin
        if(en) next_out_Q = in_D;
        else next_out_Q = 0;       
    end
    always@( posedge clk) begin
        if(rst) out_Q <= 0;
        else out_Q <= next_out_Q;
    end
endmodule

module DFF_MAX (clk, rst, in_D, out_Q);
    input   clk;
    input   rst;
    input   [15:0] in_D;
    output  [15:0] out_Q;
    reg     [15:0] next_out_Q;
    reg     [15:0] out_Q;
    always@(*) begin
        next_out_Q = in_D > out_Q ? in_D : out_Q;
    end
    always@( posedge clk) begin
        if(rst) out_Q <= 0;
        else out_Q <= next_out_Q;
    end
endmodule



 