`timescale 1ns/1ps

module alu_tb;
    // Inputs and outputs
    logic [31:0] a, b;
    logic [3:0] alu_op;
    logic [31:0] result;
    logic zero_flag;
    
    // ALU operation codes (must match those in alu.sv)
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
    
    // Instantiate the ALU module
    alu dut (
        .a(a),
        .b(b),
        .alu_op(alu_op),
        .result(result),
        .zero_flag(zero_flag)
    );
    
    // Test tasks for each operation
    task test_add(input logic [31:0] op1, input logic [31:0] op2);
        begin
            a = op1;
            b = op2;
            alu_op = ALU_ADD;
            #10;
            $display("ADD: %d + %d = %d", op1, op2, result);
            assert(result == op1 + op2) else $error("ADD failed: got %d, expected %d", result, op1 + op2);
        end
    endtask
    
    task test_sub(input logic [31:0] op1, input logic [31:0] op2);
        begin
            a = op1;
            b = op2;
            alu_op = ALU_SUB;
            #10;
            $display("SUB: %d - %d = %d", op1, op2, result);
            assert(result == op1 - op2) else $error("SUB failed: got %d, expected %d", result, op1 - op2);
        end
    endtask
    
    task test_and(input logic [31:0] op1, input logic [31:0] op2);
        begin
            a = op1;
            b = op2;
            alu_op = ALU_AND;
            #10;
            $display("AND: 0x%h & 0x%h = 0x%h", op1, op2, result);
            assert(result == (op1 & op2)) else $error("AND failed");
        end
    endtask
    
    task test_or(input logic [31:0] op1, input logic [31:0] op2);
        begin
            a = op1;
            b = op2;
            alu_op = ALU_OR;
            #10;
            $display("OR: 0x%h | 0x%h = 0x%h", op1, op2, result);
            assert(result == (op1 | op2)) else $error("OR failed");
        end
    endtask
    
    task test_xor(input logic [31:0] op1, input logic [31:0] op2);
        begin
            a = op1;
            b = op2;
            alu_op = ALU_XOR;
            #10;
            $display("XOR: 0x%h ^ 0x%h = 0x%h", op1, op2, result);
            assert(result == (op1 ^ op2)) else $error("XOR failed");
        end
    endtask
    
    task test_sll(input logic [31:0] op1, input logic [31:0] op2);
        begin
            a = op1;
            b = op2;
            alu_op = ALU_SLL;
            #10;
            $display("SLL: 0x%h << %d = 0x%h", op1, op2[4:0], result);
            assert(result == (op1 << op2[4:0])) else $error("SLL failed");
        end
    endtask
    
    task test_srl(input logic [31:0] op1, input logic [31:0] op2);
        begin
            a = op1;
            b = op2;
            alu_op = ALU_SRL;
            #10;
            $display("SRL: 0x%h >> %d = 0x%h", op1, op2[4:0], result);
            assert(result == (op1 >> op2[4:0])) else $error("SRL failed");
        end
    endtask
    
    task test_sra(input logic [31:0] op1, input logic [31:0] op2);
        begin
            logic [31:0] expected;  // Moved declaration to beginning of block
            a = op1;
            b = op2;
            alu_op = ALU_SRA;
            #10;
            expected = $signed(op1) >>> op2[4:0];  // Separate assignment
            $display("SRA: 0x%h >>> %d = 0x%h", op1, op2[4:0], result);
            assert(result == expected) else $error("SRA failed: expected 0x%h, got 0x%h", expected, result);
        end
    endtask
    
    task test_slt(input logic [31:0] op1, input logic [31:0] op2);
        begin
            a = op1;
            b = op2;
            alu_op = ALU_SLT;
            #10;
            $display("SLT: %d < %d = %d", $signed(op1), $signed(op2), result);
            assert(result == ($signed(op1) < $signed(op2) ? 1 : 0)) else $error("SLT failed");
        end
    endtask
    
    task test_sltu(input logic [31:0] op1, input logic [31:0] op2);
        begin
            a = op1;
            b = op2;
            alu_op = ALU_SLTU;
            #10;
            $display("SLTU: %d < %d = %d", op1, op2, result);
            assert(result == (op1 < op2 ? 1 : 0)) else $error("SLTU failed");
        end
    endtask
    
    // Main test sequence
    initial begin
        $display("Starting ALU Testbench");
        
        // Test cases
        test_add(100, 50);
        test_add(32'hFFFFFFFF, 1);  // Test overflow
        
        test_sub(100, 50);
        test_sub(50, 100);  // Test negative result
        
        test_and(32'hAAAAAAAA, 32'h55555555);
        test_or(32'hAAAAAAAA, 32'h55555555);
        test_xor(32'hAAAAAAAA, 32'h55555555);
        
        test_sll(32'h1, 4);
        test_srl(32'h80000000, 4);
        test_sra(32'h80000000, 4);
        
        test_slt(10, 20);
        test_slt(20, 10);
        test_slt(-10, 10);
        
        test_sltu(10, 20);
        test_sltu(20, 10);
        test_sltu(0, 32'hFFFFFFFF);  // 0 < max unsigned value
        
        $display("All tests completed");
        $finish;
    end
endmodule
