###################################################################

# Created by write_sdc on Thu Jun 27 02:16:50 2019

###################################################################
set sdc_version 2.0

set_units -time ns -resistance kOhm -capacitance pF -power mW -voltage V       \
-current mA
set_wire_load_mode top
set_wire_load_model -name G5K -library fsa0m_a_generic_core_ss1p62v125c
set_load -pin_load 0.05 [get_ports valid]
set_load -pin_load 0.05 [get_ports {max_result[15]}]
set_load -pin_load 0.05 [get_ports {max_result[14]}]
set_load -pin_load 0.05 [get_ports {max_result[13]}]
set_load -pin_load 0.05 [get_ports {max_result[12]}]
set_load -pin_load 0.05 [get_ports {max_result[11]}]
set_load -pin_load 0.05 [get_ports {max_result[10]}]
set_load -pin_load 0.05 [get_ports {max_result[9]}]
set_load -pin_load 0.05 [get_ports {max_result[8]}]
set_load -pin_load 0.05 [get_ports {max_result[7]}]
set_load -pin_load 0.05 [get_ports {max_result[6]}]
set_load -pin_load 0.05 [get_ports {max_result[5]}]
set_load -pin_load 0.05 [get_ports {max_result[4]}]
set_load -pin_load 0.05 [get_ports {max_result[3]}]
set_load -pin_load 0.05 [get_ports {max_result[2]}]
set_load -pin_load 0.05 [get_ports {max_result[1]}]
set_load -pin_load 0.05 [get_ports {max_result[0]}]
set_ideal_network -no_propagate  [get_ports clk]
create_clock [get_ports clk]  -period 5  -waveform {0 2.5}
set_clock_uncertainty 0.1  [get_clocks clk]
set_input_delay -clock clk  2.5  [get_ports clk]
set_input_delay -clock clk  2.5  [get_ports rst]
set_input_delay -clock clk  2.5  [get_ports {Read_en[1]}]
set_input_delay -clock clk  2.5  [get_ports {Read_en[0]}]
set_input_delay -clock clk  2.5  [get_ports {data_readin[1]}]
set_input_delay -clock clk  2.5  [get_ports {data_readin[0]}]
set_output_delay -clock clk  2.5  [get_ports valid]
set_output_delay -clock clk  2.5  [get_ports {max_result[15]}]
set_output_delay -clock clk  2.5  [get_ports {max_result[14]}]
set_output_delay -clock clk  2.5  [get_ports {max_result[13]}]
set_output_delay -clock clk  2.5  [get_ports {max_result[12]}]
set_output_delay -clock clk  2.5  [get_ports {max_result[11]}]
set_output_delay -clock clk  2.5  [get_ports {max_result[10]}]
set_output_delay -clock clk  2.5  [get_ports {max_result[9]}]
set_output_delay -clock clk  2.5  [get_ports {max_result[8]}]
set_output_delay -clock clk  2.5  [get_ports {max_result[7]}]
set_output_delay -clock clk  2.5  [get_ports {max_result[6]}]
set_output_delay -clock clk  2.5  [get_ports {max_result[5]}]
set_output_delay -clock clk  2.5  [get_ports {max_result[4]}]
set_output_delay -clock clk  2.5  [get_ports {max_result[3]}]
set_output_delay -clock clk  2.5  [get_ports {max_result[2]}]
set_output_delay -clock clk  2.5  [get_ports {max_result[1]}]
set_output_delay -clock clk  2.5  [get_ports {max_result[0]}]
set_drive 1  [get_ports clk]
set_drive 1  [get_ports rst]
set_drive 1  [get_ports {Read_en[1]}]
set_drive 1  [get_ports {Read_en[0]}]
set_drive 1  [get_ports {data_readin[1]}]
set_drive 1  [get_ports {data_readin[0]}]
