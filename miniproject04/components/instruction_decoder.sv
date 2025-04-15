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
                alu_src   = 2'b00; //Use for R-type to be changed 
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
                alu_src   = 2'b01; // Use for immediate  to be changed 
                case (funct3)
                    3'b000: alu_op = 4'b0000; // ADDI
                    3'b001: alu_op = 4'b1000; // SLLI
                    3'b010: alu_op = 4'b1000; // SLTI
                    3'b011: alu_op = 4'b1001; // SLTIU
                    3'b100: alu_op = 4'b0100; // XORI
                    3'b101: alu_op = (funct7[5]) ? 4'b0111 : 4'b0110; // SRAI:SRLI
                    3'b110: alu_op = 4'b0011; // ORI
                    3'b111: alu_op = 4'b0010; // ANDI
                endcase
            end

            7'b0000011: begin // I-type Load instructions (e.g., LW)
                reg_write = 1'b1;
                alu_src   = 2'b01;  // Use immediate to be changed

                alu_op    = 4'b0000;// load is add
                mem_read  = 1'b1;   //Load need read mem
                mem_write = 1'b0;   //Load no write mem
                mem_to_reg = 2'b11; // to be changed
            end

            7'b0100011: begin // S-type instructions (Store instructions, e.g., SW)
                reg_write = 1'b0;
                alu_src   = 2'b01;  // Use immediate to be changed

                alu_op    = 4'b0000;// store uses add 
                mem_read  = 1'b0;   //store no read mem
                mem_write = 1'b1;   //store need write mem
                mem_to_reg = 2'b00; // no need lah to be changed
            end

            7'b1100011: begin // B-type instructions
                reg_write = 1'b0;   // no need write
                alu_src   = 2'b00;  // Use for R-type to be changed

                alu_op    = 4'b0001;// SUB for branching 
                mem_read  = 1'b0;   // no mem
                mem_write = 1'b0;   // no mem
                mem_to_reg = 2'b00; // Not used to be changed
                branch    = 1'b1;   //branch 
            end

            7'b0010111: begin // U-type instruction: AUIPC
                reg_write = 1'b1;
                alu_src   = 2'b01; // Use immediate

                alu_op    = 4'b0000;// ADD since rd ← pc + imm u, pc ← pc+4
                mem_read  = 1'b0;   // no mem
                mem_write = 1'b0;   // no mem
                mem_to_reg = 2'b01; // to be changed 
            end

            7'b0110111: begin // U-type instruction: LUI
                reg_write = 1'b1;
                alu_src   = 2'b00; // Not used immed

                alu_op    = 4'b0000; // rd ← imm u, pc ← pc+4
                mem_read  = 1'b0;   //not used
                mem_write = 1'b0;   //not used
                mem_to_reg = 2'b00; // Directly use (from ImmGen) for register write-back to be changed 
            end

            7'b1101111: begin // J-type instruction: JAL
                reg_write = 1'b1;
                alu_src   = 2'b00; // Not used for ALU calculation

                alu_op    = 4'b0000; // Not used rd ← pc+4, pc ← pc+imm j
                mem_read  = 1'b0;   //not used
                mem_write = 1'b0;   //not used
                mem_to_reg = 2'b10; // Use PC+4 for register write-back to be changed
                jump      = 1'b1;
            end

            7'b1100111: begin // I-type instruction: JALR
                reg_write = 1'b1;
                alu_src   = 2'b01; // Use immediate to be changed

                alu_op    = 4'b0000; // ADD operation rd ← pc+4, pc ← (rs1+imm i) & ∼1
                mem_read  = 1'b0;   //not used
                mem_write = 1'b0;   //not used
                mem_to_reg = 2'b10; // Use PC+4 for register write-back to be changed
                jump      = 1'b1;
            end

            default: begin
                // Keep defaults: No operation if opcode is unrecognized
                reg_write = 1'b0;
                alu_src   = 2'b00;
                alu_op    = 4'b0000;
                mem_read  = 1'b0;
                mem_write = 1'b0;
                mem_to_reg = 2'b00;
                branch    = 1'b0;
                jump      = 1'b0;
            end

            
        endcase
    end
endmodule
