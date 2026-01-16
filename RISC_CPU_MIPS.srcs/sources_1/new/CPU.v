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

// --- Special Register ---
    reg [15:0] pc;
    reg [15:0] HI, LO, AT, RA;
  
// --- Control Signals ---
    wire RegDst, Branch, MemToReg, RegWrite, MemWrite, MemRead, ALUSrc, Jump, Halt_int;
    wire [2:0] ALUOp;
    wire [4:0] IDEX_alu_ctrl;
    
// --- IF wires ---
    wire [15:0] instruction;

// --- IF/ID ---
    wire [15:0] IFID_instruction;
    wire [15:0] IFID_pc;

// --- ID wires ---
    wire [2:0] read_reg1 = IFID_instruction[11:9];
    wire [2:0] read_reg2 = IFID_instruction[8:6];
    wire [2:0] write_reg;
    wire [15:0] read_data1, read_data2;
    wire [15:0] sign_ext;
    assign sign_ext = {{10{IFID_instruction[5]}}, IFID_instruction[5:0]};
    
 // --- ID/EX wires  ---
    wire [15:0] IDEX_read_data1, IDEX_read_data2, IDEX_imm;
    wire [2:0]  IDEX_rs, IDEX_rt, IDEX_rd;
    wire IDEX_RegWrite, IDEX_MemRead, IDEX_MemWrite;
    wire IDEX_MemToReg, IDEX_ALUSrc;
    wire [2:0] IDEX_ALUOp;
    wire [3:0] IDEX_opcode;
    wire [2:0] IDEX_funct;

// --- EX wires ---
    wire [15:0] alu_in2, alu_result;
    wire zero;

// --- EX/MEM wires ---
    wire [15:0] EXMEM_alu_result, EXMEM_write_data;
    wire [2:0]  EXMEM_rd;
    wire EXMEM_RegWrite, EXMEM_MemRead;
    wire EXMEM_MemWrite, EXMEM_MemToReg;

// --- MEM wires ---
    wire [15:0] mem_data;

// --- MEM/WB wires ---
    wire [15:0] MEMWB_mem_data, MEMWB_alu_result;
    wire [2:0]  MEMWB_rd;
    wire MEMWB_RegWrite, MEMWB_MemToReg;

// --- WB wires ---
    wire [15:0] write_data;

// --- Hazard control wires ---
    wire PCWrite, IFIDWrite, IFIDFlush, IDFlush;
    assign IFIDFlush = 0;
    wire stall;
    assign stall = ~PCWrite;


// --- Forwarding wires ---
    wire [1:0] ForwardA;
    wire [1:0] ForwardB;
    wire [15:0] forward_A_data;
    wire [15:0] forward_B_data;

    
// --- Instruction Memory ---
instruction_memory IM (
         .addr(pc),
         .instr(instruction)
);

// --- IF/ID ---
IF_ID IFID (
    .clk(clk),
    .rst(reset),
    .write_en(IFIDWrite),
    .flush(IFIDFlush),
    .instr_in(instruction),
    .pc_in(pc_plus_2),
    .instr_out(IFID_instruction),
    .pc_out(IFID_pc)
);

// --- Control Unit ---
control_unit CU (
        .opcode(IFID_instruction[15:12]),
        .RegDst(RegDst), 
        .Branch(Branch), 
        .MemToReg(MemToReg),
        .RegWrite(RegWrite), 
        .MemWrite(MemWrite), 
        .MemRead(MemRead),
        .ALUSrc(ALUSrc), 
        .ALUOp(ALUOp), 
        .Jump(Jump), 
        .Halt(Halt_int)
    );
    
// --- MUX for write register ---
    assign write_reg = RegDst ? IFID_instruction[5:3] : IFID_instruction[8:6];
    
// --- Register File ---
register_file RF (
        .clk(clk), 
        .reset(reset), 
        .reg_write(MEMWB_RegWrite),
        .read_reg1(read_reg1),
        .read_reg2(read_reg2),
        .write_reg(MEMWB_rd),
        .write_data(write_data),
        .read_data1(read_data1), 
        .read_data2(read_data2)
    );

// --- ID/EX ---
ID_EX IDEX (
    .clk(clk),
    .rst(reset),
    .flush(IDFlush),

    .rs_val_in(read_data1),
    .rt_val_in(read_data2),
    .imm_in(sign_ext),
    .rs_in(read_reg1),
    .rt_in(read_reg2),
    .rd_in(write_reg),

    .opcode_in(IFID_instruction[15:12]),
    .funct_in(IFID_instruction[2:0]),

    .RegWrite_in(RegWrite),
    .MemRead_in(MemRead),
    .MemWrite_in(MemWrite),
    .MemToReg_in(MemToReg),
    .ALUSrc_in(ALUSrc),
    .ALUOp_in(ALUOp),

    .rs_val(IDEX_read_data1),
    .rt_val(IDEX_read_data2),
    .imm(IDEX_imm),
    .rs(IDEX_rs),
    .rt(IDEX_rt),
    .rd(IDEX_rd),

    .opcode(IDEX_opcode),   // ✅ THÊM
    .funct(IDEX_funct),     // ✅ THÊM

    .RegWrite(IDEX_RegWrite),
    .MemRead(IDEX_MemRead),
    .MemWrite(IDEX_MemWrite),
    .MemToReg(IDEX_MemToReg),
    .ALUSrc(IDEX_ALUSrc),
    .ALUOp(IDEX_ALUOp)
);


