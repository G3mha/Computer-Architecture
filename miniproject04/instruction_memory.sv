// Instruction Memory Module
module instruction_memory (
  input  logic [31:0] address,
  output logic [31:0] instruction
);

  // Memory array
  logic [31:0] memory [0:255];

  // Load memory contents from file
  initial begin
    $readmemh("program.mem", memory);
  end

  // Word-aligned access (divide address by 4)
  assign instruction = memory[address[31:2]];

endmodule
