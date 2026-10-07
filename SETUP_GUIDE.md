# Congestion-Aware Adaptive Lossless Compression Engine for NoC/Memory Links
## Complete Setup and Build Guide for Vivado 2024.2

### Project Overview

This Verilog RTL implementation provides a sophisticated memory compression engine designed for NoC (Network-on-Chip) and memory link optimization. The engine features:

- **Multi-Mode Compression**: BYPASS, DELTA, RLE (Run-Length Encoding), and DICTIONARY modes
- **Adaptive Mode Selection**: Intelligent mode prediction based on data features and congestion levels
- **Feature Extraction**: Real-time analysis of zero-word counts and delta widths
- **Congestion Monitoring**: Dynamic backpressure and credit-based flow control
- **Vivado 2024.2 Ready**: Fully synthesizable for Xilinx Artix-7 FPGA (Nexys A7-100T)

---

## Directory Structure

```
.
├── rtl/                          # RTL Verilog modules
│   ├── feature_extractor.v       # Feature extraction pipeline
│   ├── mode_predictor_fsm.v      # Mode selection FSM
│   ├── unified_compression_core.v # Multi-mode compression logic
│   ├── tx_output_buffer.v        # TX packet buffering
│   ├── rx_input_depacketizer.v   # RX depacketizer
│   ├── congestion_monitor.v      # Congestion tracking
│   ├── flow_control_credit_mgr.v # Credit-based flow control
│   ├── global_clock_gate_controller.v # Clock gating
│   ├── noc_compression_engine.v  # Main compression engine
│   └── nexys_a7_wrapper.v        # Board-level wrapper
├── sim/                          # Simulation
│   └── tb_noc_compression_engine.v # Testbench
├── constraints/                  # FPGA constraints
│   └── nexys_a7_100t.xdc        # Nexys A7-100T pin constraints
├── vivado/                       # Vivado project scripts
│   └── create_vivado_project.tcl # Project generation script
├── README.md                     # Project README
└── SETUP_GUIDE.md               # This file
```

---

## Prerequisites

1. **Vivado 2024.2** installed and available in PATH
2. **Nexys A7-100T** development board (Artix-7 XC7A100TCSG324-1)
3. **USB cable** for board programming
4. **Digilent JTAG drivers** (if not already installed)

---

## Quick Start: Step-by-Step Build Process

### Step 1: Clone/Download the Repository

```bash
cd ~/your_project_directory
git clone https://github.com/vrnavenkumar/memory-compression-controller.git
cd memory-compression-controller
git checkout nexys-a7
```

Or download the ZIP:
```
https://github.com/vrnavenkumar/memory-compression-controller/archive/refs/heads/nexys-a7.zip
```

### Step 2: Create Vivado Project Using TCL Script

Open a terminal and navigate to the project root:

```bash
cd /path/to/memory-compression-controller
vivado -mode batch -source vivado/create_vivado_project.tcl
```

Or manually in Vivado GUI:

1. Open Vivado 2024.2
2. In the Tcl console, run:
   ```tcl
   source ./vivado/create_vivado_project.tcl
   ```
3. Wait for project creation to complete

### Step 3: Verify RTL Sources

In Vivado:

1. Expand **Sources** panel on the left
2. Verify all RTL files are present:
   - feature_extractor.v
   - mode_predictor_fsm.v
   - unified_compression_core.v
   - tx_output_buffer.v
   - rx_input_depacketizer.v
   - congestion_monitor.v
   - flow_control_credit_mgr.v
   - global_clock_gate_controller.v
   - noc_compression_engine.v
   - nexys_a7_wrapper.v (top module)

3. Verify constraints file:
   - constraints/nexys_a7_100t.xdc

### Step 4: Run Simulation (Optional)

Before synthesis, test the design in simulation:

1. In Vivado, go to **Simulation > Run Behavioral Simulation**
2. The testbench will run for ~200 ns
3. Verify the output in the waveform viewer
4. Expected behavior:
   - Compression modes cycle based on input data patterns
   - Congestion counter increments
   - Valid signals pulse appropriately

### Step 5: Run Synthesis

1. In Vivado, click **Flow > Run Synthesis**
2. Accept all dialogs
3. Wait for synthesis to complete (typically 2-5 minutes)
4. Review synthesis report for any warnings
5. Click **Open Synthesized Design** to review the netlist (optional)

### Step 6: Run Implementation

1. In Vivado, click **Flow > Run Implementation**
2. Accept all dialogs
3. Wait for implementation to complete (typically 3-10 minutes)
4. Review implementation report
5. Verify timing constraints are met

### Step 7: Generate Bitstream

1. In Vivado, click **Flow > Generate Bitstream**
2. Accept all dialogs
3. Wait for bitstream generation (typically 1-2 minutes)
4. Once complete, bitstream will be saved to:
   ```
   vivado_project/noc_compression_nexys_a7.runs/impl_1/nexys_a7_wrapper.bit
   ```

### Step 8: Program the FPGA Board

