`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/10/2026 04:03:11 PM
// Design Name: 
// Module Name: tb_controlunit
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


module tb_controlunit;
    reg clk = 0;
    reg reset = 1;

    // Clock: 100MHz (10ns chu kỳ)
    always #5 clk = ~clk;

    // Instance CPU
    CPU test (
        .clk(clk),
        .reset(reset),
        .Halt()
    );

    // Khởi động mô phỏng
    initial begin
        $display("=== START CPU CONTROL + HALT TEST ===");
        $display(" time | PC   | Instr | RegW ALUSrc MemRead MemWrite MemtoREg Branch Jump Halt");
        $display("--------------------------------------------------");

        // reset 2 chu kỳ
        #20 reset = 0;

        // chạy tối đa 50 chu kỳ (phòng trường hợp HALT lỗi)
        repeat (50) @(posedge clk);

        $display("=== TIMEOUT: HALT NOT DETECTED ===");
        $finish;
    end

    always @(posedge clk) begin
        if (!reset) begin
            $display("%4t | %4h | %4h |   %b     %b     %b      %b     %b      %b     %b    %b",
                $time,
                test.pc,
                test.instruction,
                test.RegWrite,
                test.ALUSrc,
                test.MemRead,
                test.MemWrite,
                test.MemToReg,
                test.Branch,
                test.Jump,
                test.Halt
            );

            // ===== HALT detection =====
            if (test.Halt) begin
                $display("=== HALT detected at PC = %h ===", test.pc);
                $finish;
            end
        end
    end
endmodule
