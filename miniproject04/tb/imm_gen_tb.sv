`timescale 1ns/1ps

module imm_gen_tb;
    // Test signals
    logic [31:0] instruction;
    logic [31:0] ImmExt;
    logic [6:0]  Opcode;
    
    // Expected values
    logic [31:0] expected_imm;
    string test_name;
    int test_count = 0;
    int pass_count = 0;
    
    // Instantiate the ImmGen module
    ImmGen dut (
        .Opcode(Opcode),
        .instruction(instruction),
        .ImmExt(ImmExt)
    );
    
    // Assign opcode from instruction
    assign Opcode = instruction[6:0];
    
    // Task to check and report results
    task check_result;
        begin
            test_count++;
            if (ImmExt === expected_imm) begin
                $display("PASS: %s - Expected: 0x%h, Got: 0x%h", test_name, expected_imm, ImmExt);
                pass_count++;
            end else begin
                $display("FAIL: %s - Expected: 0x%h, Got: 0x%h", test_name, expected_imm, ImmExt);
            end
        end
    endtask
    
    // Test cases for different instruction types
    initial begin
        $display("Starting ImmGen Testbench");
        
        // I-type load instruction test
        test_name = "I-type (LW)";
        instruction = 32'h00A02503; // lw x10, 10(x0)
        expected_imm = 32'h0000000A; // 10 sign-extended to 32 bits
        #10 check_result();
        
        // I-type arithmetic test with positive immediate
        test_name = "I-type (ADDI) positive";
        instruction = 32'h01400513; // addi x10, x0, 20
        expected_imm = 32'h00000014; // 20 sign-extended to 32 bits
        #10 check_result();
        
        // I-type arithmetic test with negative immediate
        test_name = "I-type (ADDI) negative";
        instruction = 32'hFFF00513; // addi x10, x0, -1
        expected_imm = 32'hFFFFFFFF; // -1 sign-extended to 32 bits
        #10 check_result();
        
        // S-type store instruction test
        test_name = "S-type (SW)";
        instruction = 32'h00A02423; // sw x10, 8(x0)
        expected_imm = 32'h00000008; // 8 sign-extended to 32 bits
        #10 check_result();
        
        // B-type branch instruction test (positive offset)
        test_name = "B-type (BEQ) positive";
        instruction = 32'h00A50463; // beq x10, x10, 8
        expected_imm = 32'h00000008; // 8 sign-extended to 32 bits
        #10 check_result();
        
        // B-type branch instruction test (negative offset)
        test_name = "B-type (BEQ) negative";
        instruction = 32'hFE550CE3; // beq x10, x5, -8
        expected_imm = 32'hFFFFFFF8; // -8 sign-extended to 32 bits
        #10 check_result();
        
        // U-type LUI instruction test
        test_name = "U-type (LUI)";
        instruction = 32'h12345637; // lui x12, 0x12345
        expected_imm = 32'h12345000; // 0x12345 << 12
        #10 check_result();
        
        // U-type AUIPC instruction test
        test_name = "U-type (AUIPC)";
        instruction = 32'h12345617; // auipc x12, 0x12345
        expected_imm = 32'h12345000; // 0x12345 << 12
        #10 check_result();
        
        // J-type JAL instruction test (positive offset)
        test_name = "J-type (JAL) positive";
        instruction = 32'h004000EF; // jal x1, 4
        expected_imm = 32'h00000004; // 4 sign-extended to 32 bits
        #10 check_result();
        
        // J-type JAL instruction test (negative offset)
        test_name = "J-type (JAL) negative";
        instruction = 32'hFFC000EF; // jal x1, -4
        expected_imm = 32'hFFFFFFFC; // -4 sign-extended to 32 bits
        #10 check_result();
        
        // I-type JALR instruction test
        test_name = "I-type (JALR)";
        instruction = 32'h008580E7; // jalr x1, 8(x11)
        expected_imm = 32'h00000008; // 8 sign-extended to 32 bits
        #10 check_result();
        
        // Summary
        $display("\nTestbench Complete");
        $display("Passed: %0d / %0d tests", pass_count, test_count);
        if (pass_count == test_count)
            $display("ALL TESTS PASSED!");
        else
            $display("SOME TESTS FAILED!");
        
        $finish;
    end
    
    // Monitor
    initial begin
        $monitor("Time: %0t, Instruction: 0x%h, Opcode: 0x%h, ImmExt: 0x%h", 
                 $time, instruction, Opcode, ImmExt);
    end

endmodule
