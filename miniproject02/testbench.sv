`timescale 1ns / 1ps
`include "top.sv"

module hsv_wheel_tb;
    logic clk;
    logic RGB_R;
    logic RGB_G;
    logic RGB_B;
    
    top top (
        .clk(clk),
        .RGB_R(RGB_R),
        .RGB_G(RGB_G),
        .RGB_B(RGB_B)
    );
    
    wire [7:0] red_value = top.hsv_wheel.red_value;
    wire [7:0] green_value = top.hsv_wheel.green_value;
    wire [7:0] blue_value = top.hsv_wheel.blue_value;
    wire [8:0] step_counter = top.hsv_wheel.step_counter;
    wire [8:0] region = top.hsv_wheel.region;

    initial begin
        clk = 0;
        forever #41.667 clk = ~clk; // half period (period = 83.33ns; 12MHz clock)
    end

    initial begin
        $dumpfile("hsv_wheel_tb.vcd"); // For waveform viewing
        $dumpvars(0, hsv_wheel_tb);
    end

    initial begin
        #1_200_000_000;
        $display("Simulation complete");
        $finish;
    end

    // Monitor important signals
    initial begin
        $monitor("Time: %t, Step: %d, Region: %d, RGB values: R=%d, G=%d, B=%d, LED outputs: R=%b, G=%b, B=%b", 
                 $time, step_counter, region, red_value, green_value, blue_value, RGB_R, RGB_G, RGB_B);
    end

endmodule
