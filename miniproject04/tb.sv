// Testbench for RV32I Single-Cycle Processor Top Module

`timescale 10ns/10ns
`include "top.sv"


module tb_top;

    // Clock and reset
    logic clk;
    logic reset;

    // Instantiate the top module
    top dut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation: 10ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Stimulus
    initial begin
        // Dump waves for GTKWave
        $dumpfile("top_tb.vcd");
        $dumpvars(0, tb_top);

        // Initial reset
        reset = 1;
        #20;
        reset = 0;

        // Run simulation for 300ns
        #300;
        $display("Finished simulation.");
        $finish;
    end

endmodule
