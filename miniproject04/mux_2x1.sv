module mux_2x1 #(
    parameter WIDTH = 32   // Default width is 32 bits
)(
    input  logic [WIDTH-1:0] in0,    // First input
    input  logic [WIDTH-1:0] in1,    // Second input
    input  logic             sel,    // Select signal (0=in0, 1=in1)
    output logic [WIDTH-1:0] out     // Output
);

    assign out = sel ? in1 : in0;

endmodule
