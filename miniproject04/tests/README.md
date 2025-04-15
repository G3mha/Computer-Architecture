# cocotb Testing for RISC-V Processor

This directory contains Python-based tests using the [cocotb](https://www.cocotb.org/) framework, which allows writing testbenches in Python.

## Requirements

- Python 3.6+
- cocotb
- Icarus Verilog (for simulation)
- GTKWave (for viewing waveforms)

## Installation

```bash
pip install cocotb pytest
```

## Test Structure

- `test_alu.py`: Tests for the ALU component
- `test_cpu.py`: Integration tests for the full processor
- `conftest.py`: Test configuration and setup

## Running Tests

### Testing the ALU Component

```bash
# From the tests directory
make -f alu_test.mk
```

### Testing the Full Processor

```bash
# From the tests directory
make
```

### Viewing Results

Simulation results are stored in the `sim_build` directory. You can view the waveforms with GTKWave:

```bash
gtkwave sim_build/dump.vcd
```

## Writing New Tests

To create a new test for a component:

1. Create a Python file named `test_component.py`
2. Import cocotb and required libraries
3. Define test functions decorated with `@cocotb.test()`
4. Create a makefile specifying the module to test

Example:

```python
import cocotb
from cocotb.triggers import Timer

@cocotb.test()
async def test_my_component(dut):
    # Set inputs
    dut.input.value = 10
    
    # Wait for combinational logic
    await Timer(1, units="ns")
    
    # Check outputs
    assert dut.output.value == 20, f"Expected 20, got {dut.output.value}"
```

## Test Coverage

To measure code coverage, you can use the `coverage` package:

```bash
pip install coverage
coverage run -m pytest
coverage report
```

## Debugging Tips

1. Use `cocotb.log.info()` for debug messages
2. Set `export COCOTB_REDUCED_LOG_FMT=1` for more readable log output
3. Set `export PYTHONPATH=.` if you have import issues
4. Examine waveforms in GTKWave for signal timing issues

