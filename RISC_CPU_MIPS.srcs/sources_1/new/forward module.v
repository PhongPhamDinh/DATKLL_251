`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/20/2025 08:19:25 PM
// Design Name: 
// Module Name: forward module
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


module forward_module (
    input  wire [2:0] EX_rs,
    input  wire [2:0] EX_rt,
    input  wire [2:0] MEM_rd,
    input  wire [2:0] WB_rd,
    input  wire       MEM_RegWrite,
    input  wire       WB_RegWrite,

    output reg  [1:0] ForwardA,
    output reg  [1:0] ForwardB
);

always @(*) begin
    ForwardA = 2'b00;
    ForwardB = 2'b00;

    if (MEM_RegWrite && (MEM_rd != 0) && (MEM_rd == EX_rs))
        ForwardA = 2'b10;
    else if (WB_RegWrite && (WB_rd != 0) && (WB_rd == EX_rs))
        ForwardA = 2'b01;

    if (MEM_RegWrite && (MEM_rd != 0) && (MEM_rd == EX_rt))
        ForwardB = 2'b10;
    else if (WB_RegWrite && (WB_rd != 0) && (WB_rd == EX_rt))
        ForwardB = 2'b01;
end

endmodule
