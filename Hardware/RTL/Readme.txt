There following files are in the same folder of this "Readme.txt"

SW_Control_v3_tb.v		: Testbench for RTL and gate-level stage
SW_Control_v3.v		: Top module
SW_PE_opt_Design_v2.v	: PE (processing element) and PE array
sram_1024x128_t13.v	: The 16 parallel srams
sram_1024x8_t13.v		: single sram

## To invoke the simulation, the "in_pattern" and "out_golden.pattern" from software  must be put in this folder.

Use the following command to invoke simulation:
ncverilog SW_Control_v3_tb.v sram_1024x8_t13.v +access+r +notimingcheck

