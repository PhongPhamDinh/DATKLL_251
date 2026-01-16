`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/16/2026 06:06:11 PM
// Design Name: 
// Module Name: id_ex
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

module ID_EX (
    input wire clk,
    input wire rst,
    input wire flush,

    /* data */
    input wire [15:0] rs_val_in,
    input wire [15:0] rt_val_in,
    input wire [15:0] imm_in,
    input wire [2:0]  rs_in,
    input wire [2:0]  rt_in,
    input wire [2:0]  rd_in,
    input  wire [3:0]  opcode_in,
    input  wire [2:0]  funct_in,

    /* control */
    input wire RegWrite_in,
    input wire MemRead_in,
    input wire MemWrite_in,
    input wire MemToReg_in,
    input wire ALUSrc_in,
    input wire [2:0] ALUOp_in,
    input wire write_en,

    output reg [15:0] rs_val,
    output reg [15:0] rt_val,
    output reg [15:0] imm,
    output reg [2:0]  rs,
    output reg [2:0]  rt,
    output reg [2:0]  rd,
    output reg  [3:0]  opcode,
    output reg  [2:0]  funct,

    output reg RegWrite,
    output reg MemRead,
    output reg MemWrite,
    output reg MemToReg,
    output reg ALUSrc,
    output reg [2:0] ALUOp
);
    always @(posedge clk) begin
        if (rst || flush) begin
            rs_val   <= 16'd0;
            rt_val   <= 16'd0;
            imm      <= 16'd0;
            rs       <= 3'd0;
            rt       <= 3'd0;
            rd       <= 3'd0;
            opcode   <= 4'd0;
            funct    <= 3'd0;

            RegWrite <= 1'b0;
            MemRead  <= 1'b0;
            MemWrite <= 1'b0;
            MemToReg <= 1'b0;
            ALUSrc   <= 1'b0;
            ALUOp    <= 3'b000;
        end else if (write_en) begin
            rs_val   <= rs_val_in;
            rt_val   <= rt_val_in;
            imm      <= imm_in;
            rs       <= rs_in;
            rt       <= rt_in;
            rd       <= rd_in;

            RegWrite <= RegWrite_in;
            MemRead  <= MemRead_in;
            MemWrite <= MemWrite_in;
            MemToReg <= MemToReg_in;
            ALUSrc   <= ALUSrc_in;
            ALUOp    <= ALUOp_in;
            opcode <= opcode_in;
            funct  <= funct_in;
        end
    end
endmodule
