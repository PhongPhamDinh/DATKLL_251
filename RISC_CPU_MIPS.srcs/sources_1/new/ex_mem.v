`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/16/2026 06:06:11 PM
// Design Name: 
// Module Name: ex_mem
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


module EX_MEM (
    input wire clk,
    input wire rst,

    input wire [15:0] alu_result_in,
    input wire [15:0] rt_val_in,
    input wire [3:0]  rd_in,

    input wire RegWrite_in,
    input wire MemRead_in,
    input wire MemWrite_in,
    input wire MemToReg_in,

    output reg [15:0] alu_result,
    output reg [15:0] rt_val,
    output reg [3:0]  rd,

    output reg RegWrite,
    output reg MemRead,
    output reg MemWrite,
    output reg MemToReg
);
    always @(posedge clk) begin
        if (rst) begin
            RegWrite <= 0;
            MemRead  <= 0;
            MemWrite <= 0;
            MemToReg <= 0;
        end else begin
            alu_result <= alu_result_in;
            rt_val     <= rt_val_in;
            rd         <= rd_in;

            RegWrite <= RegWrite_in;
            MemRead  <= MemRead_in;
            MemWrite <= MemWrite_in;
            MemToReg <= MemToReg_in;
        end
    end
endmodule
