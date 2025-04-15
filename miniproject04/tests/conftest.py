import os
import pytest
import shutil
from pathlib import Path

def pytest_configure(config):
    """Setup for cocotb tests."""
    # Create a sim_build directory if it doesn't exist
    sim_build = Path("sim_build")
    sim_build.mkdir(exist_ok=True)
    
    # Copy all test programs to the sim directory for easier access by the simulator
    program_dir = Path("../program")
    if program_dir.exists():
        # Copy input test files
        input_dir = program_dir / "input"
        if input_dir.exists():
            for mem_file in input_dir.glob("*.mem"):
                shutil.copy(mem_file, sim_build)
        
        # Copy expected result files
        expected_dir = program_dir / "expected"
        if expected_dir.exists():
            for mem_file in expected_dir.glob("*.mem"):
                # We'll add a prefix to avoid name conflicts
                dest_file = sim_build / f"expected_{mem_file.name}"
                shutil.copy(mem_file, dest_file)
