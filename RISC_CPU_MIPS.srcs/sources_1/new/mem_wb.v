`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/16/2026 06:06:11 PM
// Design Name: 
// Module Name: mem_wb
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


module MEM_WB (
    input wire clk,
    input wire rst,

    input wire [15:0] mem_data_in,
    input wire [15:0] alu_result_in,
    input wire [3:0]  rd_in,

    input wire RegWrite_in,
    input wire MemToReg_in,

    output reg [15:0] mem_data,
    output reg [15:0] alu_result,
    output reg [3:0]  rd,

    output reg RegWrite,
    output reg MemToReg
);
    always @(posedge clk) begin
        if (rst) begin
            RegWrite <= 0;
            MemToReg <= 0;
        end else begin
            mem_data   <= mem_data_in;
            alu_result <= alu_result_in;
            rd         <= rd_in;

            RegWrite <= RegWrite_in;
            MemToReg <= MemToReg_in;
        end
    end
endmodule
