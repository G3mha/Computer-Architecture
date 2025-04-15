import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer
from cocotb.binary import BinaryValue

# ALU operation codes (must match the ones in your ALU module)
ALU_ADD  = 0  # 4'b0000
ALU_SUB  = 1  # 4'b0001
ALU_AND  = 2  # 4'b0010
ALU_OR   = 3   # 4'b0011
ALU_XOR  = 4  # 4'b0100
ALU_SLL  = 5  # 4'b0101
ALU_SRL  = 6  # 4'b0110
ALU_SRA  = 7  # 4'b0111
ALU_SLT  = 8  # 4'b1000
ALU_SLTU = 9  # 4'b1001

@cocotb.test()
async def test_alu_add(dut):
    """Test ALU ADD operation."""
    # Set operation to ADD
    dut.alu_op.value = ALU_ADD
    
    # Test case 1: 5 + 10 = 15
    dut.a.value = 5
    dut.b.value = 10
    await Timer(1, units="ns")  # Wait a bit for combinational logic
    assert dut.result.value == 15, f"Expected 15, got {dut.result.value}"
    assert dut.zero_flag.value == 0, "Zero flag should be 0"
    
    # Test case 2: 0 + 0 = 0 (should set zero flag)
    dut.a.value = 0
    dut.b.value = 0
    await Timer(1, units="ns")
    assert dut.result.value == 0, f"Expected 0, got {dut.result.value}"
    assert dut.zero_flag.value == 1, "Zero flag should be 1"

@cocotb.test()
async def test_alu_sub(dut):
    """Test ALU SUB operation."""
    # Set operation to SUB
    dut.alu_op.value = ALU_SUB
    
    # Test case 1: 10 - 5 = 5
    dut.a.value = 10
    dut.b.value = 5
    await Timer(1, units="ns")
    assert dut.result.value == 5, f"Expected 5, got {dut.result.value}"
    
    # Test case 2: 5 - 5 = 0 (should set zero flag)
    dut.a.value = 5
    dut.b.value = 5
    await Timer(1, units="ns")
    assert dut.result.value == 0, f"Expected 0, got {dut.result.value}"
    assert dut.zero_flag.value == 1, "Zero flag should be 1"

@cocotb.test()
async def test_alu_and(dut):
    """Test ALU AND operation."""
    dut.alu_op.value = ALU_AND
    
    # Test: 0b1010 & 0b1100 = 0b1000 (10 & 12 = 8)
    dut.a.value = 0b1010
    dut.b.value = 0b1100
    await Timer(1, units="ns")
    assert dut.result.value == 0b1000, f"Expected 8, got {dut.result.value}"

@cocotb.test()
async def test_alu_or(dut):
    """Test ALU OR operation."""
    dut.alu_op.value = ALU_OR
    
    # Test: 0b1010 | 0b1100 = 0b1110 (10 | 12 = 14)
    dut.a.value = 0b1010
    dut.b.value = 0b1100
    await Timer(1, units="ns")
    assert dut.result.value == 0b1110, f"Expected 14, got {dut.result.value}"

@cocotb.test()
async def test_alu_xor(dut):
    """Test ALU XOR operation."""
    dut.alu_op.value = ALU_XOR
    
    # Test: 0b1010 ^ 0b1100 = 0b0110 (10 ^ 12 = 6)
    dut.a.value = 0b1010
    dut.b.value = 0b1100
    await Timer(1, units="ns")
    assert dut.result.value == 0b0110, f"Expected 6, got {dut.result.value}"

@cocotb.test()
async def test_alu_sll(dut):
    """Test ALU SLL (Shift Left Logical) operation."""
    dut.alu_op.value = ALU_SLL
    
    # Test: 0b0001 << 2 = 0b0100 (1 << 2 = 4)
    dut.a.value = 0b0001
    dut.b.value = 2
    await Timer(1, units="ns")
    assert dut.result.value == 0b0100, f"Expected 4, got {dut.result.value}"

@cocotb.test()
async def test_alu_srl(dut):
    """Test ALU SRL (Shift Right Logical) operation."""
    dut.alu_op.value = ALU_SRL
    
    # Test: 0b1000 >> 2 = 0b0010 (8 >> 2 = 2)
    dut.a.value = 0b1000
    dut.b.value = 2
    await Timer(1, units="ns")
    assert dut.result.value == 0b0010, f"Expected 2, got {dut.result.value}"

