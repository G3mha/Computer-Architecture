# Makefile for ALU component testing
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# Paths to source files
VERILOG_SOURCES = ../src/cpu/alu.sv
TOPLEVEL = alu
COCOTB_TEST_MODULES = test_alu

# Include cocotb's makefile
include $(shell cocotb-config --makefiles)/Makefile.sim
