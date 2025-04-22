module ImmGen (
    input  logic [6:0]  Opcode,
    input  logic [31:0] instruction,
    output logic [31:0] ImmExt
);

    always @(*) begin
        case (Opcode)
            7'b0000011, // I-type (e.g., LW)
            7'b0010011, // I-type (e.g., ADDI)
            7'b1100111: // I-type (e.g., JALR)
                ImmExt = {{20{instruction[31]}}, instruction[31:20]};

            7'b0100011: // S-type (e.g., SW)
                ImmExt = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};

            7'b1100011: // B-type (e.g., BEQ, BNE)
                ImmExt = {
                    {19{instruction[31]}},
                    instruction[31],       // imm[12]
                    instruction[7],        // imm[11]
                    instruction[30:25],    // imm[10:5]
                    instruction[11:8],     // imm[4:1]
                    1'b0                   // imm[0] (LSB)
                };

            7'b0010111, // U-type (AUIPC)
            7'b0110111: // U-type (LUI)
                ImmExt = {instruction[31:12], 12'b0};

            7'b1101111: // J-type (JAL)
                ImmExt = {
                  {12{instruction[31]}}, // Sign extension (12 bits)
                  instruction[19:12],    // imm[19:12]
                  instruction[20],       // imm[11]
                  instruction[30:21],    // imm[10:1]
                  1'b0                   // imm[0] (LSB)
                };

            default:
                ImmExt = 32'b0;
        endcase

    end

endmodule
