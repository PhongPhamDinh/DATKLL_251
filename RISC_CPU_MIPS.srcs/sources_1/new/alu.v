`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/20/2025 07:30:07 PM
// Design Name: 
// Module Name: alu
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

`timescale 1ns / 1ps

module alu (
    input  [15:0] input1,   // rs
    input  [15:0] input2,   // rt/Imm
    input  [4:0]  alu_ctrl, // 5-bit control
    output reg [15:0] result,
    output reg [15:0] hi_out,
    output reg [15:0] lo_out,
    output reg zero,
    output reg gt_zero      // Greater Than Zero (For BGTZ)
);

    always @(*) begin
        // Default assignment
        result = 16'b0;
        hi_out = 16'b0;
        lo_out = 16'b0;

        case (alu_ctrl)
            // --- SIGNED ---
            5'b00000: result = $signed(input1) + $signed(input2); // ADD
            5'b00010: result = $signed(input1) - $signed(input2); // SUB
            5'b00100: {hi_out, lo_out} = $signed(input1) * $signed(input2); // MULT
            5'b00110: begin // DIV
                if (input2 != 0) begin
                    lo_out = $signed(input1) / $signed(input2);
                    hi_out = $signed(input1) % $signed(input2);
                end
            end
            
            // --- UNSIGNED ---
            5'b00001: result = input1 + input2; // ADDU
            5'b00011: result = input1 - input2; // SUBU
            5'b00101: {hi_out, lo_out} = input1 * input2; // MULTU
            5'b00111: begin // DIVU
                if (input2 != 0) begin
                    lo_out = input1 / input2;
                    hi_out = input1 % input2;
                end
            end

            // --- LOGICAL ---
            5'b01000: result = input1 & input2;       // AND
            5'b01001: result = input1 | input2;       // OR
            5'b01010: result = ~(input1 | input2);    // NOR
            5'b01011: result = input1 ^ input2;       // XOR

            // --- COMPARISON ---
            5'b01100: result = ($signed(input1) < $signed(input2)) ? 1 : 0; // SLT (Signed)
            5'b01101: result = (input1 < input2) ? 1 : 0;                   // SLTU (Unsigned)
            5'b01110: result = (input1 == input2) ? 1 : 0;                  // SEQ

            // --- SHIFT / ROTATE ---
            5'b10000: result = input2 >> input1[3:0]; // SHR
            5'b10001: result = input2 << input1[3:0]; // SHL
            5'b10010: result = (input2 >> input1[3:0]) | (input2 << (16 - input1[3:0])); // ROR
            5'b10011: result = (input2 << input1[3:0]) | (input2 >> (16 - input1[3:0])); // ROL
            
            default: result = 16'b0;
        endcase

        // Flags output
        zero = (result == 0); 
        gt_zero = ($signed(input1) > 0);
    end
endmodule