# Application-Aware, Adaptable Multi-Mode Memory Compression Controller

This repository contains a synthesizable Verilog reference design for a memory compression controller targeting Vivado 2024.2. The design supports multiple compression modes and includes a small testbench to validate the logic in the Vivado simulator.

## Project goals

- Lightweight RTL implementation in Verilog
- Application-aware mode selection
- Support for multiple modes:
  - BYPASS
  - DELTA
  - RLE
  - DICTIONARY
- Decompression path for validation
- Vivado 2024.2 project generation support

## Directory structure

- `rtl/` : Verilog RTL modules
- `sim/` : testbench
- `constraints/` : timing constraints
- `vivado/` : Tcl script to create a project

## Files

- `rtl/memory_compression_top.v`
- `rtl/mode_selector.v`
- `rtl/delta_compressor.v`
- `rtl/rle_compressor.v`
- `rtl/dictionary_compressor.v`
- `rtl/memory_compression_decompressor.v`
- `sim/memory_compression_tb.v`
- `constraints/memory_compression.xdc`
- `vivado/create_project.tcl`

## Vivado 2024.2 flow

1. Open Vivado 2024.2.
2. Run `Tools -> Tcl Console`.
3. Change to the repository root.
4. Source the project creation script:

```tcl
source ./vivado/create_project.tcl
```

5. Build the project and run the simulation.

## Notes

This is a reference RTL architecture intended for FPGA prototyping and educational use. It can be adapted to your target board and memory protocol (AXI, AXI-Stream, or custom bus). For a production-quality implementation, you should expand the packet format and integrate the design with your actual memory controller.

## License

This project is provided as a reference design for FPGA and RTL development.
