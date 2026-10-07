#!/usr/bin/env tclsh
## Vivado 2024.2 Project Creation Script for Nexys A7-100T
## Congestion-Aware Adaptive Lossless Compression Engine for NoC/Memory Links

set project_name "noc_compression_nexys_a7"
set project_dir  "./vivado_project"
set part_name    "xc7a100tcsg324-1"
set board_name   "digilentinc.com:nexys-a7-100t:part0:1.2"

puts "Creating Vivado 2024.2 project: $project_name"
puts "Target FPGA: $part_name"
puts "Board: Nexys A7-100T"

# Create project
create_project -force $project_name $project_dir -part $part_name

# Set board (optional, for reference)
if {[catch {set_property board_part $board_name [current_project]} err]} {
    puts "Warning: Could not set board part - proceeding without it"
}

# Add RTL source files
set rtl_files {
    "./rtl/feature_extractor.v"
    "./rtl/mode_predictor_fsm.v"
    "./rtl/unified_compression_core.v"
    "./rtl/tx_output_buffer.v"
    "./rtl/rx_input_depacketizer.v"
    "./rtl/congestion_monitor.v"
    "./rtl/flow_control_credit_mgr.v"
    "./rtl/global_clock_gate_controller.v"
    "./rtl/noc_compression_engine.v"
    "./rtl/nexys_a7_wrapper.v"
}

foreach rtl_file $rtl_files {
    if {[file exists $rtl_file]} {
        add_files -norecurse $rtl_file
        puts "Added: $rtl_file"
    } else {
        puts "Warning: $rtl_file not found"
    }
}

# Add constraint file
if {[file exists "./constraints/nexys_a7_100t.xdc"]} {
    add_files -fileset constrs_1 -norecurse "./constraints/nexys_a7_100t.xdc"
    puts "Added constraints: ./constraints/nexys_a7_100t.xdc"
} else {
    puts "Warning: Constraint file not found"
}

# Add simulation testbench
if {[file exists "./sim/tb_noc_compression_engine.v"]} {
    add_files -fileset sim_1 -norecurse "./sim/tb_noc_compression_engine.v"
    set_property top tb_noc_compression_engine [get_filesets sim_1]
    puts "Added testbench: ./sim/tb_noc_compression_engine.v"
} else {
    puts "Warning: Testbench file not found"
}

# Set top module
set_property top nexys_a7_wrapper [current_fileset]

# Update compile order
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# Save project
save_project_as -force $project_name $project_dir

puts "\n=== Vivado Project Created Successfully ==="
puts "Project name: $project_name"
puts "Project directory: $project_dir"
puts "Top module: nexys_a7_wrapper"
puts "\nNext steps:"
puts "1. Open Vivado and load this project"
puts "2. Run Synthesis (Tools > Synthesis)"
puts "3. Run Implementation (Tools > Implementation)"
puts "4. Generate Bitstream (Tools > Generate Bitstream)"
puts "5. Program the Nexys A7-100T board"
puts "\nSimulation:"
puts "Run -> Run Simulation -> Run Behavioral Simulation"
puts "================================================"
