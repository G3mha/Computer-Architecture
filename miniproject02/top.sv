`include "pwm.sv"
`include "hsv_wheel.sv"

module top (
    input  logic clk,
    output logic RGB_R,
    output logic RGB_G,
    output logic RGB_B
);
    logic red_led;
    logic green_led;
    logic blue_led;

    hsv_wheel hsv_wheel (
        .clk(clk),
        .red_led(red_led),
        .green_led(green_led),
        .blue_led(blue_led)
    );

    assign RGB_R = ~red_led;
    assign RGB_G = ~green_led;
    assign RGB_B = ~blue_led;
endmodule
