`include "memory.sv"

module top(
    input  logic clk, 
    output logic _9b,  // D0
    output logic _6a,  // D1
    output logic _4a,  // D2
    output logic _2a,  // D3
    output logic _0a,  // D4
    output logic _5a,  // D5
    output logic _3b,  // D6
    output logic _49a, // D7
    output logic _45a, // D8
    output logic _48b  // D9
);
    logic [8:0] address = 0; // 2^9 = 512 addresses [Full counter]
    logic [9:0] data;
    logic [6:0] quarter_address; // 2^7 = 128 addresses [Quarter counter]
    logic [1:0] quadrant; // 4 quadrants [512/128]
    logic [9:0] memory_data; 

    assign quadrant = address[8:7];

    always_comb begin
        case(quadrant)
            2'b00: quarter_address = address[6:0]; // Direct lookup
            2'b01: quarter_address = 7'd127 - address[6:0]; // Reversed lookup
            2'b10: quarter_address = address[6:0]; // Direct lookup
            2'b11: quarter_address = 7'd127 - address[6:0]; // Reversed lookup
        endcase
    end

    memory #(
        .INIT_FILE("sine.txt")
    ) u1 (
        .clk(clk),
        .read_address(quarter_address),
        .read_data(memory_data)
    );

    always_comb begin
        case(quadrant)
            2'b00, 2'b01: data = memory_data; // Direct lookup
            2'b10, 2'b11: data = 10'd1024 - memory_data; // Inversion
        endcase
    end

    always_ff @(posedge clk) begin
        address <= address + 1;
    end

    assign {_48b, _45a, _49a, _3b, _5a, _0a, _2a, _4a, _6a, _9b} = data;
endmodule
