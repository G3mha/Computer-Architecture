module instruction_decoder (
    input  logic [31:0] instruction,
    input  logic [31:0] pc,        // Add this line
    input  logic [31:0] imm_ext,   // Add this line
    output logic [3:0]  alu_op,
    output logic        reg_write,
    output logic [1:0]  alu_src,
    output logic        mem_read,
    output logic        mem_write,
    output logic [1:0]  mem_to_reg,
    output logic        branch,
    output logic        jump
);
    // Extract instruction fields
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    
    assign opcode = instruction[6:0];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];
    
    // Instruction decoder logic
    always @(*) begin
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
                alu_src   = 2'b00;  // Use rs1_data and rs2_data
                mem_to_reg = 2'b01; // Select ALU result
                
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

            7'b0010011: begin // I-type arithmetic instructions
                reg_write = 1'b1;
                alu_src   = 2'b10;  // Use rs1_data and imm_ext
                mem_to_reg = 2'b01; // Select ALU result
                
                case (funct3)
                    3'b000: alu_op = 4'b0000; // ADDI
                    3'b001: alu_op = 4'b0101; // SLLI
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
                alu_src   = 2'b10;  // Use rs1_data and imm_ext
                alu_op    = 4'b0000; // ADD for address calculation
                mem_read  = 1'b1;    // Enable memory read
                mem_write = 1'b0;    // Disable memory write
                mem_to_reg = 2'b11;  // Select memory data
            end

            7'b0100011: begin // S-type instructions (Store instructions, e.g., SW)
                reg_write = 1'b0;    // No register write
                alu_src   = 2'b10;   // Use rs1_data and imm_ext
                alu_op    = 4'b0000; // ADD for address calculation
                mem_read  = 1'b0;    // Disable memory read
                mem_write = 1'b1;    // Enable memory write
                mem_to_reg = 2'b00;  // Not used for store
            end

            7'b1100011: begin // B-type instructions
                reg_write = 1'b0;    // No register write
                alu_src   = 2'b00;   // Use rs1_data and rs2_data
                mem_read  = 1'b0;    // No memory access
                mem_write = 1'b0;    // No memory access
                mem_to_reg = 2'b00;  // Not used for branch
                branch    = 1'b1;    // Enable branch

                case (funct3)
                    3'b000: alu_op = 4'b0001; // BEQ - SUB for comparison
                    3'b001: alu_op = 4'b0001; // BNE - SUB for comparison 
                    3'b100: alu_op = 4'b1000; // BLT - SLT (signed less than)
                    3'b101: alu_op = 4'b1000; // BGE - SLT (result needs to be inverted)
                    3'b110: alu_op = 4'b1001; // BLTU - SLTU (unsigned less than)
                    3'b111: alu_op = 4'b1001; // BGEU - SLTU (result needs to be inverted)
                    default: alu_op = 4'b0001; // Default to SUB
                endcase
            end

            7'b0010111: begin // U-type instruction: AUIPC
                reg_write = 1'b1;    // Write to register
                alu_src   = 2'b11;   // Use PC and imm_ext
                alu_op    = 4'b0000; // ADD PC and immediate
                mem_read  = 1'b0;    // No memory access
                mem_write = 1'b0;    // No memory access
                mem_to_reg = 2'b01;  // Select ALU result
            end

            7'b0110111: begin // U-type instruction: LUI
                reg_write = 1'b1;    // Write to register
                alu_src   = 2'b00;   // Not used for ALU
                alu_op    = 4'b0000; // Not used
                mem_read  = 1'b0;    // No memory access
                mem_write = 1'b0;    // No memory access
                mem_to_reg = 2'b00;  // Select immediate value
            end

            7'b1101111: begin // J-type instruction: JAL
                reg_write = 1'b1;
                alu_src   = 2'b11;
                alu_op    = 4'b0000;
                mem_read  = 1'b0;
                mem_write = 1'b0;
                mem_to_reg = 2'b10;
                jump      = 1'b1;
            end

            7'b1100111: begin // I-type instruction: JALR
                reg_write = 1'b1;    // Write to register
                alu_src   = 2'b10;   // Use rs1_data and imm_ext
                alu_op    = 4'b0000; // ADD for target address calculation
                mem_read  = 1'b0;    // No memory access
                mem_write = 1'b0;    // No memory access
                mem_to_reg = 2'b10;  // Select PC+4
                jump      = 1'b1;    // Enable jump
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
