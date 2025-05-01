`timescale 1ns/1ps

module s_type_tb;
    // Testbench signals
    logic        clk;
    logic        reset;
    logic        led;
    logic        red, green, blue;
    
    // Clock generation (100MHz)
    always #5 clk = ~clk;
    
    // Memory file for this test
    localparam PROGRAM_FILE = "program/input/test_store.mem";
    localparam EXPECTED_FILE = "program/expected/test_store.mem";
    
    // Expected register values
    logic [31:0] expected_reg [0:6]; // We're checking x0-x6
    
    // Register values from design
    logic [31:0] reg_values [0:31];
    
    // Monitor memory access for store operations
    logic [31:0] store_addr;
    logic [31:0] store_data;
    logic        store_detected;
    
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
    
    // Monitor for store operations
    always @(posedge clk) begin
        if (dut.mem_write) begin
            store_addr = dut.alu_result;
            store_data = dut.rs2_data;
            store_detected = 1;
            $display("Store detected: Address=0x%8h, Data=0x%8h", store_addr, store_data);
        end else begin
            store_detected = 0;
        end
    end
    
    // Load expected values
    initial begin
        $readmemh(EXPECTED_FILE, expected_reg);
    end

    // Test sequence
    initial begin
        $display("Starting S-Type Instructions Test");
        
        // Initialize signals
        clk = 0;
        reset = 1;
        store_detected = 0;
        
        // Apply reset for 20ns
        #20;
        reset = 0;
        
        // Run for enough cycles to execute all instructions
        // Each instruction takes multiple cycles in this design
        repeat(100) @(posedge clk);
        
        // Check results
        $display("Checking register values after S-type instructions execution");
        
        for (int i = 0; i <= 6; i++) begin
            if (reg_values[i] !== expected_reg[i]) begin
                $display("ERROR: Register x%0d = 0x%8h, Expected = 0x%8h", 
                          i, reg_values[i], expected_reg[i]);
            end else begin
                $display("PASS: Register x%0d = 0x%8h", i, reg_values[i]);
            end
        end
        
        // Check memory contents via load operations
        // We rely on the test program to verify the stored values via loads
        
        // End simulation
        $display("S-type instruction test completed");
        $finish;
    end
    
    // Optional: Dump waveforms
    initial begin
        $dumpfile("sim/s_type_tb.vcd");
        $dumpvars(0, s_type_tb);
    end
endmodule
