module program_counter(
    input  logic        clk,        // Clock input
    input  logic        rst,        // Reset signal
    input  logic        pc_write,   // Enable writing to PC
    input  logic [31:0] next_pc,    // Next PC value
    output logic [31:0] pc          // Current PC value
);
    
    // Program counter register
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            pc <= 32'h00000000;  // Reset to beginning of memory
        else if (pc_write)
            pc <= next_pc;       // Update PC with next address
    end
    
endmodule
