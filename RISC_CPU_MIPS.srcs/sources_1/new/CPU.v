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
reg [15:0] pc;
wire [15:0] pc_next, pc_plus2;
wire [15:0] instruction;

// Control Unit
wire RegDst, Branch, MemToReg, RegWrite, MemWrite, MemRead, ALUSrc;
wire [1:0] ALUOp, BranchCond;
wire Jump, JumpType, Halt_int;

// ALU Control
    wire [4:0] alu_ctrl;
    wire hi_lo_write;
    
// Data Signals
    wire [15:0] read_data1, read_data2, write_data;
    wire [15:0] sign_ext, alu_input2;
    wire [15:0] alu_result, mem_data;
    wire [15:0] hi_out, lo_out, special_out;
    wire zero, gt_zero;

// Detect Special Instructions
    wire is_mfsr = (instruction[15:12] == 4'b1010);
    wire is_mtsr = (instruction[15:12] == 4'b1011);

// Instruction Memory
instruction_memory IM (
    .addr(pc),
    .instr(instruction)
);
assign pc_plus2 = pc + 2;

// Control Unit
control_unit CU (
        .opcode(instruction[15:12]),
        .funct(instruction[2:0]),
        .RegDst(RegDst), .RegWrite(RegWrite), .ALUSrc(ALUSrc),
        .MemRead(MemRead), .MemWrite(MemWrite), .MemToReg(MemToReg),
        .Branch(Branch), .Jump(Jump), .Halt(Halt_int),
        .ALUOp(ALUOp), .BranchCond(BranchCond), .JumpType(JumpType)
    );
    
    wire [2:0] write_reg_addr = RegDst ? instruction[5:3] : instruction[8:6];
    
    // MUX Write Data: MFSR ? Special : (Load ? Mem : ALU)
    assign write_data = is_mfsr ? special_out : (MemToReg ? mem_data : alu_result);

// Register File
register_file RF (
        .clk(clk), .reset(reset),
        .read_reg1(instruction[11:9]), .read_reg2(instruction[8:6]),
        .write_reg(write_reg_addr), .write_data(write_data),
        .reg_write(RegWrite),
        
        .pc_in(pc), .hi_in(hi_out), .lo_in(lo_out),
        .hi_lo_write(hi_lo_write),
        .special_sel(instruction[2:0]),
        .special_write(is_mtsr), .special_read(is_mfsr),
        
        .read_data1(read_data1), .read_data2(read_data2),
        .special_out(special_out)
    );
    
// ALU Control
    assign sign_ext = {{10{instruction[5]}}, instruction[5:0]};
    assign alu_input2 = ALUSrc ? sign_ext : read_data2;

alu_control ALU_CTRL (
        .ALUOp(ALUOp),
        .opcode(instruction[15:12]),
        .funct(instruction[2:0]),
        .alu_ctrl(alu_ctrl),
        .HI_LO_Write(hi_lo_write)
    );

// ALU
alu ALU (
        .input1(read_data1),
        .input2(alu_input2),
        .alu_ctrl(alu_ctrl),
        .result(alu_result),
        .hi_out(hi_out), .lo_out(lo_out),
        .zero(zero), .gt_zero(gt_zero)
    );

// Data Memory
data_memory DM (
        .clk(clk), 
        .mem_write(MemWrite), 
        .mem_read(MemRead),
        .address(alu_result), 
        .write_data(read_data2),
        .read_data(mem_data)
    );

// Branch calculation
wire take_branch = Branch && ((BranchCond == 2'b01 && !zero) || (BranchCond == 2'b10 && gt_zero));
wire [15:0] branch_target = pc_plus2 + (sign_ext << 1);
wire [15:0] jump_target = JumpType ? read_data1 : {pc_plus2[15:13], instruction[11:0], 1'b0};

// PC update
assign pc_next = Jump ? jump_target : (take_branch ? branch_target : pc_plus2);

//Halt
assign Halt = Halt_int;

always @(posedge clk or posedge reset) begin
    if (reset)
        pc <= 0;
    else
        pc <= Halt_int ? pc : pc_next;
end

endmodule


