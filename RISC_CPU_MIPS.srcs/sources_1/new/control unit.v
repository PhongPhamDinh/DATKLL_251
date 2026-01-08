`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/20/2025 07:30:07 PM
// Design Name: 
// Module Name: control unit
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


module control_unit (
    input  [3:0] opcode,   // instruction[15:12]
    input  [2:0] funct,    // instruction[2:0]

    output reg RegDst,
    output reg RegWrite,
    output reg ALUSrc,
    output reg MemRead,
    output reg MemWrite,
    output reg MemToReg,
    output reg Branch,
    output reg Jump,
    output reg Halt,

    output reg [1:0] ALUOp,

    output reg [1:0] BranchCond, // 00: BEQ, 01: BNEQ, 10: BGTZ
    output reg JumpType          // 0: J, 1: JR
);

    always @* begin
        // ===== Default (safe) =====
        RegDst     = 0;
        RegWrite   = 0;
        ALUSrc     = 0;
        MemRead    = 0;
        MemWrite   = 0;
        MemToReg   = 0;
        Branch     = 0;
        Jump       = 0;
        Halt       = 0;
        ALUOp      = 2'b00;
        BranchCond = 2'b00;
        JumpType   = 0;

        case (opcode)

            // ======================
            // ALU0 - unsigned R-type
            // ======================
            4'b0000: begin
                RegDst   = 1;
                RegWrite = 1;
                ALUOp    = 2'b10;
            end

            // ======================
            // ALU1 - signed R-type + JR
            // ======================
            4'b0001: begin
                if (funct == 3'b111) begin // jr
                    Jump     = 1;
                    JumpType = 1; // JR
                end else begin
                    RegDst   = 1;
                    RegWrite = 1;
                    ALUOp    = 2'b10;
                end
            end

            // ======================
            // ALU2 - Shift
            // ======================
            4'b0010: begin
                RegDst   = 1;
                RegWrite = 1;
                ALUOp    = 2'b11;
            end

            // ======================
            // ADDI
            // ======================
            4'b0011: begin
                RegDst   = 0;
                RegWrite = 1;
                ALUSrc   = 1;
                ALUOp    = 2'b00;
            end

            // ======================
            // SLTI
            // ======================
            4'b0100: begin
                RegDst   = 0;
                RegWrite = 1;
                ALUSrc   = 1;
                ALUOp    = 2'b01;
            end

            // ======================
            // BNEQ
            // ======================
            4'b0101: begin
                Branch     = 1;
                BranchCond = 2'b01; // BNEQ
                ALUOp      = 2'b01;
            end

            // ======================
            // BGTZ
            // ======================
            4'b0110: begin
                Branch     = 1;
                BranchCond = 2'b10; // BGTZ
                ALUOp      = 2'b01;
            end

            // ======================
            // JUMP (absolute)
            // ======================
            4'b0111: begin
                Jump     = 1;
                JumpType = 0;
            end

            // ======================
            // LH
            // ======================
            4'b1000: begin
                RegDst    = 0;
                RegWrite  = 1;
                ALUSrc    = 1;
                MemRead   = 1;
                MemToReg  = 1;
                ALUOp     = 2'b00;
            end

            // ======================
            // SH
            // ======================
            4'b1001: begin
                ALUSrc    = 1;
                MemWrite  = 1;
                ALUOp     = 2'b00;
            end

            // ======================
            // MFSR
            // ======================
            4'b1010: begin
                RegDst   = 1;
                RegWrite = 1;
                ALUOp    = 2'b10;
            end

            // ======================
            // MTSR
            // ======================
            4'b1011: begin
                RegWrite = 0;
                ALUOp    = 2'b10;
            end

            // ======================
            // HALT
            // ======================
            4'b1111: begin
                Halt = 1;
            end

        endcase
    end
endmodule

