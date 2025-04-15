import os
import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer
from cocotb.regression import TestFactory

class CPUTest:
    def __init__(self, dut, test_type):
        self.dut = dut
        self.test_type = test_type
        self.input_file = f"../program/input/test_{test_type}.mem"
        self.expected_file = f"../program/expected/test_{test_type}.mem"
        
    async def setup(self):
        # Create a clock
        clock = Clock(self.dut.clk, 10, units="ns")
        cocotb.start_soon(clock.start())
        
        # Copy the input file to the default location
        import shutil
        print(f"Copying {self.input_file} to program.mem")
        target_file = "program.mem"  # Match default INIT_FILE
        shutil.copy(self.input_file, target_file)

        # Reset the processor
        self.dut.reset.value = 1
        await RisingEdge(self.dut.clk)
        await RisingEdge(self.dut.clk)
        self.dut.reset.value = 0
    
    async def run_test(self):
        await self.setup()
        
        # Load input memory file - this would be done through simulator commands
        # For cocotb with Icarus, we'll need to modify the test approach
        # Here, we'd monitor execution over several clock cycles
        
        # Run for a fixed number of clock cycles
        for _ in range(30):
            await RisingEdge(self.dut.clk)
            
        # Check results by examining register file using read ports
        expected_values = self.load_expected_values()
        for i, expected in enumerate(expected_values):
            if expected is not None:
                # Set the read address to access register i
                self.dut.top.registers.rs1_addr.value = i
                # Wait for the clock edge to update the read data
                await RisingEdge(self.dut.clk)
                # Read the value from rs1_data
                actual = self.dut.top.rs1_data.value
                # Convert to integer for comparison
                actual_int = int(actual)
                assert actual_int == expected, f"Register x{i} expected {expected:08x}, got {actual_int:08x}"
    
    def load_expected_values(self):
        """Load expected register values from file."""
        expected_values = [None] * 32  # None for registers we don't check
        
        if not os.path.exists(self.expected_file):
            return expected_values
            
        with open(self.expected_file, 'r') as f:
            for i, line in enumerate(f):
                if i >= 32:
                    break
                line = line.strip()
                if line and not line.startswith('//'):
                    expected_values[i] = int(line.split('//')[0].strip(), 16)

        return expected_values

@cocotb.test()
async def test_r_type(dut):
    """Test R-type instructions."""
    test = CPUTest(dut, "r_type")
    await test.run_test()

@cocotb.test()
async def test_i_type(dut):
    """Test I-type instructions."""
    test = CPUTest(dut, "i_type")
    await test.run_test()

@cocotb.test()
async def test_load_store(dut):
    """Test load/store instructions."""
    test = CPUTest(dut, "store")
    await test.run_test()

@cocotb.test()
async def test_branch(dut):
    """Test branch instructions."""
    test = CPUTest(dut, "branch")
    await test.run_test()

@cocotb.test()
async def test_jump(dut):
    """Test jump instructions."""
    test = CPUTest(dut, "j_type")
    await test.run_test()
