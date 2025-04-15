module register_file (
  input  logic         clk,       // Clock signal
  input  logic         reset,     // Asynchronous reset signal
  input  logic         reg_write, // write or not 
  input  logic [4:0]   rs1_addr,  // 5-bit
  input  logic [4:0]   rs2_addr,  // 5-bit 
  input  logic [4:0]   rd_addr,   // 5-bit destination register address for write
  input  logic [31:0]  rd_data,   // rdv rdv_mux              name to be changed 
  output logic [31:0]  rs1_data,  // the a in Alu  op1_mux    name to be changed 
  output logic [31:0]  rs2_data   // the b in Alu  op2_mux    name to be changed 
);
  logic [31:0] registers [0:31];  // declare 32 long

  // when reg_addr is 0 then 0, else read data stored in register
  assign rs1_data = (rs1_addr == 5'd0) ? 32'd0 : registers[rs1_addr];
  assign rs2_data = (rs2_addr == 5'd0) ? 32'd0 : registers[rs2_addr];

  // on reset, clear to 0 else on clock rise edge if reg_write true, put the rdv into rd_addr specified rs1 or rs2
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      integer i;
      for (i = 0; i < 32; i = i + 1) begin
        registers[i] <= 32'd0;
      end
    end else if (reg_write && (rd_addr != 5'd0)) begin
      registers[rd_addr] <= rd_data;
    end
  end

endmodule
