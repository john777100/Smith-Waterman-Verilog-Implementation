There following files are in the same folder of this "Readme.txt"

SW_Control_v3_SYN.v	: gate-level stage file
SW_Control_v3_SYN.sdf	: gate-level stage sdf file
SW_Control_v3.timing	: report of synthesis timing (5ns)
SW_Control_v3.area 		: report of synthesis area (1829617)
SW_Control_v3.power	: report of synthesis power (89.687 mW)

## To invoke the simulation, the "in_pattern" and "out_golden.pattern" from software and "SW_Control_v3_tb.v" from Hardware/RTL  must be put in this folder.

Use the following command to invoke simulation:
ncverilog SW_Control_v3_tb.v SW_Control_v3_SYN.v	 sram_1024x8_t13.v tsmc13.v +access+r +define+SDF

