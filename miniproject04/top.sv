// Top-level module for RV32I Single-Cycle Processor

module top (
  input  logic clk,
  input  logic reset
);

// === Program Counter and Control Signals ===
logic [31:0] pc;
logic [31:0] pc_next;
logic [31:0] pc_plus_4;
logic pc_write = 1'b1;
logic [31:0] mem_read_data;
logic [31:0] ra_mux_out;

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

// === Instruction Memory ===
logic [31:0] instruction_mem_data;

instruction_memory instruction_mem (
  .address(pc),
  .instruction(instruction_mem_data)
);

// === Instruction Register ===
logic [31:0] instruction;
logic ir_write = 1'b1;

instruction_register ir (
  .clk(clk),
  .reset(reset),
  .ir_write(ir_write),
  .instruction_in(instruction_mem_data),
  .instruction_out(instruction)
);

// === Instruction Decoder ===
logic [3:0]  alu_op;
logic reg_write, mem_read, mem_write, branch, jump;
logic [1:0]  alu_src, mem_to_reg;

instruction_decoder decoder (
  .instruction(instruction),
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
logic [31:0] imm_ext;
logic [6:0] opcode = instruction[6:0];

ImmGen immgen (
  .Opcode(opcode),
  .instruction(instruction),
  .ImmExt(imm_ext)
);

// === Register File ===
logic [31:0] rs1_data, rs2_data;
logic [31:0] rdv_mux_out;

register_file registers (
  .clk(clk),
  .reset(reset),
  .reg_write(reg_write),
  .rs1_addr(instruction[19:15]),
  .rs2_addr(instruction[24:20]),
  .rd_addr(instruction[11:7]),
  .rd_data(rdv_mux_out),
  .rs1_data(rs1_data),
  .rs2_data(rs2_data)
);

// === ALU ===
logic [31:0] alu_result;
logic zero_flag;
logic [31:0] op1_mux_out, op2_mux_out;

alu alu_unit (
  .a(op1_mux_out),
  .b(op2_mux_out),
  .alu_op(alu_op),
  .result(alu_result),
  .zero_flag(zero_flag)
);

// === Memory Unit ===
memory mem_unit (
  .clk(clk),
  .write_mem(mem_write),
  .funct3(instruction[14:12]),
  .write_address(alu_result),
  .write_data(rs2_data),
  .read_address(alu_result),
  .read_data(mem_read_data),
  .led(),
  .red(),
  .green(),
  .blue()
);

// === Multiplexers ===
mux_2x1 pc_mux (
  .in0(pc_plus_4),
  .in1(alu_result),
  .sel(jump),
  .out(pc_next)
);

mux_2x1 op1_mux (
  .in0(pc),
  .in1(rs1_data),
  .sel(alu_src[0]),
  .out(op1_mux_out)
);

mux_2x1 op2_mux (
  .in0(rs2_data),
  .in1(imm_ext),
  .sel(alu_src[1]),
  .out(op2_mux_out)
);

mux_4x1 rdv_mux (
  .in0(imm_ext),
  .in1(alu_result),
  .in2(pc_plus_4),
  .in3(mem_read_data),
  .sel(mem_to_reg),
  .out(rdv_mux_out)
);

endmodule
