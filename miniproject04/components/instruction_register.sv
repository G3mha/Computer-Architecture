module instruction_register(
    input  logic        clk,         // Clock signal
    input  logic        reset,       // Reset signal
    input  logic        ir_write,    // Enable writing to the instruction register
    input  logic [31:0] instruction_in, // Instruction from memory
    output logic [31:0] instruction_out  // Instruction to decoder/control logic
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            instruction_out <= 32'b0;
        end else if (ir_write) begin
            instruction_out <= instruction_in;
        end
    end

endmodule
