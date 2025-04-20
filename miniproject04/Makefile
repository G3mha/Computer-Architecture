# Main Makefile for RISC-V Processor Project

# Default target
.PHONY: all
all: build test

# Variables
SRC_DIR     := src
TB_DIR      := tb
SIM_DIR     := sim
BUILD_DIR   := build
PROGRAM_DIR := program
INFRA_DIR   := infra

# FPGA variables
FPGA_TOP    := top
PCF_FILE    := $(INFRA_DIR)/iceBlinkPico.pcf

# Simulation variables
IVERILOG    := iverilog
VVP         := vvp
GTKWAVE     := gtkwave

# Synthesis tools
YOSYS       := yosys
NEXTPNR     := nextpnr-ice40
ICEPACK     := icepack
DFU_UTIL    := dfu-util

# Source files
SV_FILES    := $(wildcard $(SRC_DIR)/**/*.sv) $(wildcard $(SRC_DIR)/*.sv)
TB_FILES    := $(wildcard $(TB_DIR)/*.sv)

# -----------------------------------------------
# Build rules
# -----------------------------------------------
.PHONY: build
build: $(BUILD_DIR)/$(FPGA_TOP).bin

$(BUILD_DIR)/$(FPGA_TOP).json:
	@mkdir -p $(BUILD_DIR)
	$(YOSYS) -p "read_verilog -sv $(SRC_DIR)/top.sv; synth_ice40 -top top -json $@"

$(BUILD_DIR)/$(FPGA_TOP).asc: $(BUILD_DIR)/$(FPGA_TOP).json
	$(NEXTPNR) --up5k --package sg48 --json $< --pcf $(PCF_FILE) --pcf-allow-unconstrained --asc $@

$(BUILD_DIR)/$(FPGA_TOP).bin: $(BUILD_DIR)/$(FPGA_TOP).asc
	$(ICEPACK) $< $@

# -----------------------------------------------
# Program FPGA
# -----------------------------------------------
.PHONY: prog
prog: $(BUILD_DIR)/$(FPGA_TOP).bin
	$(DFU_UTIL) --device 1d50:6146 --alt 0 -D $< -R

# -----------------------------------------------
# SystemVerilog Testbenches
# -----------------------------------------------
.PHONY: sim_cpu
sim_cpu: $(SIM_DIR)/cpu_tb.vvp
	$(VVP) $(SIM_DIR)/cpu_tb.vvp

$(SIM_DIR)/cpu_tb.vvp: $(TB_DIR)/tb_riscv_processor.sv $(SV_FILES)
	@mkdir -p $(SIM_DIR)
	$(IVERILOG) -g2012 -o $@ $(TB_DIR)/tb_riscv_processor.sv $(SV_FILES)

.PHONY: sim_alu
sim_alu: tb/alu_tb.sv src/cpu/alu.sv
	iverilog -g2012 -o sim/alu_tb.vvp $^
	vvp sim/alu_tb.vvp

$(SIM_DIR)/alu_tb.vvp: $(TB_DIR)/tb_alu.sv $(SRC_DIR)/cpu/alu.sv
	@mkdir -p $(SIM_DIR)
	$(IVERILOG) -g2012 -I$(SRC_DIR) -o $@ $(TB_DIR)/tb_alu.sv $(SRC_DIR)/cpu/alu.sv

.PHONY: sim_imm_gen
sim_imm_gen: tb/imm_gen_tb.sv src/cpu/imm_gen.sv
	@mkdir -p $(SIM_DIR)
	$(IVERILOG) -g2012 -o $(SIM_DIR)/imm_gen_tb.vvp $^
	$(VVP) $(SIM_DIR)/imm_gen_tb.vvp

$(SIM_DIR)/imm_gen_tb.vvp: $(TB_DIR)/imm_gen_tb.sv $(SRC_DIR)/cpu/imm_gen.sv
	@mkdir -p $(SIM_DIR)
	$(IVERILOG) -g2012 -I$(SRC_DIR) -o $@ $(TB_DIR)/imm_gen_tb.sv $(SRC_DIR)/cpu/imm_gen.sv

.PHONY: sim_register_file
sim_register_file: tb/register_file_tb.sv src/cpu/register_file.sv
	@mkdir -p $(SIM_DIR)
	$(IVERILOG) -g2012 -o $(SIM_DIR)/register_file_tb.vvp $^
	$(VVP) $(SIM_DIR)/register_file_tb.vvp

$(SIM_DIR)/register_file_tb.vvp: $(TB_DIR)/register_file_tb.sv $(SRC_DIR)/cpu/register_file.sv
	@mkdir -p $(SIM_DIR)
	$(IVERILOG) -g2012 -I$(SRC_DIR) -o $@ $(TB_DIR)/register_file_tb.sv $(SRC_DIR)/cpu/register_file.sv

.PHONY: wave_cpu
wave_cpu: $(SIM_DIR)/cpu_tb.vcd
	$(GTKWAVE) $< &

.PHONY: wave_alu
wave_alu: $(SIM_DIR)/alu_tb.vcd
	$(GTKWAVE) $< &

.PHONY: wave_imm_gen
wave_imm_gen: $(SIM_DIR)/imm_gen_tb.vcd
	$(GTKWAVE) $< &

.PHONY: wave_register_file
wave_register_file: $(SIM_DIR)/register_file_tb.vcd
	$(GTKWAVE) $< &

# Run all tests
.PHONY: test
test: sim_cpu sim_alu sim_imm_gen sim_register_file

# -----------------------------------------------
# Clean up
# -----------------------------------------------
.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)/* $(SIM_DIR)/*

.PHONY: clean_all
clean_all: clean
	rm -rf __pycache__ *.pyc
