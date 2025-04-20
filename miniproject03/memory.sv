module memory #(
    parameter INIT_FILE = ""
)(
    input  logic       clk,
    input  logic [6:0] read_address, // 2^7 = 128 addresses
    output logic [9:0] read_data
);
    logic [9:0] sample_memory [0:127]; // Array 128 10-bit

    if (INIT_FILE != "") begin
        $readmemh(INIT_FILE, sample_memory);
    end

    always_ff @(posedge clk) begin
        read_data <= sample_memory[read_address];
    end
endmodule
