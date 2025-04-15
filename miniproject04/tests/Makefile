# Makefile for cocotb tests
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# Explicitly set Python path
PYTHON_BIN ?= $(shell which python3)
export PYTHONPATH := $(shell cocotb-config --share):$(PYTHONPATH)

VERILOG_INCLUDE_DIRS = $(shell pwd)/../src

# Design settings
VERILOG_SOURCES = $(shell find ../src -name "*.sv" -type f)
TOPLEVEL = top
MODULE = test_cpu

# Include cocotb's makefile directly with path
include $(shell cocotb-config --makefiles)/Makefile.sim

# Clean extended
clean::
	@rm -rf __pycache__
	@rm -rf *.vcd
	@rm -rf results.xml
	@rm -rf sim_build
