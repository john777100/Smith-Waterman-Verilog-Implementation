`include "sram_1024x128_t13.v"
`include "SW_PE_opt_Design_v2.v"
`timescale 1 ns/1 ps
`define ALPHA 2
`define TCOUNTLIMIT 3584 // 128 * 56/1024 SRAM used  VF: 128 * 896/1024 SRAM used
`define SCOUNTLIMIT 4096 // 128 * 64/1024 SRAM used 
module SW_Control_v3( clk, rst, Read_en, data_readin, valid, max_result);
    localparam READ = 2'd0;
    localparam SLOAD = 2'd1;
    localparam TCALCU = 2'd2;
    localparam TERMIN = 2'd3;
    localparam SRAMON = 0;
    localparam SRAMOFF = 1;


    

    input   clk, rst;
    input   [1:0] Read_en;// 00: Read S | 01: Read T | 10: standby | 11: Finished;
    input   [1:0] data_readin;
    output  valid;
    output  [15:0] max_result;


    /*****************
    ***SRAM IO******
    ******************/ 
    reg     [127:0] VFin_reg, n_VFin_reg;
    reg     [127:0] VFout_reg, n_VFout_reg;
    reg     [7:0] Tin_reg, n_Tin_reg;
    reg     [7:0] Sin_reg, n_Sin_reg;
    
    /*****************
    ***SRAM IO END******
    ******************/ 

    /*****************
    ***READ part******
    ******************/
    localparam SISCOMING = 1'b0;
    localparam TISCOMING = 1'b1;
    

    localparam READCOMPLETE = 2'b11;
    localparam STANDBY = 2'b00;
    localparam READS = 2'b01;
    localparam READT = 2'b10;

    reg     [12:0] iter_readS, n_iter_readS;
    reg     [12:0] iter_readT, n_iter_readT;
    reg     [7:0] dataintoramS, n_dataintoramS;
    reg     [7:0] dataintoramT, n_dataintoramT;
    
    /*****************
    ***READ part end**
    ******************/
    /*****************
    *** SLOAD part ***
    ******************/
    reg     s_load;
    reg     s_valid;
    reg     [12:0] iter_Shasload, n_iter_Shasload;

    wire    wire_s_load;
    wire    wire_s_valid;
    wire    [1:0] wire_io_s_in;
    wire    [12:0] wire_state_SLOAD_needs_cycle;

    assign  wire_state_SLOAD_needs_cycle = iter_readS[5:0] == 6'd0 ? iter_readS : {iter_readS[12:6] + 1, 6'd0}; 
    //assign  wire_s_load_last_set = (iter_Shasload[12:6] == (iter_readS - 1)[12:6]) | (iter_Shasload == iter_readS); // test if this is the last set
    //WRONG assign  wire_s_load_last_set = iter_Shasload[12:6] == wire_Sneedscountsiter; // test if this is the last set
    assign  wire_s_load = s_load;
    assign  wire_s_valid = s_valid;
    assign  wire_io_s_in = Sin_reg[1:0];

    /*****************
    **SLOAD part end**
    ******************/
    /*****************
    *** TCALCU part ***
    ******************/
    reg     ripple_en_in, n_ripple_en_in;
    reg     [12:0] iter_Thasload, n_iter_Thasload;
    reg     [12:0] iter_VFhasreceived, n_iter_VFhasreceived;
    reg     [12:0] iter_cyclelapse, n_iter_cyclelapse;


    wire    [10:0] wire_T_last_set;
    wire    wire_ripple_en_in;
    wire    wire_ripple_en_out;
    wire    [1:0] wire_io_t_in;
    wire    [15:0] wire_io_v_in;
    wire    [15:0] wire_io_v_alpha_in;
    wire    [15:0] wire_io_f_in;
    wire    [15:0] wire_io_v_out;
    wire    [15:0] wire_io_f_out;
    wire    [12:0] wire_state_TCALCU_needs_cycle;

    assign  wire_T_last_set = iter_readT[1:0] == 2'b00 ? iter_readT[12:2] - 1 : iter_readT[12:2];
    assign  wire_state_TCALCU_needs_cycle = iter_readT[1:0] == 2'b00 ? iter_readT + 64 - 1  : {iter_readT[12:2] + 1 , 2'b00} + 64 - 1;
    assign  wire_ripple_en_in = ripple_en_in;
    assign  wire_io_t_in = Tin_reg[1:0];
    assign  wire_io_v_in = VFin_reg[15:0];
    assign  wire_io_v_alpha_in = VFin_reg[15:0] > `ALPHA ? VFin_reg[15:0] - `ALPHA : 0;
    assign  wire_io_f_in = VFin_reg[31:16];




    /*****************
    * TCALCU part end*
    ******************/
    /*****************
    *** Max part ***
    ******************/
    wire    [15:0] wire_max_value;
    /*****************
    ** Max part end **
    ******************/    
    /*****************
    *** sram IO part ***
    ******************/
    reg    VFsram_CEN, n_VFsram_CEN;
    reg    VFsram_WEN, n_VFsram_WEN;
    reg    [9:0] VFsram_A, n_VFsram_A;
    reg    [127:0] VFsram_D, n_VFsram_D;


    wire    [127:0] wire_VFsram_Q;
    wire    wire_VFsram_CEN;
    wire    wire_VFsram_WEN;
    wire    [9:0] wire_VFsram_A;
    wire    [127:0] wire_VFsram_D;

    assign wire_VFsram_CEN = VFsram_CEN;
    assign wire_VFsram_WEN = VFsram_WEN;
    assign wire_VFsram_A = VFsram_A;
    assign wire_VFsram_D = VFsram_D;

    reg    Ssram_CEN, n_Ssram_CEN;
    reg    Ssram_WEN, n_Ssram_WEN;
    reg    [9:0] Ssram_A, n_Ssram_A;
    reg    [7:0] Ssram_D, n_Ssram_D;


    wire    [7:0] wire_Ssram_Q;
    wire    wire_Ssram_CEN;
    wire    wire_Ssram_WEN;
    wire    [9:0] wire_Ssram_A;
    wire    [7:0] wire_Ssram_D;

    assign wire_Ssram_CEN = Ssram_CEN;
    assign wire_Ssram_WEN = Ssram_WEN;
    assign wire_Ssram_A = Ssram_A;
    assign wire_Ssram_D = Ssram_D;

    reg    Tsram_CEN, n_Tsram_CEN;
    reg    Tsram_WEN, n_Tsram_WEN;
    reg    [9:0] Tsram_A, n_Tsram_A;
    reg    [7:0] Tsram_D, n_Tsram_D;


    wire    [7:0] wire_Tsram_Q;
    wire    wire_Tsram_CEN;
    wire    wire_Tsram_WEN;
    wire    [9:0] wire_Tsram_A;
    wire    [7:0] wire_Tsram_D;

    assign wire_Tsram_CEN = Tsram_CEN;
    assign wire_Tsram_WEN = Tsram_WEN;
    assign wire_Tsram_A = Tsram_A;
    assign wire_Tsram_D = Tsram_D;

    /*****************
    ** sram IO part end **
    ******************/    

    reg     [1:0] state, n_state;
    wire    [1:0] wire_state;
    assign wire_state = state;

    reg     valid, n_valid;
    assign max_result = wire_max_value; 
    





    sram_1024x128_t13 VFm1(.Q(wire_VFsram_Q), .clk(clk), .CEN(1'b0), .WEN(wire_VFsram_WEN), .A(wire_VFsram_A), .D(wire_VFsram_D));
    sram_1024x8_t13 Sm2(.Q(wire_Ssram_Q), .CLK(clk), .CEN(1'b0), .WEN(wire_Ssram_WEN), .A(wire_Ssram_A), .D(wire_Ssram_D));
    sram_1024x8_t13 Tm3(.Q(wire_Tsram_Q), .CLK(clk), .CEN(1'b0), .WEN(wire_Tsram_WEN), .A(wire_Tsram_A), .D(wire_Tsram_D));    
    SW_PE_ARRAY m4(.clk(clk), .rst(rst), .ripple_en_in(wire_ripple_en_in), .S_load(wire_s_load), .S_valid(wire_s_valid), .S_in(wire_io_s_in), .T_in(wire_io_t_in), .max_in(16'd0), .V_in(wire_io_v_in), .V_alpha(wire_io_v_alpha_in), .F_in(wire_io_f_in), .ripple_en_out(wire_ripple_en_out), .max_out(wire_max_value), .V_out(wire_io_v_out), .F_out(wire_io_f_out));
    
// STATE TRANSITION
always@(*) begin
    case(state)
        READ: begin
            if(Read_en == READCOMPLETE) n_state = SLOAD;
            else n_state = READ;
        end
        SLOAD: begin
            if(iter_Shasload[5:0] == 6'd63) n_state = TCALCU;
            else n_state = SLOAD;
        end
        TCALCU: begin
            if(wire_state_TCALCU_needs_cycle == iter_cyclelapse) begin
                if(wire_state_SLOAD_needs_cycle == iter_Shasload) n_state = TERMIN;
                else n_state = SLOAD;
            end
            else begin
                n_state = TCALCU;
            end
        end
        TERMIN: n_state = TERMIN;
    endcase
end

always@(posedge clk) begin
    if(rst) state <= READ;
    else state <= n_state;
end

// STATE TRANSITION End

// READ Variable control
always@(*) begin
    case(state)
        READ: begin
            n_iter_readS = iter_readS;
            n_iter_readT = iter_readT;            
            case(Read_en)
                STANDBY: begin
                    n_iter_readS = 0;
                    n_iter_readT = 0;
                end
                READS: begin
                    if(iter_readS[1:0] == 2'd0) n_dataintoramS = 8'd0;
                    n_iter_readS = iter_readS + 1;
                end
                READT: begin
                    if(iter_readT[5:0] == 2'd0) n_dataintoramT = 8'd0;
                    n_iter_readT = iter_readT + 1;
                end
                READCOMPLETE: begin
                    n_iter_readS = iter_readS;
                    n_iter_readT = iter_readT;            
                end
            endcase
        end
        default: begin
            n_iter_readS = iter_readS;
            n_iter_readT = iter_readT;            
        end
    endcase
end
always@(posedge clk) begin
    if(rst) begin
        iter_readS <= 0;
        iter_readT <= 0;            
    end
    else begin
        iter_readS <= n_iter_readS;
        iter_readT <= n_iter_readT;            
    end
end
// READ Variable control End

// SLOAD Variable control

always@(*) begin
    case(state)
        SLOAD: begin
            s_load = 1;
            n_iter_Shasload = iter_Shasload + 1;
            if(iter_Shasload >= iter_readS) s_valid = 0;
            else s_valid = 1;
        end
        default: begin
            s_load = 0;
            s_valid = 0;
            n_iter_Shasload = iter_Shasload;
            end
    endcase
end
always@(posedge clk) begin
    if(rst) iter_Shasload <= 0;
    else iter_Shasload <= n_iter_Shasload;
end

// SLOAD Variable control END



// TCALCU Variable control
always@(*) begin
    case (state)
        TCALCU: begin
            n_iter_cyclelapse = iter_cyclelapse + 1;
            n_VFout_reg = VFout_reg;
            if( iter_Thasload == iter_readT ) begin
                ripple_en_in = 0;
                n_iter_Thasload = iter_Thasload;
            end
            else begin
                ripple_en_in = 1;
                n_iter_Thasload = iter_Thasload + 1;
            end
            if( wire_ripple_en_out ) begin
                n_iter_VFhasreceived = iter_VFhasreceived + 1;
                n_VFout_reg[iter_VFhasreceived[1:0] * 32 +: 16] = wire_io_v_out;
                n_VFout_reg[16 + iter_VFhasreceived[1:0] * 32 +: 16] = wire_io_f_out;
            end
            else begin
                n_iter_VFhasreceived = iter_VFhasreceived;
            end
        end
        default: begin
            n_iter_cyclelapse = 0 ;
            n_iter_Thasload = 0;
            n_iter_VFhasreceived = 0;
            ripple_en_in = 0;
            n_VFout_reg = VFout_reg;
        end
    endcase
end

always@(posedge clk) begin
    if (rst) begin
        iter_cyclelapse <= 0;
        iter_Thasload <= 0;
        iter_VFhasreceived <= 0;
        VFout_reg <= 0;
    end
    else begin
        iter_cyclelapse <= n_iter_cyclelapse ;
        iter_Thasload <= n_iter_Thasload;
        iter_VFhasreceived <= n_iter_VFhasreceived;
        VFout_reg <= n_VFout_reg;
    end
end
// TCALCU Variable control END

// MemReg Variable
//// S sram
always@(*) begin
    n_Ssram_CEN = 1;
    n_Ssram_WEN = 1;
    n_Ssram_D = Ssram_D;
    n_Ssram_A = Ssram_A;
    n_Sin_reg = Sin_reg;
    case(state) 
        READ: begin
            if(Read_en == READS) begin
                n_Ssram_CEN = 0;
                n_Ssram_WEN = 0;
                n_Ssram_D[iter_readS[1:0] * 2 +: 2] = data_readin;
                n_Ssram_A = iter_readS[11:2];
            end
            else begin
                n_Ssram_CEN = 1;
                n_Ssram_WEN = 1;
            end
            if(iter_readS <= 4) n_Sin_reg = Ssram_D; 
        end
        SLOAD: begin
            if(iter_Shasload[1:0] == 2'b01) begin
                n_Ssram_CEN = 0;
                n_Ssram_WEN = 1;
                n_Ssram_A = iter_Shasload[11:2] + 1;
            end
            if(iter_Shasload[1:0] == 2'b11) begin
                n_Sin_reg = wire_Ssram_Q;
            end 
            else begin
                n_Sin_reg = Sin_reg >> 2;
            end
        end
        default: begin
            n_Ssram_CEN = 1;
            n_Ssram_WEN = 1;
            n_Ssram_D = Ssram_D;
            n_Ssram_A = Ssram_A;
            n_Sin_reg = Sin_reg;
        end


    endcase

end
always@(posedge clk) begin
    if(rst == 1) begin
        Ssram_CEN <= 1;
        Ssram_WEN <= 1;
        Ssram_D <= 8'd0;
        Ssram_A <= 10'd0;
        Sin_reg <= 8'd0;
    end
    else begin
        Ssram_CEN <= n_Ssram_CEN;
        Ssram_WEN <= n_Ssram_WEN;
        Ssram_D <= n_Ssram_D;
        Ssram_A <= n_Ssram_A;
        Sin_reg <= n_Sin_reg;
    end
end
//// S sram end
//// T sram 
always@(*) begin
    n_Tsram_CEN = 1;
    n_Tsram_WEN = 1;
    n_Tsram_D = Tsram_D;
    n_Tsram_A = Tsram_A;
    n_Tin_reg = Tin_reg;
    case(state) 
        READ: begin
            if(Read_en == READT) begin
                n_Tsram_CEN = 0;
                n_Tsram_WEN = 0;
                n_Tsram_D[iter_readT[1:0] * 2 +: 2] = data_readin;
                n_Tsram_A = iter_readT[11:2];
            end
            else begin
                n_Tsram_CEN = 1;
                n_Tsram_WEN = 1;
            end
            if(iter_readT <= 4) n_Tin_reg = Tsram_D; 
        end
        TCALCU: begin
            if(iter_cyclelapse[1:0] == 2'b01) begin
                n_Tsram_CEN = 0;
                n_Tsram_WEN = 1;
                if(iter_cyclelapse[12:2] < wire_T_last_set) n_Tsram_A = iter_cyclelapse[11:2] + 1;
                else n_Tsram_A = 0;
            end
            if(iter_cyclelapse[12:2] <= wire_T_last_set) begin
                if(iter_cyclelapse[1:0] == 2'b11) n_Tin_reg = wire_Tsram_Q;
                else n_Tin_reg = Tin_reg >> 2;
            end
            else n_Tin_reg = Tin_reg;
        end
        default: begin
            n_Tsram_CEN = 1;
            n_Tsram_WEN = 1;
            n_Tsram_D = Tsram_D;
            n_Tsram_A = Tsram_A;
            n_Tin_reg = Tin_reg;
        end
    endcase
end

always@(posedge clk) begin
    if(rst == 1) begin
        Tsram_CEN <= 1;
        Tsram_WEN <= 1;
        Tsram_D <= 8'd0;
        Tsram_A <= 10'd0;
        Tin_reg <= 8'd0;
    end
    else begin
        Tsram_CEN <= n_Tsram_CEN;
        Tsram_WEN <= n_Tsram_WEN;
        Tsram_D <= n_Tsram_D;
        Tsram_A <= n_Tsram_A;
        Tin_reg <= n_Tin_reg;
    end
end
//// T sram end
//// VF sram
always@(*) begin
    n_VFsram_CEN = 1;
    n_VFsram_WEN = 1;
    n_VFsram_D = VFsram_D;
    n_VFsram_A = VFsram_A;
    n_VFin_reg = VFin_reg;
    case(state)
        READ: begin
            if(Read_en == READT) begin
                n_VFsram_CEN = 0;
                n_VFsram_WEN = 0;
                n_VFsram_D = 0;
                n_VFsram_A = iter_readT[11:2];
            end
            else begin
                n_VFsram_CEN = 1;
                n_VFsram_WEN = 1;
            end
        end
        TCALCU: begin
            if(iter_cyclelapse[1:0] == 2'b00) begin // VFout write in to sram
                if(iter_VFhasreceived != 0) begin
                    n_VFsram_CEN = 0;
                    n_VFsram_WEN = 0;
                    n_VFsram_D = VFout_reg;
                    n_VFsram_A = iter_VFhasreceived[11:2] - 1;
                end
                else begin
                    if(iter_cyclelapse == 0) begin
                        n_VFsram_CEN = 0;
                        n_VFsram_WEN = 0;
                        n_VFsram_D = VFout_reg;
                        n_VFsram_A = wire_T_last_set[9:0];
                    end
                end
            end
            else if (iter_cyclelapse[1:0] == 2'b01) begin // VFin read out from sram
                if(iter_cyclelapse[12:2] < wire_T_last_set) begin 
                    n_VFsram_CEN = 0;
                    n_VFsram_WEN = 1;
                    n_VFsram_A = iter_cyclelapse[12:2] + 1;
                end
                else begin // VFin first group of next S 
                    n_VFsram_CEN = 0;
                    n_VFsram_WEN = 1;
                    n_VFsram_A = 0;
                end
            end
            else begin
                n_VFsram_CEN = 1;
                n_VFsram_WEN = 1;
                n_VFsram_D = 0;
                n_VFsram_A = VFsram_A;

            end
            if(iter_cyclelapse[1:0] == 2'b11) begin
                n_VFin_reg = wire_VFsram_Q;
            end
            else begin
                n_VFin_reg = VFin_reg >> 32;
            end
        end
        default: begin
            n_VFsram_CEN = 1;
            n_VFsram_WEN = 1;
            n_VFsram_D = VFsram_D;
            n_VFsram_A = VFsram_A;
            n_VFin_reg = VFin_reg;
        end
    endcase

end

always@(posedge clk) begin
    if(rst == 1) begin
        VFsram_CEN <= 1;
        VFsram_WEN <= 1;
        VFsram_D <= 8'd0;
        VFsram_A <= 10'd0;
        VFin_reg <= 8'd0;
    end
    else begin
        VFsram_CEN <= n_VFsram_CEN;
        VFsram_WEN <= n_VFsram_WEN;
        VFsram_D <= n_VFsram_D;
        VFsram_A <= n_VFsram_A;
        VFin_reg <= n_VFin_reg;
    end
end
//// VF sram end
// MemReg Variable end

// Valid or not
always@(*) begin
    if(state == TERMIN) n_valid = 1;
    else n_valid = 0;
end
always@(posedge clk) begin
    if(rst) valid <= 0;
    else valid <= n_valid;
end

endmodule






