# Makefile for cocotb tests

# Simulation settings
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# Design settings
VERILOG_SOURCES = $(shell find ../src -name "*.sv" -type f)
TOPLEVEL = top
MODULE = test_cpu

# Include cocotb's makefile
include $(shell cocotb-config --makefiles)/Makefile.sim

# Clean extended
clean::
	@rm -rf __pycache__
	@rm -rf *.vcd
	@rm -rf results.xml
	@rm -rf sim_build