#### Option A: Using Vivado Hardware Manager

1. Connect Nexys A7-100T board via USB
2. In Vivado, go to **Tools > Open Hardware Manager**
3. Click **Open Target > Auto Connect**
4. Right-click the detected device and select **Program Device**
5. Select the generated bitstream (.bit file)
6. Click **Program**
7. Wait for programming to complete (~5-10 seconds)

#### Option B: Using Command Line

```bash
vivado -mode batch -notrace <<EOF
open_hw_manager
connect_hw_server -url localhost:3121
open_hw_target
set_property PROGRAM.FILE {vivado_project/noc_compression_nexys_a7.runs/impl_1/nexys_a7_wrapper.bit} [get_hw_devices xc7a100t_0]
program_hw_devices [get_hw_devices xc7a100t_0]
EOF
```

---

## Functionality After Programming

Once the bitstream is programmed:

### LEDs Display
- **LED[1:0]**: Selected compression mode (binary)
  - 00 = BYPASS
  - 01 = DELTA
  - 10 = RLE
  - 11 = DICTIONARY
- **LED[2]**: Compression valid flag
- **LED[3]**: Decompression valid flag
- **LED[15:4]**: Congestion counter (12-bit)

### Input Switches
- Not actively used in this demo (reserved for future expansion)

### Operation
The design generates test data internally:
- Continuously feeds 512-bit data words
- Mode predictor analyzes features
- Data is compressed and transmitted
- LEDs reflect real-time compression status

---

## Troubleshooting

### Issue: "File not found" during project creation

**Solution**: Ensure all RTL files are in the `rtl/` directory. Check file permissions.

### Issue: Synthesis fails with timing errors

**Solution**: 
- Increase clock period in constraints (currently 10 ns = 100 MHz)
- Reduce data width or pipeline depth
- Run placement and routing again

### Issue: Device cannot be detected

**Solution**:
- Install Digilent JTAG drivers
- Check USB cable connection
- Verify Nexys A7 board power is on
- Try using Vivado Hardware Manager GUI instead of CLI

### Issue: Bitstream generation fails

**Solution**:
- Check implementation report for unmet timing
- Verify all design constraints are correct
- Try a clean rebuild (Flow > Clean, then re-run)

---

## Design Architecture Summary

### TX Pipeline (Compression)
1. **Feature Extractor**: Analyzes incoming 512-bit data
   - Counts zero words
   - Calculates max delta width
2. **Mode Predictor FSM**: Selects best compression mode
3. **Unified Compression Core**: Applies selected compression
4. **TX Output Buffer**: Packages compressed data

### RX Pipeline (Decompression)
1. **RX Depacketizer**: Unpacks received 128-bit packets
2. (Decompression logic can be extended)

### System Control
- **Congestion Monitor**: Tracks backpressure and credit status
- **Flow Control**: Manages credit-based transmission
- **Clock Gating**: Power optimization via enable signal
- **APB Register File**: Configuration and monitoring (address space 0x00-0x10)

---

## APB Register Map (Optional)

The design includes a simple APB control interface:

| Address | Register | Description |
|---------|----------|-------------|
| 0x00 | CFG_THRESHOLD | Congestion threshold for mode selection |
| 0x04 | CFG_WINDOW | Credit window limit |
| 0x08 | CFG_MODE | Manual mode override |
| 0x0C | CFG_ENABLE | Global enable/disable |
| 0x10 | CFG_IRQ_ENABLE | Interrupt enable |

---

## Performance Specifications

- **Clock Frequency**: 100 MHz (10 ns period)
- **Input Data Width**: 512 bits
- **Compressed Output Width**: 128 bits
- **Compression Modes**: 4 (BYPASS, DELTA, RLE, DICTIONARY)
- **FPGA Device**: Xilinx Artix-7 XC7A100T
- **Board**: Nexys A7-100T

---

## Next Steps for Enhancement

1. **Integrate with AXI4-Stream Interface**: Connect to real system bus
2. **Add BRAM for buffering**: Implement deeper FIFO stages
3. **Implement full decompression**: Add reverse logic for all modes
4. **Add UART monitoring**: Real-time statistics logging
5. **Optimize compression ratio**: Tune mode selection heuristics
6. **Add packet formatting**: Header/footer and error detection (CRC)

---

## References

- [Vivado 2024.2 Documentation](https://docs.xilinx.com/)
- [Nexys A7-100T Reference Manual](https://reference.digilentinc.com/reference/boards/nexys-a7/start)
- [Artix-7 FPGA Datasheet](https://www.xilinx.com/)

---

## Support

For questions or issues:
1. Check this SETUP_GUIDE.md
2. Review the testbench: `sim/tb_noc_compression_engine.v`
3. Inspect the RTL modules for inline comments
4. Visit Digilent or Xilinx forums for board/tool-specific support

---

**Last Updated**: 2026-10-07  
**Vivado Version**: 2024.2  
**Target Board**: Nexys A7-100T (Artix-7 XC7A100T)
