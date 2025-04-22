// RV32I memory module
//
// Implements 8kB of actual memory in the address range of 0x00000000 to
// 0x00001FFF, which can be written to or read from in words (4 bytes), 
// half words (2 bytes), or single bytes. Word accesses are aligned to four-byte 
// boundaries, and half-word access are aligned to two-byte boundaries.
// Half-word and sigle-byte reads are either sign extended or zero extended to 
// 32 bits, depending on the msb of funct3. The value of funct3 should be 3'b010 
// when fetching instructions as it is during execution of lw / sw instructions. 
// Addresses outside of the physical address space are read as 32'd0. The memory 
// can be initialized by specifying via the INIT_FILE parameter the name of a 
// text file containing 2,048 lines of 32-bit hex values. If no file name is 
// specified, the memory is initialized to all 0s.
//
// The memory module also implements some memory-mapped peripherals: 8-bit PWM 
// generators for each of the user LED (0xFFFFFFFF, R/W), RED (0xFFFFFFFE, R/W), 
// GREEN (0xFFFFFFFD, R/W), and BLUE (0xFFFFFFFC, R/W), a running timer that 
// counts the number of milliseconds (mod 2^32) since the processor 
// started (0xFFFFFFF8, R), and a running timer that counts the number of 
// microseconds (mod 2^32) since the processor started (0xFFFFFFF4, R).

module memory #(
    parameter INIT_FILE = ""
)(
    input  logic         clk,
    input  logic         mem_read,    // Read enable for data
    input  logic         mem_write,   // Write enable for data
    input  logic [31:0]  address,     // Address for instruction fetch or data access
    input  logic [31:0]  write_data,  // Data to write
    input  logic [2:0]   funct3,      // Function code for data access
    output logic [31:0]  read_data,   // Data read
    output logic [31:0]  instruction, // Instruction fetched
    output logic         led,         // Active-high PWM output for user LED
    output logic         red,         // Active-high PWM output for red LED
    output logic         green,       // Active-high PWM output for green LED
    output logic         blue         // Active-high PWM output for blue LED
);

    logic [31:0] mem [0:2047]; // Unified memory array (8kB)
    logic [31:0] read_value = 32'd0;

    // Declare variables associated with memory-mapped peripherals
    logic [31:0] leds = 32'd0;      // Address 0xFFFFFFFC, R/W, four 8-bit PWM duty-cycle values for the user LED and the RGB LEDs
    logic [31:0] millis = 32'd0;    // Address 0xFFFFFFF8, R, count of milliseconds since processor started (mod 2^32)
    logic [31:0] micros = 32'd0;    // Address 0xFFFFFFF4, R, count of microseconds since processor started (mod 2^32)

    logic [7:0] pwm_counter = 8'd0;
    logic [13:0] millis_counter = 14'd0;
    logic [3:0] micros_counter = 4'd0;

    // Declare variables for data access
    logic [15:0] read_value10;
    logic [15:0] read_value32;
    logic [7:0] read_value0;
    logic [7:0] read_value1;
    logic [7:0] read_value2;
    logic [7:0] read_value3;
    logic sign_bit0;
    logic sign_bit1;
    logic sign_bit2;
    logic sign_bit3;

    // Initialize memory array
    initial begin
        // First initialize all memory to zero
        for (int i = 0; i < 2048; i++) begin
            mem[i] = 32'd0;
        end
        
        // Then read from file if specified
        if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, mem);
        end
    end

    // Fetch instruction (always enabled)
    assign instruction = mem[address[12:2]];

    // Handle memory reads
    always_ff @(posedge clk) begin
        if (address[31:13] == 19'd0) begin
            read_value <= mem[address[12:2]];
        end else if (address[31:13] == 19'h7FFFF) begin
            case (address[12:2])
                11'h7FF: read_value <= leds;
                11'h7FE: read_value <= millis;
                11'h7FD: read_value <= micros;
                default: read_value <= 32'd0;
            endcase
        end else begin
            read_value <= 32'd0;
        end
    end

    // Data read logic
    assign read_data = (mem_read) ? read_value : 32'b0;

    // Handle memory writes
    always_ff @(posedge clk) begin
        if (mem_write) begin
            if (address[31:13] == 19'd0) begin
                if (funct3[1]) begin
                    mem[address[12:2]] <= write_data;
                end else if (funct3[0]) begin
                    if (address[1])
                        mem[address[12:2]][31:16] <= write_data[15:0];
                    else
                        mem[address[12:2]][15:0] <= write_data[15:0];
                end else begin
                    case (address[1:0])
                        2'b00: mem[address[12:2]][7:0] <= write_data[7:0];
                        2'b01: mem[address[12:2]][15:8] <= write_data[7:0];
                        2'b10: mem[address[12:2]][23:16] <= write_data[7:0];
                        2'b11: mem[address[12:2]][31:24] <= write_data[7:0];
                    endcase
                end
            end else if (address[31:2] == 30'h3FFFFFFF) begin
                if (funct3[1]) begin
                    leds <= write_data;
                end else if (funct3[0]) begin
                    if (address[1])
                        leds[31:16] <= write_data[15:0];
                    else
                        leds[15:0] <= write_data[15:0];
                end else begin
                    case (address[1:0])
                        2'b00: leds[7:0] <= write_data[7:0];
                        2'b01: leds[15:8] <= write_data[7:0];
                        2'b10: leds[23:16] <= write_data[7:0];
                        2'b11: leds[31:24] <= write_data[7:0];
                    endcase
                end
            end
        end
    end

    // Implement PWM control for LED / RGB outputs
    always_ff @(posedge clk) begin
        pwm_counter <= pwm_counter + 1;
    end

    assign led = (pwm_counter < leds[31:24]);
    assign red = (pwm_counter < leds[23:16]);
    assign green = (pwm_counter < leds[15:8]);
    assign blue = (pwm_counter < leds[7:0]);

    // Implement millis counter
    always_ff @(posedge clk) begin
        if (millis_counter == 11999) begin
            millis_counter <= 14'd0;
            millis <= millis + 1;
        end else begin
            millis_counter <= millis_counter + 1;
        end
    end

    // Implement micros counter
    always_ff @(posedge clk) begin
        if (micros_counter == 11) begin
            micros_counter <= 4'd0;
            micros <= micros + 1;
        end else begin
            micros_counter <= micros_counter + 1;
        end
    end
endmodule
