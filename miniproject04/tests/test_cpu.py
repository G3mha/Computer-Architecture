import shutil
import os
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

@cocotb.test()
async def test_r_type(dut):
    """Test R-type instructions."""
    # Setup memory file
    input_file = "../program/input/test_r_type.mem"
    expected_file = "../program/expected/test_r_type.mem"
    target_file = "program.mem"
    
    shutil.copy(input_file, target_file)
    
    # Run the test
    await run_single_test(dut, expected_file)

@cocotb.test()
async def test_i_type(dut):
    """Test I-type instructions."""
    input_file = "../program/input/test_i_type.mem"
    expected_file = "../program/expected/test_i_type.mem"
    target_file = "program.mem"
    
    shutil.copy(input_file, target_file)
    
    # Run the test
    await run_single_test(dut, expected_file)

@cocotb.test()
async def test_load_store(dut):
    """Test load/store instructions."""
    input_file = "../program/input/test_store.mem"
    expected_file = "../program/expected/test_store.mem"
    target_file = "program.mem"
    
    shutil.copy(input_file, target_file)
    
    # Run the test
    await run_single_test(dut, expected_file)

@cocotb.test()
async def test_branch(dut):
    """Test branch instructions."""
    input_file = "../program/input/test_branch.mem"
    expected_file = "../program/expected/test_branch.mem"
    target_file = "program.mem"
    
    shutil.copy(input_file, target_file)
    
    # Run the test
    await run_single_test(dut, expected_file)

@cocotb.test()
async def test_jump(dut):
    """Test jump instructions."""
    input_file = "../program/input/test_j_type.mem"
    expected_file = "../program/expected/test_j_type.mem"
    target_file = "program.mem"
    
    shutil.copy(input_file, target_file)
    
    # Run the test
    await run_single_test(dut, expected_file)

async def run_single_test(dut, expected_file):
    """Run a single test with the specified expected values file."""
    # Print debug info
    # print("DUT structure:", dir(dut))
    
    # Create clock and reset
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())
    
    # Reset the processor
    dut.reset.value = 1
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.reset.value = 0
    
    # Run for a fixed number of cycles
    for _ in range(30):
        await RisingEdge(dut.clk)
    
    # Check results
    expected_values = load_expected_values(expected_file)
    for i, expected in enumerate(expected_values):
        if expected is not None:
            dut.registers.rs1_addr.value = i
            await Timer(1, units="ns")
            actual = dut.registers.rs1_data.value
            actual_int = int(actual)
            assert actual_int == expected, f"Register x{i} expected {expected:08x}, got {actual_int:08x}"

def load_expected_values(expected_file):
    """Load expected register values from file."""
    expected_values = [None] * 32
    
    if not os.path.exists(expected_file):
        return expected_values
        
    with open(expected_file, 'r') as f:
        for i, line in enumerate(f):
            if i >= 32:
                break
            line = line.strip()
            if line and not line.startswith('//'):
                expected_values[i] = int(line.split('//')[0].strip(), 16)

    return expected_values
