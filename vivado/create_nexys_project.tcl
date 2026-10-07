# Vivado 2024.2 project creation script for Nexys A7-100T

set project_name "memory_compression_nexys_a7"
set project_dir  "./vivado/build"
set repo_root    "."

create_project -force $project_name $project_dir -part xc7a100tcsg324-1
set_property board_part digilentinc.com:nexys-a7-100t:part0:1.2 [current_project]

# Add RTL sources
auto_import_files -files [list \
    "$repo_root/rtl/mode_selector.v" \
    "$repo_root/rtl/delta_compressor.v" \
    "$repo_root/rtl/rle_compressor.v" \
    "$repo_root/rtl/dictionary_compressor.v" \
    "$repo_root/rtl/memory_compression_decompressor.v" \
    "$repo_root/rtl/memory_compression_top.v" \
    "$repo_root/rtl/nexys_a7_top.v"]

# Add constraints
add_files -fileset constrs_1 -norecurse "$repo_root/constraints/nexys_a7_100t.xdc"

# Set top module
set_property top nexys_a7_top [current_fileset]

# Optional: create a simulation file
# add_files -fileset sim_1 -norecurse "$repo_root/sim/memory_compression_tb.v"
# set_property top memory_compression_tb [get_filesets sim_1]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "Nexys A7-100T project created successfully."
puts "Open Vivado and run synthesis / implementation."
