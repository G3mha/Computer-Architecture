# ENGR 3410: RISC-V Single-Cycle Processor
**Due: April 14, 2025**

## Project Overview
In this project, you will design a single-cycle 32-bit RISC-V integer microprocessor with a von Neumann architecture using the OSS CAD suite. The processor will work with:

- A provided memory module implementing 16kB of physical memory at the bottom of the 32-bit address space
- Memory-mapped hardware peripherals accessible through the highest addresses, including:
  - 8-bit PWM generators for the user LED and RGB LEDs on the iceBlinkPico board
  - Two 32-bit timers counting milliseconds and microseconds (mod 2^32) since processor start

Your task is to implement the base RV32I instruction set (with exceptions noted below) capable of running a simple RISC-V assembly program that interacts with the LEDs in an interesting manner.

This is a group project for teams of up to three students. While design approaches can be discussed between groups, each team must complete all aspects without sharing code.

## Requirements

1. Your processor must implement all instructions in the base RV32I instruction set except:
  - `ecall`
  - `ebreak`
  - `csrrw`, `csrrs`, `csrrc`
  - `csrrwi`, `csrrsi`, `csrrci`
  - Atomic read/write instructions

2. Your processor must be specified in one or more SystemVerilog source files.

3. You must provide a SystemVerilog test bench and simulation results using Icarus Verilog (iverilog) verifying proper operation for representative examples of each class of RV32I instructions.

## Deliverables
Due by the start of class on April 14, 2025 via Canvas:

1. A PDF report explaining:
  - Your processor design and operation
  - Simulation results demonstrating proper operation for each class of RV32I instructions

2. Source code files:
  - All SystemVerilog files specifying your circuit
  - Test bench files
  - May be submitted as GitHub repo URL or shared folder link

3. Demo materials:
  - Video showing your processor running a RISC-V assembly program interacting with the LEDs on the iceBlinkPico board
  - Source code for your demo program

## Implementation Notes

- Focus on implementing a functional single-cycle processor where only one instruction is executed at a time
- The von Neumann architecture means there is a single memory containing both code and data
- Pay careful attention to the memory-mapped peripherals which will be used to control the LEDs

## Getting Started

1. Set up the OSS CAD Suite for SystemVerilog development
2. Familiarize yourself with the RISC-V RV32I instruction set
3. Design your processor architecture (datapath and control unit)
4. Implement your design in SystemVerilog
5. Create test benches to verify each instruction type works correctly
6. Develop an assembly program that demonstrates LED interaction
7. Document your design and results for the final report

## Resources

- RISC-V Specification: [riscv.org](https://riscv.org/technical/specifications/)
- Icarus Verilog: [iverilog.icarus.com](http://iverilog.icarus.com/)
- OSS CAD Suite: [github.com/YosysHQ/oss-cad-suite-build](https://github.com/YosysHQ/oss-cad-suite-build)
- Basic Computer Design (Part 1): [John's Basement](https://www.youtube.com/watch?v=6f5Vu5zymog)
- Basic Computer Design (Part 2): [A Simple RISC-V RV32I CPU - John's Basement](https://www.youtube.com/watch?v=zW2Pmki81ow)
- Basic Computer Design (Part 3): [A Simple RISC-V RV32I CPU - John's Basement](https://www.youtube.com/watch?v=xLcdJ33RBo0)
- Designing a RISC-V Single-Cycle Processor: [Step-by-Step Tutorial](https://www.youtube.com/watch?v=dh88oe6O0QU)
- RISC-V Instruction Encoder/Decoder: [LupLab @ University of California, Davis](https://luplab.gitlab.io/rvcodecjs/)
- [RISC-V Assembler and Simulator](https://srki.github.io/RISC-V-Simulator/)
- [John Winans' RISC-V Assembly Language Programming Draft](https://github.com/johnwinans/rvalp/releases/tag/v0.18.3)
- [xPack GNU RISC-V Embedded GCC](https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/tag/v14.2.0-3)
- cocotb: [An Open-Source Co-routine-based Co-simulation Testbench Environment for Verifying SystemVerilog with Python](https://www.cocotb.org/)
