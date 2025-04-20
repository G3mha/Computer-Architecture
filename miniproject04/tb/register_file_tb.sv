`timescale 1ns/1ps

module register_file_tb;
    // Signals for connecting to the register file
    logic         clk;
    logic         reset;
    logic         reg_write;
    logic [4:0]   rs1_addr;
    logic [4:0]   rs2_addr;
    logic [4:0]   rd_addr;
    logic [31:0]  rd_data;
    logic [31:0]  rs1_data;
    logic [31:0]  rs2_data;
    
    // Instantiate the register file (device under test)
    register_file dut (
        .clk(clk),
        .reset(reset),
        .reg_write(reg_write),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .rd_data(rd_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );
    
    // Clock generation - 10ns period (100MHz)
    always begin
        #5 clk = ~clk;
    end
    
    // Task to write a value to a register
    task write_register(input [4:0] addr, input [31:0] data);
        begin
            @(negedge clk);
            reg_write = 1;
            rd_addr = addr;
            rd_data = data;
            @(posedge clk);
            #1; // Small delay after clock edge
            reg_write = 0;
        end
    endtask
    
    // Task to verify register value on rs1 port
    task verify_rs1(input [4:0] addr, input [31:0] expected);
        begin
            @(negedge clk);
            rs1_addr = addr;
            #1; // Small delay for propagation
            if (rs1_data === expected)
                $display("PASS: rs1_addr=%d, expected=%h, got=%h", addr, expected, rs1_data);
            else
                $display("FAIL: rs1_addr=%d, expected=%h, got=%h", addr, expected, rs1_data);
        end
    endtask
    
    // Task to verify register value on rs2 port
    task verify_rs2(input [4:0] addr, input [31:0] expected);
        begin
            @(negedge clk);
            rs2_addr = addr;
            #1; // Small delay for propagation
            if (rs2_data === expected)
                $display("PASS: rs2_addr=%d, expected=%h, got=%h", addr, expected, rs2_data);
            else
                $display("FAIL: rs2_addr=%d, expected=%h, got=%h", addr, expected, rs2_data);
        end
    endtask
    
    // Test stimulus
    initial begin
        $display("Starting Register File Testbench");
        
        // Initialize signals
        clk = 0;
        reset = 0;
        reg_write = 0;
        rs1_addr = 0;
        rs2_addr = 0;
        rd_addr = 0;
        rd_data = 0;
        
        // Apply reset
        reset = 1;
        #10;
        reset = 0;
        #10;
        
        // Test 1: Verify all registers are reset to 0
        $display("Test 1: Verify reset sets all registers to 0");
        for (int i = 0; i < 32; i++) begin
            verify_rs1(i, 0);
        end
        
        // Test 2: Write to registers 1-31 and verify
        $display("Test 2: Write to and read from registers");
        for (int i = 1; i < 32; i++) begin
            write_register(i, i * 100);  // Write i*100 to register i
            verify_rs1(i, i * 100);      // Verify via port 1
        end
        
        // Test 3: Verify register 0 is hardwired to 0
        $display("Test 3: Verify register 0 is hardwired to 0");
        write_register(0, 32'hDEADBEEF); // Try to write non-zero value to x0
        verify_rs1(0, 0);                // Should still read as 0
        
        // Test 4: Verify writes don't occur when reg_write is 0
        $display("Test 4: Verify writes don't occur when reg_write is 0");
        @(negedge clk);
        reg_write = 0;
        rd_addr = 5;
        rd_data = 32'hAABBCCDD;
        @(posedge clk);
        #1;
        verify_rs1(5, 5 * 100);  // Should still have the old value (5*100)
        
        // Test 5: Verify both read ports work independently
        $display("Test 5: Verify both read ports work correctly and independently");
        rs1_addr = 10;  // Read register 10 via port 1
        rs2_addr = 20;  // Read register 20 via port 2
        #1;
        if (rs1_data === 10 * 100 && rs2_data === 20 * 100)
            $display("PASS: Both ports read correct values simultaneously");
        else
            $display("FAIL: Expected rs1_data=%h, got=%h, Expected rs2_data=%h, got=%h", 
                    10 * 100, rs1_data, 20 * 100, rs2_data);
        
        // Test 6: Verify asynchronous reset works
        $display("Test 6: Verify asynchronous reset");
        @(negedge clk);
        reset = 1;
        #1;  // Small delay after reset
        for (int i = 0; i < 32; i++) begin
            rs1_addr = i;
            #1;
            if (rs1_data === 0)
                $display("PASS: After reset, register %d = 0", i);
            else
                $display("FAIL: After reset, register %d = %h (expected 0)", i, rs1_data);
        end
        reset = 0;
        
        $display("All tests completed");
        $finish;
    end
endmodule
