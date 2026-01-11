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

module alu (
    input  [15:0] input1,   // rs
    input  [15:0] input2,   // rt/Imm
    input  [4:0]  alu_ctrl, // 5-bit control
    output reg [15:0] result,
    output zero
);

    // FP16 logic variables
    reg s1, s2, new_s;
    reg [4:0] e1, e2, final_e;
    reg [5:0] temp_e;      
    reg [10:0] m1, m2;      
    reg [21:0] temp_m;    
    reg [9:0] final_m;

    always @(*) begin
        // Default assignment
        result  = 0;
        s1      = 0;
        s2      = 0;
        new_s   = 0;
        e1      = 0;
        e2      = 0;
        final_e = 0;
        temp_e  = 0;
        m1      = 0;
        m2      = 0;
        temp_m  = 0;
        final_m = 0;

        case (alu_ctrl)
            // Arithmetic
            5'b00000: result = $signed(input1) + $signed(input2); // ADD
            5'b00010: result = $signed(input1) - $signed(input2); // SUB
            5'b00001: result = input1 + input2; // ADDU
            5'b00011: result = input1 - input2; // SUBU
            
            // Logic
            5'b01000: result = input1 & input2; // AND
            5'b01001: result = input1 | input2; // OR
            5'b01010: result = ~(input1 | input2); // NOR
            5'b01011: result = input1 ^ input2; // XOR

            // Comparison
            5'b01100: result = ($signed(input1) < $signed(input2)) ? 1 : 0; // SLT
            5'b01101: result = (input1 < input2) ? 1 : 0; // SLTU
            5'b01110: result = (input1 == input2) ? 1 : 0; // SEQ

            // Shift
            5'b10000: result = input2 >> input1[3:0]; // SHR
            5'b10001: result = input2 << input1[3:0]; // SHL
            5'b10010: result = (input2 >> input1[3:0]) | (input2 << (16 - input1[3:0])); // ROR
            5'b10011: result = (input2 << input1[3:0]) | (input2 >> (16 - input1[3:0])); // ROL

            // Memory Calc
            5'b10101: result = (input1[15:1] + input2) << 1;

            // Pass input2 (Used for MFSR)
            5'b11110: result = input2;

            // FP16 Multiply
            5'b11111: begin
                 if (input1[14:0] == 0 || input2[14:0] == 0) result = 0;
                 else begin
                    s1 = input1[15]; 
                    e1 = input1[14:10]; 
                    m1 = {1'b1, input1[9:0]};
                    s2 = input2[15]; 
                    e2 = input2[14:10]; 
                    m2 = {1'b1, input2[9:0]};
                    new_s = s1 ^ s2;
                    temp_e = e1 + e2 - 15;
                    temp_m = m1 * m2;
                    
                    if (temp_m[21]) begin 
                        final_e = temp_e + 1; 
                        final_m = temp_m[20:11]; 
                    end
                    else begin 
                        final_e = temp_e; 
                        final_m = temp_m[19:10]; 
                    end
                    result = {new_s, final_e[4:0], final_m};
                 end
            end

            default: result = 0;
        endcase
    end
    assign zero = (result == 0);
endmodule