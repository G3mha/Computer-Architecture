`timescale 1ns/1ps

module i_type_tb;
    // Testbench signals
    logic        clk;
    logic        reset;
    logic        led;
    logic        red, green, blue;
    
    // Clock generation (100MHz)
    always #5 clk = ~clk;
    
    // Memory file for this test
    localparam PROGRAM_FILE = "program/input/test_i_type.mem";
    localparam EXPECTED_FILE = "program/expected/test_i_type.mem";
    
    // Expected register values
    logic [31:0] expected_reg [0:10]; // We're checking x0-x10
    
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
        $display("Starting I-Type Instructions Test");
        
        // Initialize signals
        clk = 0;
        reset = 1;
        
        // Apply reset for 20ns
        #20;
        reset = 0;
        
        // Run for more cycles to ensure all instructions execute
        repeat(200) @(posedge clk);
        
        // Check results
        $display("Checking register values after I-type instructions execution");
        
        for (int i = 0; i <= 9; i++) begin
            if (reg_values[i] !== expected_reg[i]) begin
                $display("ERROR: Register x%0d = 0x%8h, Expected = 0x%8h", 
                          i, reg_values[i], expected_reg[i]);
            end else begin
                $display("PASS: Register x%0d = 0x%8h", i, reg_values[i]);
            end
        end
                
        // End simulation
        $display("I-type instruction test completed");
        $finish;
    end
    
    // Optional: Dump waveforms
    initial begin
        $dumpfile("sim/i_type_tb.vcd");
        $dumpvars(0, i_type_tb);
    end
endmodule
