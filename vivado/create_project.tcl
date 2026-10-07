create_clock -period 10.000 -name clk [get_ports clk]

set_input_delay -clock clk 1.0 [get_ports data_in[*]]
set_input_delay -clock clk 1.0 [get_ports app_hint[*]]
set_input_delay -clock clk 1.0 [get_ports valid_in]
set_input_delay -clock clk 1.0 [get_ports rst]

set_output_delay -clock clk 1.0 [get_ports compressed_data_out[*]]
set_output_delay -clock clk 1.0 [get_ports selected_mode[*]]
set_output_delay -clock clk 1.0 [get_ports decompressed_data_out[*]]
set_output_delay -clock clk 1.0 [get_ports compressed_valid]
set_output_delay -clock clk 1.0 [get_ports decompressed_valid]
