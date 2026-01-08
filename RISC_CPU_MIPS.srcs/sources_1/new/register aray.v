`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/20/2025 07:30:07 PM
// Design Name: 
// Module Name: register aray
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

module register_file (
    input clk, reset,
    input reg_write,
    input [2:0] read_reg1, read_reg2, write_reg,
    input [15:0] write_data,
    
    // Special Registers Interfaces
    input [15:0] pc_in, hi_in, lo_in,
    input hi_lo_write,
    input [2:0] special_sel,
    input special_write, special_read,
    
    output [15:0] read_data1, read_data2,
    output reg [15:0] special_out
);

    reg [15:0] R [0:7];
    reg [15:0] HI, LO, RA, AT;
    integer i;

    // Read Logic
    assign read_data1 = (read_reg1 == 0) ? 0 : R[read_reg1];
    assign read_data2 = (read_reg2 == 0) ? 0 : R[read_reg2];

    // Read Special Logic (MFSR)
    always @(*) begin
        if (special_read) begin
            case (special_sel)
                3'b000: special_out = 16'b0;  // MFZ ($ZERO)
                3'b001: special_out = pc_in;  // MFPC
                3'b010: special_out = RA;     // MFRA
                3'b011: special_out = AT;     // MFAT
                3'b100: special_out = HI;     // MFHI
                3'b101: special_out = LO;     // MFLO
                default: special_out = 16'b0;
            endcase
        end else special_out = 16'b0;
    end

    // Write Logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i=0; i<8; i=i+1) R[i] <= 0;
            HI<=0; LO<=0; RA<=0; AT<=0;
        end else begin
            if (reg_write && write_reg != 0) R[write_reg] <= write_data;
            
            if (hi_lo_write) begin HI <= hi_in; LO <= lo_in; end
            
            if (special_write) begin
                case (special_sel)
                    3'b010: RA <= read_data2; // MTRA
                    3'b011: AT <= read_data2; // MTAT
                    3'b100: HI <= read_data2; // MTHI
                    3'b101: LO <= read_data2; // MTLO
                endcase
            end
        end
    end
endmodule

