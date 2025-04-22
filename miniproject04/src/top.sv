// Top-level module for RV32I Single-Cycle Processor

module top #(
  parameter INIT_FILE = "program.mem"
) (
  input  logic clk,
  input  logic reset,
  output logic led,
  output logic red,
  output logic green,
  output logic blue,
  output logic [31:0] ImmExt
);

// === Program Counter and Control Signals ===
logic [31:0] pc;
logic [31:0] pc_next;
logic [31:0] pc_plus_4;
logic [31:0] branch_target;  // Branch target address
logic pc_write = 1'b1;  // Always enabled for single-cycle

// === Instruction Memory and Decoding ===
logic [31:0] instruction;
logic ir_write = 1'b1;  // Always enabled for single-cycle

// === ALU and Datapath Signals ===
logic [31:0] rs1_data, rs2_data;
logic [3:0] alu_op;
logic [31:0] alu_result;
logic zero_flag;
logic [31:0] op1_mux_out, op2_mux_out;

// === Control Signals ===
logic reg_write, mem_read, mem_write, branch, jump;
logic [1:0] alu_src, mem_to_reg;
logic take_branch;
logic [31:0] imm_ext;
logic [31:0] mem_read_data;
logic [31:0] write_data;
logic pc_mux_sel;

// === Program Counter ===
program_counter pc_unit (
  .clk(clk),
  .rst(reset),
  .pc_write(pc_write),
  .next_pc(pc_next),
  .pc(pc)
);

// === PC Adder ===
pc_adder pc_incr (
  .pc(pc),
  .pc_plus_4(pc_plus_4)
);

// === Instruction Decoder ===
instruction_decoder decoder (
  .instruction(instruction),
  .pc(pc),                // Connect PC
  .imm_ext(imm_ext),      // Connect ImmExt
  .alu_op(alu_op),
  .reg_write(reg_write),
  .alu_src(alu_src),
  .mem_read(mem_read),
  .mem_write(mem_write),
  .mem_to_reg(mem_to_reg),
  .branch(branch),
  .jump(jump)
);

// === Immediate Generator ===
ImmGen immgen (
  .Opcode(instruction[6:0]),
  .instruction(instruction),
  .ImmExt(imm_ext)
);

// === Register File ===
register_file registers (
  .clk(clk),
  .reset(reset),
  .reg_write(reg_write),
  .rs1_addr(instruction[19:15]),
  .rs2_addr(instruction[24:20]),
  .rd_addr(instruction[11:7]),
  .rd_data(write_data),
  .rs1_data(rs1_data),
  .rs2_data(rs2_data)
);

// === ALU Input Muxes ===
// alu_src[0]: 0=rs1_data, 1=pc
mux_2x1 op1_mux (
  .in0(rs1_data),
  .in1(pc),
  .sel(alu_src[0]),
  .out(op1_mux_out)
);

// alu_src[1]: 0=rs2_data, 1=imm_ext  
mux_2x1 op2_mux (
  .in0(rs2_data),
  .in1(imm_ext),
  .sel(alu_src[1]),
  .out(op2_mux_out)
);

// === ALU ===
alu alu_unit (
  .a(op1_mux_out),
  .b(op2_mux_out),
  .alu_op(alu_op),
  .result(alu_result),
  .zero_flag(zero_flag)
);

// === Memory Unit ===
memory #(
  .INIT_FILE(INIT_FILE)
) mem_unit (
  .clk(clk),
  .mem_read(mem_read),         // Read enable for data
  .mem_write(mem_write),       // Write enable for data
  .address(pc),                // Address for instruction fetch or data access
  .funct3(instruction[14:12]), // Function code for data access
  .write_data(rs2_data),       // Data to write
  .read_data(mem_read_data),   // Data read
  .instruction(instruction),   // Instruction fetched
  .led(led),
  .red(red),
  .green(green),
  .blue(blue)
);

// === Branch Control Logic ===
wire [2:0] branch_funct3 = instruction[14:12];

wire beq_cond = (branch_funct3 == 3'b000) && zero_flag;      // beq
wire bne_cond = (branch_funct3 == 3'b001) && !zero_flag;     // bne
wire blt_cond = (branch_funct3 == 3'b100) && alu_result[0];  // blt
wire bge_cond = (branch_funct3 == 3'b101) && !alu_result[0]; // bge
wire bltu_cond = (branch_funct3 == 3'b110) && alu_result[0]; // bltu
wire bgeu_cond = (branch_funct3 == 3'b111) && !alu_result[0]; // bgeu

// Calculate branch target address (PC + immediate)
assign branch_target = pc + imm_ext;

// Take branch if any condition is true and branch signal is enabled
assign take_branch = branch && (beq_cond || bne_cond || blt_cond || bge_cond || bltu_cond || bgeu_cond);

// === PC MUX ===
mux_2x1 pc_mux (
  .in0(pc_plus_4),
  .in1(take_branch ? branch_target : alu_result),  // Use branch_target for branches, alu_result for jumps
  .sel(take_branch || jump),
  .out(pc_next)
);

// === Register Write-back MUX ===
mux_4x1 rdv_mux (
  .in0(imm_ext),     // For LUI
  .in1(alu_result),  // For most ALU ops
  .in2(pc_plus_4),   // For JAL/JALR
  .in3(mem_read_data), // For loads
  .sel(mem_to_reg),
  .out(write_data)
);

// === PC MUX Selector ===
assign pc_mux_sel = take_branch || jump;

endmodule
