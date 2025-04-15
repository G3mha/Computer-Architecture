module mux_4x1 #(
    parameter WIDTH = 32   // Default width is 32 bits
)(
    input  logic [WIDTH-1:0] in0,    // First input
    input  logic [WIDTH-1:0] in1,    // Second input
    input  logic [WIDTH-1:0] in2,    // Third input
    input  logic [WIDTH-1:0] in3,    // Fourth input
    input  logic [1:0]       sel,    // 2-bit select signal
    output logic [WIDTH-1:0] out     // Output
);

    always @(*) begin
        case (sel)
            2'b00: out = in0;
            2'b01: out = in1;
            2'b10: out = in2;
            2'b11: out = in3;
        endcase
    end
    
endmodule
