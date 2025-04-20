// Instruction Memory Module
module instruction_memory #(
  parameter INIT_FILE = ""
)(
  input  logic [31:0] address,
  output logic [31:0] instruction
);

  // Memory array - increase to 2048 words to match the main memory
  logic [31:0] memory [0:2047];

  // Load memory contents from file
  initial begin
    if (INIT_FILE != "") begin
      $readmemh(INIT_FILE, memory);
    end
  end

  // Word-aligned access (divide address by 4)
  assign instruction = memory[address[31:2]];

endmodule
