`timescale 10ns/10ns

module top(
    input  logic       clk,         // 12 MHz board oscillator
    input  logic       boot_n,      // BOOT button (active low)
    input  logic       sw_n,        //  SW  button (active low)
    output logic [9:0] dac_out      // 10-bit to R-2R ladder
);

  //  Button Synchronizers & Edge Detectors
  logic boot_sync0, boot_sync1, boot_r;
  logic sw_sync0,   sw_sync1,   sw_r;

  // two-stage sync + invert active-low
  always_ff @(posedge clk) begin
    boot_sync0 <= ~boot_n;
    boot_sync1 <= boot_sync0;
    sw_sync0   <= ~sw_n;
    sw_sync1   <= sw_sync0;
  end

  // detect rising edge (button press)
  always_ff @(posedge clk) begin
    boot_r <= boot_sync1 & ~boot_r;
    sw_r   <= sw_sync1   & ~sw_r;
  end


  // waveform: 00=sine, 01=triangle, 10=square
  logic [1:0] waveform_sel = 2'b00;  
  // freq index: 0->1 kHz, 1->2 kHz, 2->5 kHz, 3->10 kHz
  logic [1:0] freq_sel     = 2'b00;  

  always_ff @(posedge clk) begin
    if (boot_r) waveform_sel <= (waveform_sel == 2'd2) ? 2'd0 : waveform_sel + 1;
    if ( sw_r)   freq_sel     <= (freq_sel     == 2'd3) ? 2'd0 : freq_sel     + 1;
  end

  
  // sample clock = 12 MHz
  localparam PH1 = 32'd357_913;   // ~1 kHz 
  localparam PH2 = 32'd715_827;   // ~2 kHz
  localparam PH5 = 32'd1_789_574; // ~5 kHz
  localparam PH10= 32'd3_578_139; // ~10 kHz

  logic [31:0] phase_inc;
  always_comb begin
    case (freq_sel)
      2'd0: phase_inc = PH1;
      2'd1: phase_inc = PH2;
      2'd2: phase_inc = PH5;
      2'd3: phase_inc = PH10;
      default: phase_inc = PH1;
    endcase
  end


  logic [31:0] phase_acc = 32'd0;

  always_ff @(posedge clk) phase_acc <= phase_acc + phase_inc;



  // Waveform Generators
  //Sine via quarter-memory + symmetry
  logic [9:0] data_sine;
  sine_gen sin_i (
    .clk   (clk),
    .phase (phase_acc[31:23]),  
    .out   (data_sine)
  );

  //  Triangle: up/down ramp over full cycle
  logic [9:0] data_tri;
  assign data_tri = phase_acc[31]
                  ? (10'd1023 - phase_acc[30:21]) // descending
                  : phase_acc[30:21];            // ascending

  // Square: MSB of phase_acc
  logic data_sq;
  assign data_sq = phase_acc[31];


  // Output Multiplexer
  always_comb begin
    case (waveform_sel)
      2'b00: dac_out = data_sine;
      2'b01: dac_out = data_tri;
      2'b10: dac_out = {10{data_sq}}; 
      default: dac_out = data_sine;
    endcase
end

endmodule
