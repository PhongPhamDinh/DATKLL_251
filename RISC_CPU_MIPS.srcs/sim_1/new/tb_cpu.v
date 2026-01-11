`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/20/2025 11:20:01 PM
// Design Name: 
// Module Name: tb_cpu
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


module tb_cpu;
    reg clk = 0;
    reg reset = 1;

    // Clock: 100MHz (10ns)
    always #5 clk = ~clk;

    // DUT
    CPU test (
        .clk(clk),
        .reset(reset),
        .Halt()
    );
    integer i;
    initial begin
    for (i = 0; i < 8; i = i + 1) test.RF.R[i] = 16'd0;
        $display("================================================================================");
        $display(" time | PC   | Instr | rs rt | rs_val  rt_val  | ALUop | in1     in2     | ALUres | Z GT | Br J | MemR MemW | Wreg Wdata");
        $display("================================================================================");
        reset = 1;
        #12;
        reset = 0;

        repeat (100) @(posedge clk);

        $display("=== TIMEOUT: HALT NOT DETECTED ===");
        $finish;
    end

    always @(posedge clk) begin
        if (!reset) begin
           #1;
            $display(
                "%4t | %4h | %4h | %2d %2d | %6d %6d | %5b | %6d %6d | %6d | %b  %b | %b  %b |  %b    %b |  %2d  %6d",
                $time,
                test.pc,
                test.instruction,

                // Register index
                test.read_reg1,
                test.read_reg2,

                // Register values
                test.read_data1,
                test.read_data2,

                // ALU
                test.alu_ctrl,
                test.read_data1,
                (test.ALUSrc ? test.sign_ext : test.read_data2),
                test.alu_result,

                // Flags
                test.zero,
                test.gt_zero,

                // Control
                test.Branch,
                test.Jump,
                test.MemRead,
                test.MemWrite,

                // Write-back
                test.write_reg,
                test.write_data
            );

            // ===== Data Memory observe =====
            if (test.MemRead || test.MemWrite) begin
                $display("      >>> DM: addr=%h write_data=%h read_data=%h",
                    test.alu_result,
                    test.read_data2,
                    test.mem_data
                );
            end

            // ===== HALT =====
            if (test.Halt) begin
                $display("=== HALT detected at PC = %h ===", test.pc);
                $finish;
            end
        end
    end
endmodule

