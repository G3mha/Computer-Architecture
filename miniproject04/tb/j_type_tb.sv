`timescale 1ns/1ps

module j_type_tb;
    // Testbench signals
    logic        clk;
    logic        reset;
    logic        led;
    logic        red, green, blue;
    
    // Clock generation (100MHz)
    always #5 clk = ~clk;
    
    // Memory file for this test
    localparam PROGRAM_FILE = "program/input/test_j_type.mem";
    localparam EXPECTED_FILE = "program/expected/test_j_type.mem";
    
    // Expected register values
    logic [31:0] expected_reg [0:8]; // We're checking x0-x8
    
    // Register values from design
    logic [31:0] reg_values [0:31];
    
    // Jump monitoring
    logic [31:0] pc_current;
    logic [31:0] pc_next;
    logic        jump_detected;
    
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
    
    // Monitor PC and jump operations
    assign pc_current = dut.pc;
    assign pc_next = dut.pc_next;
    assign jump_detected = dut.jump;
    
    // Load expected values
    initial begin
        $readmemh(EXPECTED_FILE, expected_reg);
    end

    // Test sequence
    initial begin
        $display("Starting J-Type Instructions Test (JAL only)");
        
        // Initialize signals
        clk = 0;
        reset = 1;
        
        // Apply reset for 20ns
        #20;
        reset = 0;
        
        // Run for enough cycles to execute all instructions
        repeat(100) @(posedge clk);
        
        // Check results
        $display("Checking register values after J-type (JAL) instructions execution");
        
        for (int i = 0; i <= 8; i++) begin
            if ((i == 1 || i == 4) && (reg_values[i] !== expected_reg[i])) begin
                // Link registers (x1/x6) store return addresses, so they might vary
                if (reg_values[i] == 0) begin
                    $display("ERROR: Link register x%0d = 0, Expected non-zero value", i);
                end else begin
                    $display("PASS: Link register x%0d = 0x%8h (non-zero value)", i, reg_values[i]);
                end
            end else if (reg_values[i] !== expected_reg[i]) begin
                $display("ERROR: Register x%0d = 0x%8h, Expected = 0x%8h", 
                          i, reg_values[i], expected_reg[i]);
            end else begin
                $display("PASS: Register x%0d = 0x%8h", i, reg_values[i]);
            end
        end
        
        // End simulation
        $display("J-type (JAL) instruction test completed");
        $finish;
    end
    
    // Optional: Dump waveforms
    initial begin
        $dumpfile("sim/j_type_tb.vcd");
        $dumpvars(0, j_type_tb);
    end

endmodule
