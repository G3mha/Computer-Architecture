// Top-level module for RV32I Single-Cycle Processor

module top (
  input  logic clk,
  input  logic reset
);

// === Instruction Memory ===
logic [31:0] instruction_mem_data;

instruction_memory instruction_mem (
    .address(pc),
    .instruction(instruction_mem_data)
);


// === Instruction Register ===
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

ImmGen immgen (
  .Opcode(opcode),
  .instruction(instruction),
  .ImmExt(imm_ext)
);

// === Memory Unit ===
logic [2:0] mem_funct3;
logic [31:0] read_data;
logic [31:0] write_data;
logic [31:0] write_address;
logic [31:0] read_address;
logic [31:0] mem_data;

assign mem_funct3 = (state == FETCH) ? 3'b010 : instruction[14:12];

memory mem_unit (
  .clk(clk),
  .write_mem(mem_write),
  .funct3(mem_funct3),
  .write_address(alu_result),
  .write_data(rs2_data),
  .read_address(mem_read_addr),
  .read_data(mem_read_data),
  .led(led),
  .red(red),
  .green(green),
  .blue(blue)
);

// Program Logic
program_counter pc (
logic [31:0] pc

.clk(clk),
.reset(reset),
.pc_write(pc_write),
.pc_in(pc_next),
    );

pc_adder pc_incr (
    logic [31:0] pc_plus_4,

    .pc(pc)
)

// ALU
alu alu_unit (
  .a(op1),
  .b(op2),
  .alu_op(alu_op),
  .result(alu_result),
  .zero_flag(zero_flag)
)
// Mux's
mux_2x1 pc_mux (
    .in0(pc_plus_4),
    .in1(alu_result),
    .sel(jump),
    .out(pc_next)
)

mux_2x1 RA_mux (
    .in0(pc),
    .in1(alu_result),
    .sel(jump),
    .out(rdv_mux_out)
)

mux_2x1 op1_mux (
    .in0(pc),
    .in1(rs1),
    .sel(alu_src),
    .out(op1_mux_out)
)

mux_2x1 op2_mux (
    .in0(rs2_data),
    .in1(imm_ext),
    .sel(alu_src),
    .out(op2_mux_out)
)

mux_4x1 rdv_mux (
  .in0(imm_ext),
  .in1(alu_result),
  .in2(pc_adder),
  .in3(mem_read_data),
  .sel(mem_to_reg),
  .out(rdv_mux_out)
)

endmodule

