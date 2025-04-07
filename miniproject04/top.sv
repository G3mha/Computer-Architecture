// Top-level module for RV32I Single-Cycle Processor

module top (
    input  logic clk,
    input  logic reset
);

// Instruction Register
instruction_register ir (
        .clk(clk),
        .reset(reset),
        .ir_write(ir_write),
        .instruction_in(instruction_mem_data),
        .instruction_out(instruction)
    );

// Instruction Decoder
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

// Immediate Generator
logic [31:0] imm_ext;

ImmGen immgen (
        .Opcode(opcode),
        .instruction(instruction),
        .ImmExt(imm_ext)
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

endmodule

