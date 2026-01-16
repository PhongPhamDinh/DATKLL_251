`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/16/2026 06:06:11 PM
// Design Name: 
// Module Name: if_id
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


module IF_ID (
    input  wire        clk,
    input  wire        rst,
    input  wire        write_en,
    input  wire        flush,
    input  wire [15:0] instr_in,
    input  wire [15:0] pc_in,
    output reg  [15:0] instr_out,
    output reg  [15:0] pc_out
);
    always @(posedge clk) begin
        if (rst || flush) begin
            instr_out <= 16'b0;
            pc_out    <= 16'b0;
        end else if (write_en) begin
            instr_out <= instr_in;
            pc_out    <= pc_in;
        end
    end
endmodule