// --- Harzard Detection  Unit ---
hazard_detection_unit HU (
    .IFID_rs(read_reg1),
    .IFID_rt(read_reg2),
    .IDEX_rd(IDEX_rd),
    .IDEX_MemRead(IDEX_MemRead),
    .PCWrite(PCWrite),
    .IFIDWrite(IFIDWrite),
    .IDFlush(IDFlush)
);

// --- Forwarding Module ---
forward_module FU (
    .EX_rs(IDEX_rs),
    .EX_rt(IDEX_rt),
    .MEM_rd(EXMEM_rd),
    .WB_rd(MEMWB_rd),
    .MEM_RegWrite(EXMEM_RegWrite),
    .WB_RegWrite(MEMWB_RegWrite),
    .ForwardA(ForwardA),
    .ForwardB(ForwardB)
);

assign forward_A_data =
    (ForwardA == 2'b00) ? IDEX_read_data1 :
    (ForwardA == 2'b10) ? EXMEM_alu_result :
    (ForwardA == 2'b01) ? write_data :
    IDEX_read_data1;
assign forward_B_data =
    (ForwardB == 2'b00) ? IDEX_read_data2 :
    (ForwardB == 2'b10) ? EXMEM_alu_result :
    (ForwardB == 2'b01) ? write_data :
    IDEX_read_data2;

// --- ALU Control ---
alu_control ALU_CTRL (
        .ALUOp(IDEX_ALUOp), 
        .opcode(IDEX_opcode), 
        .funct(IDEX_funct),
        .alu_ctrl(IDEX_alu_ctrl)
    );

// --- ALU ---
     assign alu_in2 = IDEX_ALUSrc ? IDEX_imm : forward_B_data;
alu ALU (
        .input1(forward_A_data), 
        .input2(alu_in2), 
        .alu_ctrl(IDEX_alu_ctrl),
        .result(alu_result), 
        .zero(zero)
    );

// --- EX/MEM ---
EX_MEM EXMEM (
    .clk(clk),
    .rst(reset),

    .alu_result_in(alu_result),
    .rt_val_in(forward_B_data),
    .rd_in(IDEX_rd),

    .RegWrite_in(IDEX_RegWrite),
    .MemRead_in(IDEX_MemRead),
    .MemWrite_in(IDEX_MemWrite),
    .MemToReg_in(IDEX_MemToReg),

    .alu_result(EXMEM_alu_result),
    .rt_val(EXMEM_write_data),
    .rd(EXMEM_rd),

    .RegWrite(EXMEM_RegWrite),
    .MemRead(EXMEM_MemRead),
    .MemWrite(EXMEM_MemWrite),
    .MemToReg(EXMEM_MemToReg)
);
// --- Data Memory ---
data_memory DM (
    .clk(clk),
    .mem_write(EXMEM_MemWrite),
    .mem_read(EXMEM_MemRead),
    .address(EXMEM_alu_result),
    .write_data(EXMEM_write_data),
    .read_data(mem_data)
);

// --- MEM/WB ---
MEM_WB MEMWB (
    .clk(clk),
    .rst(reset),

    .mem_data_in(mem_data),
    .alu_result_in(EXMEM_alu_result),
    .rd_in(EXMEM_rd),

    .RegWrite_in(EXMEM_RegWrite),
    .MemToReg_in(EXMEM_MemToReg),

    .mem_data(MEMWB_mem_data),
    .alu_result(MEMWB_alu_result),
    .rd(MEMWB_rd),

    .RegWrite(MEMWB_RegWrite),
    .MemToReg(MEMWB_MemToReg)
);
// --- WRITE BACK ---  
    assign write_data = MEMWB_MemToReg ? MEMWB_mem_data : MEMWB_alu_result;
    
// --- PC update --- 
    wire [15:0] pc_plus_2 = pc + 16'd2;
    assign Halt = Halt_int;

// --- PC Update ---
reg [15:0] pc_next;

always @(*) begin
    pc_next = pc + 16'd2;
end

always @(posedge clk or posedge reset) begin
    if (reset)
        pc <= 16'd0;
    else if (PCWrite)
        pc <= pc_next;
        else pc <= pc;
end

endmodule



