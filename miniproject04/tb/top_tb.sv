module top_tb;
    // Declare signals
    logic clk;
    logic reset;

    // Instantiate the top module
    top uut (
        .clk(clk),
        .reset(reset)
        // Connect other ports as needed
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 10ns clock period

    // Reset signal
    initial begin
        reset = 1;
        #20 reset = 0; // Deassert reset after 20ns
    end

    // Dump waveforms
    initial begin
        $dumpfile("sim/top_tb.vcd");
        $dumpvars(0, top_tb);
    end

    // End simulation after a certain time
    initial begin
        #1000; // Adjust simulation time as needed
        $finish;
    end
endmodule