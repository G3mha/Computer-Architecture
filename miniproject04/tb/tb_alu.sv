// Specific testbench for ALU module
`timescale 1ns/1ps

module tb_alu;
  // ALU inputs and outputs
  logic [31:0] a;
  logic [31:0] b;
  logic [3:0]  alu_op;
  logic [31:0] result;
  logic        zero_flag;
  
  // ALU operation codes
  localparam ALU_ADD  = 4'b0000;
  localparam ALU_SUB  = 4'b0001;
  localparam ALU_AND  = 4'b0010;
  localparam ALU_OR   = 4'b0011;
  localparam ALU_XOR  = 4'b0100;
  localparam ALU_SLL  = 4'b0101;
  localparam ALU_SRL  = 4'b0110;
  localparam ALU_SRA  = 4'b0111;
  localparam ALU_SLT  = 4'b1000;
  localparam ALU_SLTU = 4'b1001;
  
  // Test stats
  int test_count = 0;
  int pass_count = 0;
  
  // Instantiate the ALU module
  alu dut (
    .a(a),
    .b(b),
    .alu_op(alu_op),
    .result(result),
    .zero_flag(zero_flag)
  );
  
  // Main test procedure
  initial begin
    $display("\n===== ALU Module Testbench =====\n");
    
    // Test ADD operation
    test_alu_add();
    
    // Test SUB operation
    test_alu_sub();
    
    // Test logical operations
    test_alu_and();
    test_alu_or();
    test_alu_xor();
    
    // Test shift operations
    test_alu_sll();
    test_alu_srl();
    test_alu_sra();
    
    // Test comparison operations
    test_alu_slt();
    test_alu_sltu();
    
    // Test random operations
    test_alu_random();
    
    // Print summary
    $display("\n===== ALU Test Results Summary =====");
    $display("Total Tests: %0d", test_count);
    $display("Passed: %0d", pass_count);
    $display("Failed: %0d", test_count - pass_count);
    
    if (pass_count == test_count)
      $display("ALL TESTS PASSED!");
    else
      $display("SOME TESTS FAILED!");
      
    $finish;
  end
  
  // Helper task for testing
  task check_result(string test_name, logic [31:0] expected, logic expected_zero = 0);
    test_count++;
    #1; // Allow propagation
    
    if (result === expected && zero_flag === expected_zero) begin
      $display("[PASS] %s: Result = 0x%h, Zero = %b", test_name, result, zero_flag);
      pass_count++;
    end else begin
      $display("[FAIL] %s: Result = 0x%h (Expected 0x%h), Zero = %b (Expected %b)", 
               test_name, result, expected, zero_flag, expected_zero);
    end
  endtask
  
  // Test ADD operation
  task test_alu_add();
    $display("\n----- Testing ADD Operation -----");
    alu_op = ALU_ADD;
    
    // Test case 1: 5 + 10 = 15
    a = 5; b = 10;
    check_result("ADD 5+10", 15, 0);
    
    // Test case 2: 0 + 0 = 0 (should set zero flag)
    a = 0; b = 0;
    check_result("ADD 0+0", 0, 1);
    
    // Test case 3: Large numbers
    a = 32'hFFFFFFFF; b = 1;
    check_result("ADD 0xFFFFFFFF+1", 0, 1);
  endtask
  
  // Test SUB operation
  task test_alu_sub();
    $display("\n----- Testing SUB Operation -----");
    alu_op = ALU_SUB;
    
    // Test case 1: 10 - 5 = 5
    a = 10; b = 5;
    check_result("SUB 10-5", 5, 0);
    
    // Test case 2: 5 - 5 = 0 (should set zero flag)
    a = 5; b = 5;
    check_result("SUB 5-5", 0, 1);
    
    // Test case 3: 5 - 10 = -5 (2's complement)
    a = 5; b = 10;
    check_result("SUB 5-10", 32'hFFFFFFFB, 0); // -5 in 2's complement
  endtask
  
  // Test AND operation
  task test_alu_and();
    $display("\n----- Testing AND Operation -----");
    alu_op = ALU_AND;
    
    // Test: 0b1010 & 0b1100 = 0b1000 (10 & 12 = 8)
    a = 'b1010; b = 'b1100;
    check_result("AND 0b1010 & 0b1100", 'b1000, 0);
    
    // More tests...
    a = 'hFFFFFFFF; b = 'h0F0F0F0F;
    check_result("AND 0xFFFFFFFF & 0x0F0F0F0F", 'h0F0F0F0F, 0);
    
    a = 0; b = 'hFFFFFFFF;
    check_result("AND 0 & 0xFFFFFFFF", 0, 1);
  endtask
  
  // Test OR operation
  task test_alu_or();
    $display("\n----- Testing OR Operation -----");
    alu_op = ALU_OR;
    
    // Test: 0b1010 | 0b1100 = 0b1110 (10 | 12 = 14)
    a = 'b1010; b = 'b1100;
    check_result("OR 0b1010 | 0b1100", 'b1110, 0);
    
    // More tests...
    a = 'h0F0F0F0F; b = 'hF0F0F0F0;
    check_result("OR 0x0F0F0F0F | 0xF0F0F0F0", 'hFFFFFFFF, 0);
    
    a = 0; b = 0;
    check_result("OR 0 | 0", 0, 1);
  endtask
  
  // Test XOR operation
  task test_alu_xor();
    $display("\n----- Testing XOR Operation -----");
    alu_op = ALU_XOR;
    
    // Test: 0b1010 ^ 0b1100 = 0b0110 (10 ^ 12 = 6)
    a = 'b1010; b = 'b1100;
    check_result("XOR 0b1010 ^ 0b1100", 'b0110, 0);
    
    // More tests...
    a = 'hFFFFFFFF; b = 'hFFFFFFFF;
    check_result("XOR 0xFFFFFFFF ^ 0xFFFFFFFF", 0, 1);
    
    a = 'h55555555; b = 'hAAAAAAAA;
    check_result("XOR 0x55555555 ^ 0xAAAAAAAA", 'hFFFFFFFF, 0);
  endtask
  
  // Test SLL operation
  task test_alu_sll();
    $display("\n----- Testing SLL Operation -----");
    alu_op = ALU_SLL;
    
    // Test: 0b0001 << 2 = 0b0100 (1 << 2 = 4)
    a = 'b0001; b = 2;
    check_result("SLL 0b0001 << 2", 'b0100, 0);
    
    // More tests...
    a = 'h0000FFFF; b = 16;
    check_result("SLL 0x0000FFFF << 16", 'hFFFF0000, 0);
    
    a = 1; b = 31;
    check_result("SLL 1 << 31", 'h80000000, 0);
    
    a = 1; b = 32; // Should only use lower 5 bits, so shift by 0
    check_result("SLL 1 << 32", 1, 0);
  endtask
  
  // Test SRL operation
  task test_alu_srl();
    $display("\n----- Testing SRL Operation -----");
    alu_op = ALU_SRL;
    
    // Test: 0b1000 >> 2 = 0b0010 (8 >> 2 = 2)
    a = 'b1000; b = 2;
    check_result("SRL 0b1000 >> 2", 'b0010, 0);
    
    // More tests...
    a = 'hFFFF0000; b = 16;
    check_result("SRL 0xFFFF0000 >> 16", 'h0000FFFF, 0);
    
    a = 'h80000000; b = 31;
    check_result("SRL 0x80000000 >> 31", 1, 0);
  endtask
  
  // Test SRA operation
  task test_alu_sra();
    $display("\n----- Testing SRA Operation -----");
    alu_op = ALU_SRA;
    
    // Test positive number: 0b1000 >>> 2 = 0b0010 (8 >>> 2 = 2)
    a = 'b1000; b = 2;
    check_result("SRA 0b1000 >>> 2", 'b0010, 0);
    
    // Test negative number: Sign should be preserved
    a = 'h80000008; b = 2;
    check_result("SRA 0x80000008 >>> 2", 'hE0000002, 0);
    
    a = 'hF0000000; b = 4;
    check_result("SRA 0xF0000000 >>> 4", 'hFF000000, 0);
  endtask
  
  // Test SLT operation
  task test_alu_slt();
    $display("\n----- Testing SLT Operation -----");
    alu_op = ALU_SLT;
    
    // Test 5 < 10 = 1
    a = 5; b = 10;
    check_result("SLT 5 < 10", 1, 0);
    
    // Test 10 < 5 = 0
    a = 10; b = 5;
    check_result("SLT 10 < 5", 0, 1);
    
    // Test with negative numbers: -5 < 10 = 1
    a = 'hFFFFFFFB; b = 10; // -5 in 2's complement
    check_result("SLT -5 < 10", 1, 0);
    
    // Test negative vs negative: -10 < -5 = 1
    a = 'hFFFFFFF6; b = 'hFFFFFFFB; // -10 and -5
    check_result("SLT -10 < -5", 1, 0);
  endtask
  
  // Test SLTU operation
  task test_alu_sltu();
    $display("\n----- Testing SLTU Operation -----");
    alu_op = ALU_SLTU;
    
    // Test 5 < 10 = 1
    a = 5; b = 10;
    check_result("SLTU 5 < 10", 1, 0);
    
    // Test with negative value (interpreted as large unsigned number)
    // -5 as unsigned is a very large number, so -5 < 10 should be false (0)
    a = 'hFFFFFFFB; b = 10; // -5 as two's complement
    check_result("SLTU 0xFFFFFFFB < 10", 0, 1);
    
    // Test 0 < 1 = 1
    a = 0; b = 1;
    check_result("SLTU 0 < 1", 1, 0);
  endtask
  
  // Test with random values
  task test_alu_random();
    $display("\n----- Testing Random Values -----");
    
    // Using fixed "random" values since we can't really do random in plain SV
    // These would be randomly generated in cocotb
    int random_tests[10][3] = '{
      '{ALU_ADD, 'h12345678, 'h87654321},
      '{ALU_SUB, 'h00001234, 'h00000234},
      '{ALU_AND, 'hAAAAAAAA, 'h55555555},
      '{ALU_OR,  'h0F0F0F0F, 'hF0F0F0F0},
      '{ALU_XOR, 'h55555555, 'h33333333},
      '{ALU_SLL, 'h00000001, 4},
      '{ALU_SRL, 'h80000000, 8},
      '{ALU_SRA, 'h80000000, 16},
      '{ALU_SLT, 'h7FFFFFFF, 'h80000000},
      '{ALU_SLTU,'h00000001, 'hFFFFFFFF}
    };
    
    for (int i = 0; i < 10; i++) begin
      automatic int op = random_tests[i][0];
      automatic int a_val = random_tests[i][1];
      automatic int b_val = random_tests[i][2];
      automatic int expected;
      
      // Set inputs
      alu_op = op;
      a = a_val;
      b = b_val;
      
      // Calculate expected result
      case (op)
        ALU_ADD: expected = a_val + b_val;
        ALU_SUB: expected = a_val - b_val;
        ALU_AND: expected = a_val & b_val;
        ALU_OR:  expected = a_val | b_val;
        ALU_XOR: expected = a_val ^ b_val;
        ALU_SLL: expected = a_val << (b_val & 5'h1F);
        ALU_SRL: expected = a_val >> (b_val & 5'h1F);
        ALU_SRA: expected = $signed(a_val) >>> (b_val & 5'h1F);
        ALU_SLT: expected = $signed(a_val) < $signed(b_val) ? 1 : 0;
        ALU_SLTU:expected = a_val < b_val ? 1 : 0;
        default: expected = 0;
      endcase
      
      // Check the result
      check_result($sformatf("Random test %0d: op=%0d, a=0x%h, b=0x%h", 
                  i, op, a_val, b_val), expected);
    end
  endtask
  
endmodule
