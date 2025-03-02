module PWM #(
    parameter WIDTH = 8, // PWM resolution
    parameter ACTIVE_LOW = 1
)(
    input  logic clk,
    input  logic [WIDTH-1:0] duty,
    output logic pwm_out
);
    logic [WIDTH-1:0] counter;

    always_ff @(posedge clk) begin
        counter <= counter + 1;
    end
    
    always_comb begin
        if (ACTIVE_LOW)
            pwm_out = (counter < duty) ? 1'b0 : 1'b1;
        else
            pwm_out = (counter < duty) ? 1'b1 : 1'b0;
    end
endmodule
