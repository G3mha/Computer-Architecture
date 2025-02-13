module top(
    input logic     clk,
    output logic    RGB_R,
    output logic    RGB_G,
    output logic    RGB_B
);
    typedef enum logic [2:0] {
        RED,
        YELLOW,
        GREEN,
        CYAN,
        BLUE,
        MAGENTA
    } state_t;
    
    state_t state = RED;
    parameter COLOR_INTERVAL = 2000000; // 12MHz clock
    parameter PWM_INTERVAL = 120;       // Fix yellow brightness (too green before)
    logic [$clog2(COLOR_INTERVAL)-1:0] count;
    logic [$clog2(PWM_INTERVAL)-1:0] pwm_count;

    always_ff @(posedge clk) begin // Edge of the clock
        if (count == COLOR_INTERVAL - 1) begin
            count <= 0;
            case (state)
                RED:     state <= YELLOW;
                YELLOW:  state <= GREEN;
                GREEN:   state <= CYAN;
                CYAN:    state <= BLUE;
                BLUE:    state <= MAGENTA;
                MAGENTA: state <= RED;
            endcase
        end
        else begin
            count <= count + 1;
        end
        
        if (pwm_count == PWM_INTERVAL - 1)
            pwm_count <= 0;
        else
            pwm_count <= pwm_count + 1;
    end

    always_comb begin
        // 0 = on, 1 = off (active low)
        case (state)
            RED: begin
                RGB_R = 0;
                RGB_G = 1;
                RGB_B = 1;
            end
            YELLOW: begin
                RGB_R = 0;
                RGB_G = (pwm_count < PWM_INTERVAL/2);
                RGB_B = 1;
            end
            GREEN: begin
                RGB_R = 1;
                RGB_G = 0;
                RGB_B = 1;
            end
            CYAN: begin
                RGB_R = 1;
                RGB_G = 0;
                RGB_B = 0;
            end
            BLUE: begin
                RGB_R = 1;
                RGB_G = 1;
                RGB_B = 0;
            end
            MAGENTA: begin
                RGB_R = 0;
                RGB_G = 1;
                RGB_B = 0;
            end
            default: begin
                RGB_R = 1;
                RGB_G = 1;
                RGB_B = 1;
            end
        endcase
    end
endmodule
