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
.PHONY: sim_alu
sim_alu: tb/alu_tb.sv src/cpu/alu.sv
	iverilog -g2012 -o sim/alu_tb.vvp $^
	vvp sim/alu_tb.vvp

$(SIM_DIR)/alu_tb.vvp: $(TB_DIR)/tb_alu.sv $(SRC_DIR)/cpu/alu.sv
	@if not exist $(SIM_DIR) mkdir $(SIM_DIR)
	$(IVERILOG) -g2012 -I$(SRC_DIR) -o $@ $(TB_DIR)/tb_alu.sv $(SRC_DIR)/cpu/alu.sv

.PHONY: sim_imm_gen
sim_imm_gen: tb/imm_gen_tb.sv src/cpu/imm_gen.sv
	@if not exist $(SIM_DIR) mkdir $(SIM_DIR)
	$(IVERILOG) -g2012 -o $(SIM_DIR)/imm_gen_tb.vvp $^
	$(VVP) $(SIM_DIR)/imm_gen_tb.vvp

$(SIM_DIR)/imm_gen_tb.vvp: $(TB_DIR)/imm_gen_tb.sv $(SRC_DIR)/cpu/imm_gen.sv
	@if not exist $(SIM_DIR) mkdir $(SIM_DIR)
	$(IVERILOG) -g2012 -I$(SRC_DIR) -o $@ $(TB_DIR)/imm_gen_tb.sv $(SRC_DIR)/cpu/imm_gen.sv

.PHONY: sim_register_file
sim_register_file: tb/register_file_tb.sv src/cpu/register_file.sv
	@if not exist $(SIM_DIR) mkdir $(SIM_DIR)
	$(IVERILOG) -g2012 -o $(SIM_DIR)/register_file_tb.vvp $^
	$(VVP) $(SIM_DIR)/register_file_tb.vvp

$(SIM_DIR)/register_file_tb.vvp: $(TB_DIR)/register_file_tb.sv $(SRC_DIR)/cpu/register_file.sv
	@if not exist $(SIM_DIR) mkdir $(SIM_DIR)
	$(IVERILOG) -g2012 -I$(SRC_DIR) -o $@ $(TB_DIR)/register_file_tb.sv $(SRC_DIR)/cpu/register_file.sv

.PHONY: sim_instruction_decoder
sim_instruction_decoder: tb/instruction_decoder_tb.sv src/cpu/instruction_decoder.sv
	@if not exist $(SIM_DIR) mkdir $(SIM_DIR)
	$(IVERILOG) -g2012 -o $(SIM_DIR)/instruction_decoder_tb.vvp $^
	$(VVP) $(SIM_DIR)/instruction_decoder_tb.vvp

.PHONY: sim_r_type
sim_r_type: tb/r_type_tb.sv $(SV_FILES)
	@if not exist $(SIM_DIR) mkdir $(SIM_DIR)
	$(IVERILOG) -g2012 -I$(SRC_DIR) -o $(SIM_DIR)/r_type_tb.vvp $^
	$(VVP) $(SIM_DIR)/r_type_tb.vvp

.PHONY: sim_i_type
sim_i_type: tb/i_type_tb.sv $(SV_FILES)
	@if not exist $(SIM_DIR) mkdir $(SIM_DIR)
	$(IVERILOG) -g2012 -I$(SRC_DIR) -o $(SIM_DIR)/i_type_tb.vvp $^
	$(VVP) $(SIM_DIR)/i_type_tb.vvp

.PHONY: sim_s_type
sim_s_type: tb/s_type_tb.sv $(SV_FILES)
	@if not exist $(SIM_DIR) mkdir $(SIM_DIR)
	$(IVERILOG) -g2012 -I$(SRC_DIR) -o $(SIM_DIR)/s_type_tb.vvp $^
	$(VVP) $(SIM_DIR)/s_type_tb.vvp

.PHONY: sim_b_type
sim_b_type: tb/b_type_tb.sv $(SV_FILES)
	@if not exist $(SIM_DIR) mkdir $(SIM_DIR)
	$(IVERILOG) -g2012 -I$(SRC_DIR) -o $(SIM_DIR)/b_type_tb.vvp $^
	$(VVP) $(SIM_DIR)/b_type_tb.vvp

.PHONY: sim_u_type
sim_u_type: tb/u_type_tb.sv $(SV_FILES)
	@if not exist $(SIM_DIR) mkdir $(SIM_DIR)
	$(IVERILOG) -g2012 -I$(SRC_DIR) -o $(SIM_DIR)/u_type_tb.vvp $^
	$(VVP) $(SIM_DIR)/u_type_tb.vvp

.PHONY: sim_j_type
sim_j_type: tb/j_type_tb.sv $(SV_FILES)
	@if not exist $(SIM_DIR) mkdir $(SIM_DIR)
	$(IVERILOG) -g2012 -I$(SRC_DIR) -o $(SIM_DIR)/j_type_tb.vvp $^
	$(VVP) $(SIM_DIR)/j_type_tb.vvp

.PHONY: wave_alu
wave_alu: $(SIM_DIR)/alu_tb.vcd
	$(GTKWAVE) $< &

.PHONY: wave_imm_gen
wave_imm_gen: $(SIM_DIR)/imm_gen_tb.vcd
	$(GTKWAVE) $< &

.PHONY: wave_register_file
wave_register_file: $(SIM_DIR)/register_file_tb.vcd
	$(GTKWAVE) $< &

.PHONY: wave_r_type
wave_r_type: $(SIM_DIR)/r_type_tb.vcd
	$(GTKWAVE) $< &

.PHONY: wave_i_type
wave_i_type: $(SIM_DIR)/i_type_tb.vcd
	$(GTKWAVE) $< &

.PHONY: wave_s_type
wave_s_type: $(SIM_DIR)/s_type_tb.vcd
	$(GTKWAVE) $< &

.PHONY: wave_b_type
wave_b_type: $(SIM_DIR)/b_type_tb.vcd
	$(GTKWAVE) $< &

.PHONY: wave_u_type
wave_u_type: $(SIM_DIR)/u_type_tb.vcd
	$(GTKWAVE) $< &

.PHONY: wave_j_type
wave_j_type: $(SIM_DIR)/j_type_tb.vcd
	$(GTKWAVE) $< &

# Run all instruction type tests
.PHONY: sim_instructions_tests
sim_instructions_tests: sim_r_type sim_i_type sim_s_type sim_b_type sim_u_type sim_j_type
	@echo "All instruction type tests completed!"

# Update the main test target to include instruction tests
.PHONY: test
test: sim_alu sim_imm_gen sim_register_file sim_instruction_decoder sim_instructions_tests
	@echo "All tests passed!"

# -----------------------------------------------
# Clean up
# -----------------------------------------------
.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)/* $(SIM_DIR)/*

.PHONY: clean_all
clean_all: clean
	rm -rf __pycache__ *.pyc
