module instruction_decoder(
    input  logic [31:0] instruction,    // Full 32-bit instruction
    output logic [3:0]  alu_op,         // Encoded ALU operation
    output logic        reg_write,      // Register file write enable
    output logic [1:0]  alu_src,        // ALU source selection
    output logic        mem_read,       // Memory read enable
    output logic        mem_write,      // Memory write enable
    output logic [1:0]  mem_to_reg,     // Memory to register routing
    output logic        branch,         // Branch instruction flag
    output logic        jump            // Jump instruction flag
);
    // Extract instruction fields
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    
    assign opcode = instruction[6:0];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];
    
    // Instruction decoder logic
    always_comb begin
        // Default control signals
        alu_op    = 4'b0000;  // ADD operation
        reg_write = 1'b0;
        alu_src   = 2'b00;
        mem_read  = 1'b0;
        mem_write = 1'b0;
        mem_to_reg = 2'b00;
        branch    = 1'b0;
        jump      = 1'b0;
        
        case (opcode)
            7'b0110011: begin // R-type instructions
                reg_write = 1'b1;
                alu_src   = 2'b00; //Use for R-type
                // Determine ALU operation based on funct3 and funct7
                case (funct3)
                    3'b000: alu_op = (funct7[5]) ? 4'b0001 : 4'b0000; // SUB : ADD
                    3'b001: alu_op = 4'b0101; // SLL
                    3'b010: alu_op = 4'b1000; // SLT
                    3'b011: alu_op = 4'b1001; // SLTU
                    3'b100: alu_op = 4'b0100; // XOR
                    3'b101: alu_op = (funct7[5]) ? 4'b0111 : 4'b0110; // SRA : SRL
                    3'b110: alu_op = 4'b0011; // OR
                    3'b111: alu_op = 4'b0010; // AND
                endcase
            end

            7'b0010011: begin // I-type instructions
                reg_write = 1'b1;
                alu_src   = 2'b01; // Use for immediate 
                case (funct3)
                    3'b000: alu_op = 4'b0000; // ADDI
                    3'b010: alu_op = 4'b1000; // SLTI
                    3'b011: alu_op = 4'b1001; // SLTIU
                    3'b100: alu_op = 4'b0100; // XORI
                    3'b110: alu_op = 4'b0011; // ORI
                    3'b111: alu_op = 4'b0010; // ANDI
                    3'b001: alu_op = 4'b; // SLLI




            // Add other instruction types (I-type, S-type, etc.)
            
        endcase
    end
endmodule
