`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/20/2025 07:30:07 PM
// Design Name: 
// Module Name: alu control
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
module alu_control (
    input  [1:0] ALUOp,     
    input  [3:0] opcode,    
    input  [2:0] funct,   
    output reg [4:0] alu_ctrl, 
    output reg HI_LO_Write
);

    always @(*) begin
        alu_ctrl = 5'b00000;
        HI_LO_Write = 0;

        case (ALUOp)
            // --------------------------------------------
            // Case 00: Memory & ADDI
            // --------------------------------------------
            2'b00: alu_ctrl = 5'b00000; // ADD 

            // --------------------------------------------
            // Case 01: Branch & SLTI 
            // --------------------------------------------
            2'b01: begin
                // SLTI (Opcode 0100)
                if (opcode == 4'b0100) alu_ctrl = 5'b01100; 
                // Branch (BNEQ/BGTZ)
                else alu_ctrl = 5'b00010;
            end

            // --------------------------------------------
            // Case 10: R-Type (ALU0 & ALU1)
            // --------------------------------------------
            2'b10: begin
                if (opcode == 4'b0000) begin // === ALU0 (UNSIGNED) ===
                    case (funct)
                        3'b000: alu_ctrl = 5'b00001; // ADDU
                        3'b001: alu_ctrl = 5'b00011; // SUBU
                        3'b010: begin alu_ctrl = 5'b00101; HI_LO_Write = 1; end // MULTU
                        3'b011: begin alu_ctrl = 5'b00111; HI_LO_Write = 1; end // DIVU
                        3'b100: alu_ctrl = 5'b01000; // AND
                        3'b101: alu_ctrl = 5'b01001; // OR
                        3'b110: alu_ctrl = 5'b01010; // NOR
                        3'b111: alu_ctrl = 5'b01011; // XOR
                    endcase
                end 
                else if (opcode == 4'b0001) begin // === ALU1 (SIGNED) === 
                    case (funct)
                        3'b000: alu_ctrl = 5'b00000; // ADD (Signed)
                        3'b001: alu_ctrl = 5'b00010; // SUB (Signed)
                        3'b010: begin alu_ctrl = 5'b00100; HI_LO_Write = 1; end // MULT (Signed)
                        3'b011: begin alu_ctrl = 5'b00110; HI_LO_Write = 1; end // DIV (Signed)
                        3'b100: alu_ctrl = 5'b01100; // SLT (Signed)
                        3'b101: alu_ctrl = 5'b01110; // SEQ
                        3'b110: alu_ctrl = 5'b01101; // SLTU 
                        3'b111: alu_ctrl = 5'b00000; // JR
                    endcase
                end
            end

            // ------------------------------
            // Case 11: ALU2 (Shift / Rotate) 
            // ------------------------------
            2'b11: begin
                case (funct)
                    3'b000: alu_ctrl = 5'b10000; // SHR
                    3'b001: alu_ctrl = 5'b10001; // SHL
                    3'b010: alu_ctrl = 5'b10010; // ROR
                    3'b011: alu_ctrl = 5'b10011; // ROL
                    default: alu_ctrl = 5'b00000;
                endcase
            end
        endcase
    end
endmodule