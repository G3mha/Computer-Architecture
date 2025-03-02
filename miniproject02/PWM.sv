module pwm #(
    parameter PWM_WIDTH = 8
)(
    input  logic clk,
    input  logic [7:0] duty_cycle,
    output logic pwm_signal
);
    logic [PWM_WIDTH-1:0] counter = 0;

    always_ff @(posedge clk) begin
        counter <= counter + 1;
    end

    assign pwm_signal = (counter < duty_cycle);
endmodule
