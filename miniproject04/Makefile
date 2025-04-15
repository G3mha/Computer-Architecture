# Main Makefile for RISC-V Processor Project

# Default target
.PHONY: all
all: build test

# Variables
SRC_DIR     := src
TB_DIR      := tb
TESTS_DIR   := tests
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
	$(NEXTPNR) --up5k --package sg48 --json $< --pcf $(PCF_FILE) --asc $@

$(BUILD_DIR)/$(FPGA_TOP).bin: $(BUILD_DIR)/$(FPGA_TOP).asc
	$(ICEPACK) $< $@

# -----------------------------------------------
# Program FPGA
# -----------------------------------------------
.PHONY: prog
prog: $(BUILD_DIR)/$(FPGA_TOP).bin
	$(DFU_UTIL) --device 1d50:6146 --alt 0 -D $< -R

# -----------------------------------------------
# Traditional simulation with iverilog
# -----------------------------------------------
.PHONY: sim
sim: $(SIM_DIR)/tb.vcd

$(SIM_DIR)/tb.vcd: $(SIM_DIR)/tb.vvp
	$(VVP) $< -fst

$(SIM_DIR)/tb.vvp: $(SRC_DIR)/top.sv $(TB_DIR)/tb.sv
	@mkdir -p $(SIM_DIR)
	$(IVERILOG) -g2012 -o $@ $(TB_DIR)/tb.sv

.PHONY: wave
wave: $(SIM_DIR)/tb.vcd
	$(GTKWAVE) $< &

# -----------------------------------------------
# cocotb testing
# -----------------------------------------------
.PHONY: cocotb
cocotb:
	$(MAKE) -C $(TESTS_DIR) SIM=icarus

# Run all tests
.PHONY: test
test: sim cocotb

# -----------------------------------------------
# Clean up
# -----------------------------------------------
.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)/* $(SIM_DIR)/*
	$(MAKE) -C $(TESTS_DIR) clean SIM=icarus

.PHONY: clean_all
clean_all: clean
	rm -rf __pycache__ *.pyc
