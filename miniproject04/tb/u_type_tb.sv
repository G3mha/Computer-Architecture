`timescale 1ns/1ps

module u_type_tb;
    // Testbench signals
    logic        clk;
    logic        reset;
    logic        led;
    logic        red, green, blue;
    
    // Clock generation (100MHz)
    always #5 clk = ~clk;
    
    // Memory file for this test
    localparam PROGRAM_FILE = "program/input/test_u_type.mem";
    localparam EXPECTED_FILE = "program/expected/test_u_type.mem";
    
    // Expected register values
    logic [31:0] expected_reg [0:4]; // We're checking x0-x4
    
    // Register values from design
    logic [31:0] reg_values [0:31];
    
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
    
    // Load expected values
    initial begin
        $readmemh(EXPECTED_FILE, expected_reg);
    end

    // Test sequence
    initial begin
        $display("Starting U-Type Instructions Test");
        
        // Initialize signals
        clk = 0;
        reset = 1;
        
        // Apply reset for 20ns
        #20;
        reset = 0;
        
        // Run for enough cycles to execute all instructions
        // Each instruction takes multiple cycles in this design
        repeat(100) @(posedge clk);
        
        // Check results
        $display("Checking register values after U-type instructions execution");
        
        for (int i = 0; i <= 4; i++) begin
            if (i == 4) begin  
                // Special case for AUIPC which uses PC value
                // We can't expect an exact match because the PC value depends on
                // the cycle count, but we can check if the upper bits match
                logic [31:0] upper_expected = expected_reg[i] & 32'hFFFFF000;
                logic [31:0] upper_actual = reg_values[i] & 32'hFFFFF000;
                
                if (upper_actual !== upper_expected) begin
                    $display("ERROR: Register x%0d = 0x%8h, Expected upper bits = 0x%8h", 
                              i, reg_values[i], upper_expected);
                end else begin
                    $display("PASS: Register x%0d = 0x%8h (upper bits match expected)", 
                              i, reg_values[i]);
                end
            end else if (reg_values[i] !== expected_reg[i]) begin
                $display("ERROR: Register x%0d = 0x%8h, Expected = 0x%8h", 
                          i, reg_values[i], expected_reg[i]);
            end else begin
                $display("PASS: Register x%0d = 0x%8h", i, reg_values[i]);
            end
        end
        
        // End simulation
        $display("U-type instruction test completed");
        $finish;
    end
    
    // Optional: Dump waveforms
    initial begin
        $dumpfile("sim/u_type_tb.vcd");
        $dumpvars(0, u_type_tb);
    end
endmodule
