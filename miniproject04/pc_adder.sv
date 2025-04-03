module pc_adder(
    input  logic [31:0] pc,         // Current PC value
    output logic [31:0] pc_plus_4   // PC + 4 value
);
    
    // Simple adder to increment PC by 4 (word alignment)
    assign pc_plus_4 = pc + 32'd4;
    
endmodule
