# 16-bit RISC CPU (MIPS-based)

This project implements a **16-bit single-cycle RISC CPU** inspired by the MIPS architecture.  
The processor is designed using **Verilog HDL** and supports arithmetic, logic, memory access, branch/jump instructions, and FP16 floating-point operations.

## Requirements

- Verilog HDL
- Xilinx Vivado

## Usage

1. Open the project in **Xilinx Vivado**.
2. Add all Verilog source files to the project.
3. Ensure the instruction memory file `program.mem` is included.
4. Run **Behavioral Simulation** in Vivado.
5. Observe the waveform results to verify CPU execution.

## Main Components

- Program Counter (PC)
- Instruction Memory
- Control Unit
- Register File
- ALU & ALU Control
- Data Memory
- Branch / Jump Logic

The CPU follows a **single-cycle architecture**, where each instruction completes in a single clock cycle.

## Authors

- Phạm Đình Phong - 2312628  
- Chu Quang Trường - 2313698  
