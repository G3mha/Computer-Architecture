`timescale 10ns/10ns

module sine_gen(
    input  logic        clk,
    input  logic [8:0]   phase,    // 9-bit input: 0-511
    output logic [9:0]   out       // 10-bit output: centered around 512
);

    // Split phase into quadrant and index
    logic [1:0] quadrant;
    logic [6:0] quarter_address;
    logic [8:0] quarter_data;

    assign quadrant        = phase[8:7];
    assign quarter_address = (quadrant == 2'b01 || quadrant == 2'b11) ? (7'd127 - phase[6:0])
                                                                     : phase[6:0];

    // Quarter-cycle memory lookup
    memory_quarter #(
        .INIT_FILE("sine_quarter.txt")
    ) mem_inst (
        .clk(clk),
        .read_address(quarter_address),
        .read_data(quarter_data)
    );

    // Generate full-cycle sine from quarter lookup
    always_comb begin
        case (quadrant)
            2'b00, 2'b01: out = 10'd512 + quarter_data; // positive half
            2'b10, 2'b11: out = 10'd512 - quarter_data; // negative half
            default:      out = 10'd512;
        endcase
    end

endmodule
