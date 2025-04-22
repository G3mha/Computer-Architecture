`timescale 1ns/1ps

module b_type_tb;
    // Testbench signals
    logic        clk;
    logic        reset;
    logic        led;
    logic        red, green, blue;
    
    // Test counters
    integer pass_count = 0;
    integer fail_count = 0;
    
    // Clock generation (100MHz)
    always #5 clk = ~clk;
    
    // Memory file for this test
    localparam PROGRAM_FILE = "program/input/test_branch.mem";
    localparam EXPECTED_FILE = "program/expected/test_branch.mem";
    
    // Expected register values - set proper size
    logic [31:0] expected_reg [0:8]; // Update size to match expected values file (x0-x8)
    
    // Register values from design
    logic [31:0] reg_values [0:31];
    
    // PC monitoring
    logic [31:0] pc_current;
    logic [31:0] pc_next;
    logic        branch_taken;
    
    // Instantiate the processor
    top #(
        .INIT_FILE(PROGRAM_FILE)
    ) dut (
        .clk(clk),
        .reset(reset),
        .led(led),
        .red(red),
        .green(green),
        .blue(blue)
    );
    
    // Access the register file values
    assign reg_values = dut.registers.registers;
    
    // Monitor PC and branch operations
    assign pc_current = dut.pc;
    assign pc_next = dut.pc_next;
    assign branch_taken = dut.take_branch;
    
    // Monitor branch decisions
    always @(posedge clk) begin
        if (dut.branch) begin
            if (dut.take_branch)
                $display("Branch taken at PC=0x%8h -> Next PC=0x%8h", pc_current, pc_next);
            else
                $display("Branch not taken at PC=0x%8h", pc_current);
        end
    end
    
    // Load expected values
    initial begin
        // Clear array first
        for (int i = 0; i < 9; i++) begin
            expected_reg[i] = 32'h0;
        end
        $readmemh(EXPECTED_FILE, expected_reg);
    end

    // Test sequence
    initial begin
        $display("Starting B-Type Instructions Test");
        
        // Initialize signals
        clk = 0;
        reset = 1;
        
        // Apply reset
        #20 reset = 0;
        
        // Run test for a while to allow execution
        repeat(250) @(posedge clk);
        
        // Check results
        $display("Checking register values after B-type instructions execution");
        
        // Initialize pass and fail counters
        pass_count = 0;
        fail_count = 0;

        // Check registers according to expected_test_branch.mem file
        for (int i = 0; i <= 8; i++) begin
            if (reg_values[i] !== expected_reg[i]) begin
                $display("ERROR: Register x%0d = 0x%8h, Expected = 0x%8h", 
                         i, reg_values[i], expected_reg[i]);
                fail_count++;
            end else begin
                $display("PASS: Register x%0d = 0x%8h", i, reg_values[i]);
                pass_count++;
            end
        end
        
        $display("Test summary: %0d passed, %0d failed", pass_count, fail_count);
        
        $display("B-type instruction test completed");
        $finish;
    end
    
    // Dump waveforms
    initial begin
        $dumpfile("sim/b_type_tb.vcd");
        $dumpvars(0, b_type_tb);
    end
endmodule
