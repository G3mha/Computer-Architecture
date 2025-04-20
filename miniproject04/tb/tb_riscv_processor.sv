// Comprehensive testbench for RISC-V processor
`timescale 1ns/1ps

module tb_riscv_processor;
  // Clock and reset
  logic clk;
  logic reset;
  logic led;
  logic red, green, blue;
  
  // Path constants for test files
  string INPUT_PATH;
  string EXPECTED_PATH;

  initial begin
    INPUT_PATH = "./program/input/";
    EXPECTED_PATH = "./program/expected/";
  end

  
  // Test configuration
  int MAX_CYCLES = 50;
  logic [31:0] expected_reg_values[0:31];
  int test_count = 0;
  int pass_count = 0;
  
  // Instantiate the top module
  top #(
    .INIT_FILE("./program/program.mem") // Will be overridden by test
  ) dut (
    .clk(clk),
    .reset(reset),
    .led(led),
    .red(red),
    .green(green),
    .blue(blue)
  );
  
  // Clock generation: 10ns period
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  // Main test routine
  initial begin
    $display("\n===== RISC-V Processor Testbench =====\n");
    
    // Run all tests
    run_test("R-Type Instructions", "test_r_type.mem");
    run_test("I-Type Instructions", "test_i_type.mem");
    run_test("Load Instructions", "test_load.mem");
    run_test("Store Instructions", "test_store.mem");
    run_test("Branch Instructions", "test_branch.mem");
    run_test("U-Type Instructions", "test_u_type.mem");
    run_test("J-Type Instructions", "test_j_type.mem");
    
    // Print summary
    $display("\n===== Test Results Summary =====");
    $display("Total Tests: %0d", test_count);
    $display("Passed: %0d", pass_count);
    $display("Failed: %0d", test_count - pass_count);
    
    if (pass_count == test_count)
      $display("ALL TESTS PASSED!");
    else
      $display("SOME TESTS FAILED!");
      
    $finish;
  end
  
  // Task to run a single test
  task run_test(string test_name, string mem_file);
    string input_file;
    string expected_file;
    string msg;
    
    $display("\n===== Testing %s =====", test_name);
    
    // Setup file paths
    input_file = $sformatf("%s%s", INPUT_PATH, mem_file);
    expected_file = $sformatf("%s%s", EXPECTED_PATH, mem_file);

    $display("Input file path: %s", input_file);
    $display("Expected file path: %s", expected_file);

    
    // Reset processor
    reset = 1;
    @(posedge clk);
    @(posedge clk);
    reset = 0;
    
    // Load program and expected values
    $display("Loading test program: %s", input_file);
    
    // Copy to program.mem for the DUT to read (in both the current directory and sim directory)
    copy_file(input_file, "program.mem");
    
    // Also copy to the root directory where the memory modules expect to find it
    copy_file(input_file, "../program.mem");
    
    // Instead of trying to force clear memory, we'll use the reset signal
    // to let the system reload memory from the file
    reset = 1;
    repeat(5) @(posedge clk);
    reset = 0;
    
    // Load expected values
    load_expected_values(expected_file);
    
    // Run for a fixed number of cycles
    for (int i = 0; i < MAX_CYCLES; i++) begin
      @(posedge clk);
      
      // Debug output
      if (!reset) begin
        $display("Cycle %0d: PC=0x%8h, Instr=0x%8h", 
                i, dut.pc, dut.instruction);
      end
      
      // Check if we've hit an infinite loop (jal x0, 0)
      if (dut.instruction == 32'h0000006F && i > 5) begin
        $display("Detected end of program (infinite loop)");
        break;
      end
    end
    
    // Verify results
    verify_registers(test_name);
  endtask
  
  // Task to verify register values against expected
  task verify_registers(string test_name);
    int reg_test_count = 0;
    int reg_pass_count = 0;
    
    $display("\n----- %s: Register Verification -----", test_name);
    
    for (int i = 0; i < 32; i++) begin
      // Only check registers with expected values
      if (expected_reg_values[i] !== 32'hx) begin
        reg_test_count++;
        test_count++;
        
        if (dut.registers.registers[i] === expected_reg_values[i]) begin
          $display("[PASS] Register x%0d = 0x%8h", i, dut.registers.registers[i]);
          reg_pass_count++;
          pass_count++;
        end else begin
          $display("[FAIL] Register x%0d = 0x%8h (Expected: 0x%8h)", 
                   i, dut.registers.registers[i], expected_reg_values[i]);
        end
      end
    end
    
    $display("\n%s: %0d/%0d register tests passed", 
             test_name, reg_pass_count, reg_test_count);
  endtask
  
  // Function to load expected register values
  task load_expected_values(string filename);
    int file;
    string line;
    int reg_num = 0;
    logic [31:0] value;
    string comment;
    
    // Initialize with x (don't care)
    for (int i = 0; i < 32; i++) begin
      expected_reg_values[i] = 32'hx;
    end
    
    file = $fopen(filename, "r");
    if (file == 0) begin
      $display("ERROR: Failed to open file: %s", filename);
      return;
    end
    
    while (!$feof(file) && reg_num < 32) begin
      int status = $fgets(line, file);
      if (status != 0) begin
        // Process the line (simplified from the original)
        status = $sscanf(line, "%h", value);
        if (status == 1) begin
          expected_reg_values[reg_num] = value;
          reg_num++;
        end
      end
    end
    
    $fclose(file);
    $display("Loaded %0d expected register values from %s", reg_num, filename);
  endtask
  
  // Helper function to copy a file
  // Note: In actual implementation, you might need to use system tasks
  // like $system to call OS commands for file copying
  task copy_file(string src_file, string dst_file);
    int src, dst;
    string line;
    
    src = $fopen(src_file, "r");
    if (src == 0) begin
      $display("ERROR: Failed to open source file: %s", src_file);
      $display("Current directory: %s", `__FILE__);
      return;
    end
    
    dst = $fopen(dst_file, "w");
    if (dst == 0) begin
      $display("ERROR: Failed to open destination file: %s", dst_file);
      $fclose(src);
      return;
    end
    
    while (!$feof(src)) begin
      int status = $fgets(line, src);
      if (status != 0) begin
        $fwrite(dst, "%s", line);
      end
    end
    
    $fclose(src);
    $fclose(dst);
    $display("Copied %s to %s", src_file, dst_file);
  endtask
  
  // Monitor instruction execution
  always @(posedge clk) begin
    if (!reset && $time > 20) begin
      // Detailed signal monitoring when verbose
      $display("  ALU: a=0x%8h, b=0x%8h, op=%b, result=0x%8h, zero=%b", 
               dut.op1_mux_out, dut.op2_mux_out, dut.alu_op, 
               dut.alu_result, dut.zero_flag);
               
      $display("  Control: reg_write=%b, alu_src=%b, mem_to_reg=%b, branch=%b, jump=%b", 
               dut.reg_write, dut.alu_src, dut.mem_to_reg, dut.branch, dut.jump);
               
      if (dut.reg_write && dut.instruction[11:7] != 0)
        $display("  RegWrite: rd=x%0d, data=0x%8h", 
                 dut.instruction[11:7], dut.write_data);
    end
  end

endmodule
