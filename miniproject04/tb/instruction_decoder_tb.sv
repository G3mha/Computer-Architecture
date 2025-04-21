`timescale 1ns/1ps

module instruction_decoder_tb;
    // Test signals
    logic [31:0] instruction;
    logic [3:0]  alu_op;
    logic        reg_write;
    logic [1:0]  alu_src;
    logic        mem_read;
    logic        mem_write;
    logic [1:0]  mem_to_reg;
    logic        branch;
    logic        jump;

    // Expected output signals
    logic [3:0]  exp_alu_op;
    logic        exp_reg_write;
    logic [1:0]  exp_alu_src;
    logic        exp_mem_read;
    logic        exp_mem_write;
    logic [1:0]  exp_mem_to_reg;
    logic        exp_branch;
    logic        exp_jump;

    // Test tracking
    string test_name;
    int test_count = 0;
    int pass_count = 0;

    // Instantiate the instruction_decoder (DUT)
    instruction_decoder dut (
        .instruction(instruction),
        .alu_op(alu_op),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .jump(jump)
    );

    // Task to check and report results
    task check_result;
        begin
            test_count++;
            
            if (alu_op === exp_alu_op &&
                reg_write === exp_reg_write &&
                alu_src === exp_alu_src &&
                mem_read === exp_mem_read &&
                mem_write === exp_mem_write &&
                mem_to_reg === exp_mem_to_reg &&
                branch === exp_branch &&
                jump === exp_jump) 
            begin
                $display("PASS: %s", test_name);
                pass_count++;
            end 
            else 
            begin
                $display("FAIL: %s", test_name);
                $display("  Expected: alu_op=%b, reg_write=%b, alu_src=%b, mem_read=%b, mem_write=%b, mem_to_reg=%b, branch=%b, jump=%b",
                         exp_alu_op, exp_reg_write, exp_alu_src, exp_mem_read, exp_mem_write, exp_mem_to_reg, exp_branch, exp_jump);
                $display("  Got:      alu_op=%b, reg_write=%b, alu_src=%b, mem_read=%b, mem_write=%b, mem_to_reg=%b, branch=%b, jump=%b",
                         alu_op, reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, jump);
            end
        end
    endtask

    // Define ALU operation codes
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

    // Main test sequence
    initial begin
        $display("Starting Instruction Decoder Testbench");
        
        // R-type: ADD
        test_name = "R-type (ADD)";
        instruction = 32'h00208033;  // add x0, x1, x2
        exp_alu_op = ALU_ADD;
        exp_reg_write = 1'b1;
        exp_alu_src = 2'b00;         // Use rs1_data and rs2_data
        exp_mem_read = 1'b0;
        exp_mem_write = 1'b0;
        exp_mem_to_reg = 2'b01;      // Select ALU result
        exp_branch = 1'b0;
        exp_jump = 1'b0;
        #10 check_result();
        
        // R-type: SUB
        test_name = "R-type (SUB)";
        instruction = 32'h40208033;  // sub x0, x1, x2
        exp_alu_op = ALU_SUB;
        exp_reg_write = 1'b1;
        exp_alu_src = 2'b00;
        exp_mem_read = 1'b0;
        exp_mem_write = 1'b0;
        exp_mem_to_reg = 2'b01;
        exp_branch = 1'b0;
        exp_jump = 1'b0;
        #10 check_result();
        
        // R-type: AND
        test_name = "R-type (AND)";
        instruction = 32'h00207033;  // and x0, x0, x2
        exp_alu_op = ALU_AND;
        exp_reg_write = 1'b1;
        exp_alu_src = 2'b00;
        exp_mem_read = 1'b0;
        exp_mem_write = 1'b0;
        exp_mem_to_reg = 2'b01;
        exp_branch = 1'b0;
        exp_jump = 1'b0;
        #10 check_result();
        
        // I-type arithmetic: ADDI
        test_name = "I-type (ADDI)";
        instruction = 32'h00208093;  // addi x1, x1, 2
        exp_alu_op = ALU_ADD;
        exp_reg_write = 1'b1;
        exp_alu_src = 2'b10;         // Use rs1_data and imm_ext
        exp_mem_read = 1'b0;
        exp_mem_write = 1'b0;
        exp_mem_to_reg = 2'b01;
        exp_branch = 1'b0;
        exp_jump = 1'b0;
        #10 check_result();
        
        // I-type load: LW
        test_name = "I-type (LW)";
        instruction = 32'h00202083;  // lw x1, 2(x0)
        exp_alu_op = ALU_ADD;
        exp_reg_write = 1'b1;
        exp_alu_src = 2'b10;
        exp_mem_read = 1'b1;
        exp_mem_write = 1'b0;
        exp_mem_to_reg = 2'b11;      // Select memory data
        exp_branch = 1'b0;
        exp_jump = 1'b0;
        #10 check_result();
        
        // S-type: SW
        test_name = "S-type (SW)";
        instruction = 32'h00202023;  // sw x2, 0(x0)
        exp_alu_op = ALU_ADD;
        exp_reg_write = 1'b0;
        exp_alu_src = 2'b10;
        exp_mem_read = 1'b0;
        exp_mem_write = 1'b1;
        exp_mem_to_reg = 2'b00;      // Not used for store
        exp_branch = 1'b0;
        exp_jump = 1'b0;
        #10 check_result();
        
        // B-type: BEQ
        test_name = "B-type (BEQ)";
        instruction = 32'h00208063;  // beq x1, x2, 0
        exp_alu_op = ALU_SUB;        // Subtraction for comparison
        exp_reg_write = 1'b0;
        exp_alu_src = 2'b00;
        exp_mem_read = 1'b0;
        exp_mem_write = 1'b0;
        exp_mem_to_reg = 2'b00;
        exp_branch = 1'b1;
        exp_jump = 1'b0;
        #10 check_result();
        
        // U-type: LUI
        test_name = "U-type (LUI)";
        instruction = 32'h123450B7;  // lui x1, 0x12345
        exp_alu_op = ALU_ADD;
        exp_reg_write = 1'b1;
        exp_alu_src = 2'b00;
        exp_mem_read = 1'b0;
        exp_mem_write = 1'b0;
        exp_mem_to_reg = 2'b00;      // Select immediate value
        exp_branch = 1'b0;
        exp_jump = 1'b0;
        #10 check_result();
        
        // U-type: AUIPC
        test_name = "U-type (AUIPC)";
        instruction = 32'h12345097;  // auipc x1, 0x12345
        exp_alu_op = ALU_ADD;
        exp_reg_write = 1'b1;
        exp_alu_src = 2'b11;         // Use PC and imm_ext
        exp_mem_read = 1'b0;
        exp_mem_write = 1'b0;
        exp_mem_to_reg = 2'b01;
        exp_branch = 1'b0;
        exp_jump = 1'b0;
        #10 check_result();
        
        // J-type: JAL
        test_name = "J-type (JAL)";
        instruction = 32'h004000EF;  // jal x1, 4
        exp_alu_op = ALU_ADD;
        exp_reg_write = 1'b1;
        exp_alu_src = 2'b11;
        exp_mem_read = 1'b0;
        exp_mem_write = 1'b0;
        exp_mem_to_reg = 2'b10;      // Select PC+4
        exp_branch = 1'b0;
        exp_jump = 1'b1;
        #10 check_result();
        
        // I-type: JALR
        test_name = "I-type (JALR)";
        instruction = 32'h000080E7;  // jalr x1, 0(x1)
        exp_alu_op = ALU_ADD;
        exp_reg_write = 1'b1;
        exp_alu_src = 2'b10;
        exp_mem_read = 1'b0;
        exp_mem_write = 1'b0;
        exp_mem_to_reg = 2'b10;
        exp_branch = 1'b0;
        exp_jump = 1'b1;
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
    
    // Monitor changes in signals
    initial begin
        $monitor("Time: %0t, Instruction: 0x%h", $time, instruction);
    end

endmodule
