// Testbench for RV32I Single-Cycle Processor Top Module

`timescale 10ns/10ns
`include "top.sv"

module tb_top;
  // Clock and reset
  logic clk;
  logic reset;
  
  // Instantiate the top module
  top dut (
    .clk(clk),
    .reset(reset)
  );
  
  // Clock generation: 10ns period
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Test program memory - will be loaded via $readmemh
  logic [31:0] expected_reg_values[0:31];
  logic [31:0] test_count = 0;
  logic [31:0] pass_count = 0;
  string current_test = "None";
  
  // Monitor key signals and register file for verification
  task check_register(input int reg_num, input logic [31:0] expected_value);
    test_count = test_count + 1;
    if (dut.registers.registers[reg_num] === expected_value) begin
      $display("[PASS] Register x%0d = 0x%8h (Expected: 0x%8h)", reg_num, dut.registers.registers[reg_num], expected_value);
      pass_count = pass_count + 1;
    end else begin
      $display("[FAIL] Register x%0d = 0x%8h (Expected: 0x%8h)", reg_num, dut.registers.registers[reg_num], expected_value);
    end
  endtask
  
  // Test specific instruction execution
  task test_instruction_type(input string test_name, input string mem_file);
    current_test = test_name;
    $display("\n=== Testing %s Instructions ===", test_name);
    
    // Reset processor
    reset = 1;
    #20;
    reset = 0;
    
    $readmemh({"tests/input/", mem_file}, dut.instruction_mem.memory);
    $readmemh({"tests/expected/", mem_file}, expected_reg_values);
    
    // Run for enough cycles to complete test
    #200;
    
    // Verify results for each register that should have changed
    for (int i = 1; i < 32; i++) begin
      if (expected_reg_values[i] !== 32'h0) begin
        check_register(i, expected_reg_values[i]);
      end
    end
  endtask
  
  // Run all tests
  initial begin
    // Dump waves for GTKWave
    $dumpfile("riscv_processor_test.vcd");
    $dumpvars(0, tb_top);
    
    // Test each instruction type
    test_instruction_type("R-Type", "test_r_type.mem");
    test_instruction_type("I-Type", "test_i_type.mem");
    test_instruction_type("Load", "test_load.mem");
    test_instruction_type("Store", "test_store.mem");
    test_instruction_type("Branch", "test_branch.mem");
    test_instruction_type("U-Type", "test_u_type.mem");
    test_instruction_type("J-Type", "test_j_type.mem");
    
    // Report final results
    $display("\n=== Test Results Summary ===");
    $display("Total Tests: %0d", test_count);
    $display("Passed: %0d", pass_count);
    $display("Failed: %0d", test_count - pass_count);
    
    if (pass_count == test_count)
      $display("ALL TESTS PASSED!");
    else
      $display("SOME TESTS FAILED!");
        
    $finish;
  end

  // Monitor instruction execution
  always @(posedge clk) begin
    if (!reset && dut.instruction !== 32'h0) begin
      $display("Time=%0t: PC=0x%8h, Instr=0x%8h", $time, dut.pc, dut.instruction);
    end
  end
endmodule
