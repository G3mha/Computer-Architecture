`timescale 10ns/10ns

module tb_top;
    // Clock and button signals
    logic        clk;
    logic        boot_n;
    logic        sw_n;

    // 10-bit DAC output bus
    logic [9:0]  dac_out;

    // Instantiate the top-level design
    top uut (
        .clk     (clk),
        .boot_n  (boot_n),
        .sw_n    (sw_n),
        .dac_out (dac_out)
    );

    // Clock generation: 10 ns period (100 MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Button stimulus
    // Both buttons are active-low (pressed = 0).
    initial begin
        // Initialize unpressed
        boot_n = 1;
        sw_n   = 1;

        // Let the design settle for 200 ns
        #20;

        // Press BOOT (cycle waveform)
        boot_n = 0;  
        #20;        // hold for two clock cycles
        boot_n = 1;
        
        // Wait a bit, then press SW (cycle frequency)
        #500;
        sw_n   = 0;
        #20;
        sw_n   = 1;

        // Press BOOT again
        #500;
        boot_n = 0;
        #20;
        boot_n = 1;

        // Add more presses as desired...
        #2000;

        // Finish simulation
        $finish;
    end

    // Dump waveforms for GTKWave
    initial begin
        $dumpfile("tb_top.vcd");
        $dumpvars(0, tb_top);
        #12000; // Adjust time as needed to capture the waveform
        $finish; // End simulation after 12 ms
    end
endmodule