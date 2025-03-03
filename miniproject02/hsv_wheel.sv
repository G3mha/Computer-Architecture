module hsv_wheel #(
    parameter CLK_FREQ = 12_000_000 // 12MHz
)(
    input  logic clk,
    output logic red_led,
    output logic green_led,
    output logic blue_led
);
    localparam TOTAL_STEPS = 360;
    localparam CYCLES_PER_STEP = CLK_FREQ / TOTAL_STEPS;

    logic [$clog2(CYCLES_PER_STEP)-1:0] cycle_counter = 0;
    logic [8:0]  step_counter  = 0;  // 2^8 = 512 (0 to 359)

    logic [7:0] red_value;
    logic [7:0] green_value;
    logic [7:0] blue_value;

    always_ff @(posedge clk) begin
        if (cycle_counter >= CYCLES_PER_STEP - 1) begin
            cycle_counter <= 0;
            if (step_counter >= TOTAL_STEPS - 1)
                step_counter <= 0;
            else
                step_counter <= step_counter + 1;
        end 
        else begin
            cycle_counter <= cycle_counter + 1;
        end
    end
    
    logic [8:0] region;
    logic [7:0] remainder, p, q, t;

    always_comb begin
        region = step_counter / 60; // Dvidide into 6 regions (0-5)
        remainder = step_counter % 60; // Position within the region (0-59)
        p = 8'd0; // Min component value (S=100%)
        q = 8'd255 - ((remainder * 255) / 60); // Descending
        t = ((remainder * 255) / 60); // Ascending
        
        case (region) // HSV to RGB
            0: begin red_value = 8'd255; green_value = t;      blue_value = p;      end
            1: begin red_value = q;      green_value = 8'd255; blue_value = p;      end
            2: begin red_value = p;      green_value = 8'd255; blue_value = t;      end
            3: begin red_value = p;      green_value = q;      blue_value = 8'd255; end
            4: begin red_value = t;      green_value = p;      blue_value = 8'd255; end
            5: begin red_value = 8'd255; green_value = p;      blue_value = q;      end
            default: begin red_value = 8'd255; green_value = 8'd0; blue_value = 8'd0; end
        endcase
    end
    
    pwm red_pwm (
        .clk(clk),
        .duty(red_value),
        .pwm_out(red_led)
    );
    
    pwm green_pwm (
        .clk(clk),
        .duty(green_value),
        .pwm_out(green_led)
    );
    
    pwm blue_pwm (
        .clk(clk),
        .duty(blue_value),
        .pwm_out(blue_led)
    );
endmodule
