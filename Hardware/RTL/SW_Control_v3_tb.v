`timescale 1ns/1ps
`define CYCLE  5.0
`define HCYCLE  2.5
`define INFILE "in.pattern"
`define OUTFILE "out_golden.pattern"
`define PATTERNNUM 142
`define TERMINCYCLE 200000

`define SDFFILE    "SW_Control_v3_SYN.sdf"    // Modify your sdf file name here



module SW_tb;
    reg clk, rst;
    reg [1:0] Read_en, data_readin;
    wire valid;
    wire [15:0] max_result;
    integer   fp_given, fp_ans, dumb, cnt, correct, i, cycle_cnt, cycle_start;

    `ifdef SDF
    initial $sdf_annotate(`SDFFILE, m1);
    `endif


    reg  [1:0] data_Read_en [0:(`PATTERNNUM) - 1];
    reg  [1:0] data_data_readin [0:(`PATTERNNUM) - 1];
    reg  [15:0] data_max_result;
    
    // instantiate the design-under-test
    SW_Control_v3 m1 ( clk, rst, Read_en, data_readin, valid, max_result);

    // Dump fsdb file
    initial begin 
        $fsdbDumpfile("sw.fsdb");
        $fsdbDumpvars(0, "+mda");
    end

    // Read in/out pattern
    initial begin
        fp_given = $fopen(`INFILE , "r");
        fp_ans = $fopen(`OUTFILE , "r");

        cnt = 0;
        while(!$feof(fp_given)) begin
            dumb = $fscanf(fp_given, "%b %b", data_Read_en[cnt], data_data_readin[cnt]);
            cnt = cnt + 1;
        end

        while(!$feof(fp_ans)) begin
            dumb = $fscanf(fp_ans, "%b", data_max_result);
        end
        $fclose(fp_given);
        $fclose(fp_ans);
    end

    // clk 

    initial begin
        clk = 1'b0;
    end
    always begin
        #(`HCYCLE) clk = ~clk;

    end

    always begin
        #(`CYCLE) cycle_cnt = cycle_cnt + 1;
    end

    // always begin
    //     if(Read_en === 2'b11) cycle_start = cycle_cnt;
    // end

    initial begin
        cycle_cnt = 0;
        rst = 1'b1;
        //Read_en = 2'd0;
        data_readin = 2'd0;
        #(`CYCLE * 3) rst = 1'b0;
        correct = 1'b0;
        for( i = 0; i < (`PATTERNNUM); i = i + 1 ) begin
            @(posedge clk) begin
            data_readin = data_data_readin[i];
            Read_en = data_Read_en[i];
            end
        end
        //$monitor("=== cycle_cnt = %d", cycle_cnt);
        //$monitor("max_result: %d", max_result);

        wait( valid );
            $display("data_max_result: %d", data_max_result);
            $display("max_result: %d", max_result);
            $display("cycle end: %d", cycle_cnt );
        if( data_max_result == max_result) begin
            $display("============================================================================");
            $display("\n");
            $display("        ****************************              ");
            $display("        **                        **        /|__/|");
            $display("        **  Congratulations !!    **      / O,O  |");
            $display("        **                        **    /_____   |");
            $display("        **  Simulation Complete!! **   /^ ^ ^ \\  |");
            $display("        **                        **  |^ ^ ^ ^ |w|");
            $display("        *************** ************   \\m___m__|_|");
            $display("\n");
            $display("============================================================================");
            $finish;
        end

        else begin
            $display("============================================================================");
            $display("\n (>_<) ERROR!! Result isn't compatible to answer! Please check your code @@ \n");
            $display("============================================================================");
            $finish;
        end
    end


    initial begin
        #(`TERMINCYCLE);
        $display("================================================================================================================");
        $display("(/`n`)/ ~#  There is something wrong with your code!!"); 
        $display("Time out!! The simulation didn't finish after %d cycles!!, Please check it!!!", `TERMINCYCLE); 
        $display("================================================================================================================");
        $finish;
    end
endmodule