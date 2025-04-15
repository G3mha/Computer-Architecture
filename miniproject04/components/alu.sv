module alu(
    input  logic [31:0] a,          // First operand
    input  logic [31:0] b,          // Second operand
    input  logic [3:0]  alu_op,
    output logic [31:0] result,
    output logic        zero_flag   // Zero flag (for branch operations)
);

    // ALU operation codes
    localparam ALU_ADD  = 4'b0000;  // Addition
    localparam ALU_SUB  = 4'b0001;  // Subtraction
    localparam ALU_AND  = 4'b0010;  // Bitwise AND
    localparam ALU_OR   = 4'b0011;  // Bitwise OR
    localparam ALU_XOR  = 4'b0100;  // Bitwise XOR
    localparam ALU_SLL  = 4'b0101;  // Shift left logical
    localparam ALU_SRL  = 4'b0110;  // Shift right logical
    localparam ALU_SRA  = 4'b0111;  // Shift right arithmetic
    localparam ALU_SLT  = 4'b1000;  // Set less than (signed)
    localparam ALU_SLTU = 4'b1001;  // Set less than (unsigned)

    // Result MUX
    always @(*) begin
        case (alu_op)
            ALU_ADD:  result = a + b;
            ALU_SUB:  result = a - b;
            ALU_AND:  result = a & b;
            ALU_OR:   result = a | b;
            ALU_XOR:  result = a ^ b;
            ALU_SLL:  result = a << b[4:0];  // Only use lower 5 bits for shift amount
            ALU_SRL:  result = a >> b[4:0];
            ALU_SRA:  result = $signed(a) >>> b[4:0];
            ALU_SLT:  result = {31'b0, $signed(a) < $signed(b)};
            ALU_SLTU: result = {31'b0, a < b};
            default:  result = 32'b0;
        endcase
    end

    // Zero flag
    assign zero_flag = (result == 32'b0);

endmodule