@cocotb.test()
async def test_alu_sra(dut):
    """Test ALU SRA (Shift Right Arithmetic) operation."""
    dut.alu_op.value = ALU_SRA
    
    # Test positive number: 0b1000 >> 2 = 0b0010 (8 >> 2 = 2)
    dut.a.value = 0b1000
    dut.b.value = 2
    await Timer(1, units="ns")
    assert dut.result.value == 0b0010, f"Expected 2, got {dut.result.value}"
    
    # Test negative number: 0b10000000000000000000000000001000 >> 2
    # Should preserve sign bit
    negative_val = BinaryValue(value="10000000000000000000000000001000", n_bits=32)
    dut.a.value = negative_val
    dut.b.value = 2
    await Timer(1, units="ns")
    
    # After shift, should still have the sign bit set
    expected = BinaryValue(value="11100000000000000000000000000010", n_bits=32)
    assert dut.result.value == expected.integer, f"Expected sign-extended result"

@cocotb.test()
async def test_alu_slt(dut):
    """Test ALU SLT (Set Less Than) operation."""
    dut.alu_op.value = ALU_SLT
    
    # Test 5 < 10 = 1
    dut.a.value = 5
    dut.b.value = 10
    await Timer(1, units="ns")
    assert dut.result.value == 1, f"Expected 1, got {dut.result.value}"
    
    # Test 10 < 5 = 0
    dut.a.value = 10
    dut.b.value = 5
    await Timer(1, units="ns")
    assert dut.result.value == 0, f"Expected 0, got {dut.result.value}"
    
    # Test with negative numbers: -5 < 10 = 1
    negative_val = BinaryValue(value="11111111111111111111111111111011", n_bits=32)  # -5 in two's complement
    dut.a.value = negative_val
    dut.b.value = 10
    await Timer(1, units="ns")
    assert dut.result.value == 1, f"Expected 1, got {dut.result.value}"

@cocotb.test()
async def test_alu_sltu(dut):
    """Test ALU SLTU (Set Less Than Unsigned) operation."""
    dut.alu_op.value = ALU_SLTU
    
    # Test 5 < 10 = 1
    dut.a.value = 5
    dut.b.value = 10
    await Timer(1, units="ns")
    assert dut.result.value == 1, f"Expected 1, got {dut.result.value}"
    
    # Test with negative value (interpreted as large unsigned number)
    # -5 as unsigned is a very large number, so -5 < 10 should be false (0)
    negative_val = BinaryValue(value="11111111111111111111111111111011", n_bits=32)  # -5 as two's complement
    dut.a.value = negative_val
    dut.b.value = 10
    await Timer(1, units="ns")
    assert dut.result.value == 0, f"Expected 0, got {dut.result.value}"

@cocotb.test()
async def test_alu_random(dut):
    """Test ALU with random inputs."""
    operations = [ALU_ADD, ALU_SUB, ALU_AND, ALU_OR, ALU_XOR, ALU_SLL, ALU_SRL]
    
    for _ in range(20):  # Run 20 random tests
        # Select random operation from list
        op = random.choice(operations)
        dut.alu_op.value = op
        
        # Generate random 32-bit values for a and b
        a_val = random.randint(0, 0xFFFFFFFF)
        b_val = random.randint(0, 0xFF)  # Limit shift amount for shift operations
        
        dut.a.value = a_val
        dut.b.value = b_val
        
        # Calculate expected result based on operation
        if op == ALU_ADD:
            expected = (a_val + b_val) & 0xFFFFFFFF
        elif op == ALU_SUB:
            expected = (a_val - b_val) & 0xFFFFFFFF
        elif op == ALU_AND:
            expected = a_val & b_val
        elif op == ALU_OR:
            expected = a_val | b_val
        elif op == ALU_XOR:
            expected = a_val ^ b_val
        elif op == ALU_SLL:
            expected = (a_val << (b_val & 0x1F)) & 0xFFFFFFFF
        elif op == ALU_SRL:
            expected = (a_val >> (b_val & 0x1F)) & 0xFFFFFFFF
        
        await Timer(1, units="ns")
        assert dut.result.value == expected, f"Op: {op}, a: {a_val:x}, b: {b_val:x}, Expected: {expected:x}, Got: {dut.result.value:x}"
