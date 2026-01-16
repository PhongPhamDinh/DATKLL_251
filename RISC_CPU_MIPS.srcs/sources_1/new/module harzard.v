`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/20/2025 08:32:34 PM
// Design Name: 
// Module Name: module harzard
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


module hazard_detection_unit (
    input  wire [2:0] IFID_rs,
    input  wire [2:0] IFID_rt,
    input  wire [2:0] IDEX_rd,
    input  wire       IDEX_MemRead,

    output reg        PCWrite,
    output reg        IFIDWrite,
    output reg        IDFlush
);

always @(*) begin
    PCWrite   = 1'b1;
    IFIDWrite = 1'b1;
    IDFlush   = 1'b0;

    if (IDEX_MemRead &&
       ((IDEX_rd == IFID_rs) || (IDEX_rd == IFID_rt))) begin
        PCWrite   = 0;
        IFIDWrite = 0;
        IDFlush   = 1;
    end
end

endmodule
