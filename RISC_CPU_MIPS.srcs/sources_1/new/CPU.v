`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/20/2025 05:30:37 PM
// Design Name: 
// Module Name: CPU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CPU(
    input clk,
    input reset,
    output Halt
);

// Program Counter
wire Halt_int;
reg [15:0] pc;
wire [15:0] instruction;

// Instruction Memory
instruction_memory IM (
    .addr(pc),
    .instr(instruction)
);

// Control Unit
wire RegDst, Branch, MemToReg, RegWrite, MemWrite, MemRead, ALUSrc, PCSrc, Jump;
wire [1:0] ALUOp;

control_unit CU (
    .opcode(instruction[15:12]),
    .RegDst(RegDst),
    .Branch(Branch),
    .MemToReg(MemToReg),
    .RegWrite(RegWrite),
    .MemWrite(MemWrite),
    .MemRead(MemRead),
    .ALUSrc(ALUSrc),
    .ALUOp(ALUOp),
    .Halt(Halt_int),
    .Jump(Jump) 
);

// Register File
wire [2:0] read_reg1 = instruction[11:9];
wire [2:0] read_reg2 = instruction[8:6];
wire [2:0] write_reg;
wire [15:0] write_data, read_data1, read_data2;

register_file RF (
    .clk(clk),
    .reg_write(RegWrite),
    .read_reg1(read_reg1),
    .read_reg2(read_reg2),
    .write_reg(write_reg),
    .write_data(write_data),
    .read_data1(read_data1),
    .read_data2(read_data2)
);

// ALU Control
wire [2:0] alu_ctrl;
alu_control ALU_CTRL (
    .ALUOp(ALUOp),
    .funct(instruction[2:0]),
    .alu_ctrl(alu_ctrl)
);

// Sign extend
wire [15:0] sign_ext = {{10{instruction[5]}}, instruction[5:0]};

// ALU
wire [15:0] alu_result;
wire zero;
alu ALU (
    .input1(read_data1),
    .input2(ALUSrc ? sign_ext : read_data2),
    .alu_ctrl(alu_ctrl),
    .result(alu_result),
    .zero(zero)
);

// Data Memory
wire [15:0] mem_data;
data_memory DM (
    .clk(clk),
    .mem_write(MemWrite),
    .mem_read(MemRead),
    .address(alu_result),
    .write_data(read_data2),
    .read_data(mem_data)
);

// MUX for write register
assign write_reg = RegDst ? instruction[11:9] : instruction[8:6];

// MUX for write data
assign write_data = MemToReg ? mem_data : alu_result;

// Branch calculation
wire [15:0] branch_addr = pc + 16'd2 + (sign_ext << 1);

// PC update
wire [15:0] pc_next = (Branch && zero) ? branch_addr : pc + 16'd2;

// Jump calculation
wire [15:0] pc_plus_2 = pc + 16'd2;
wire [15:0] jump_addr = { pc_plus_2[15:13], instruction[11:0], 1'b0 };

//Halt
assign Halt = Halt_int;

always @(posedge clk or posedge reset) begin
    if (reset)
        pc <= 16'd0;
    else if (Halt)
        pc <= pc;
    else if (Jump)
        pc <= jump_addr;
    else if (Branch)
        pc <= branch_addr;
    else
        pc <= pc_plus_2;
end

endmodule


