`timescale 1ns / 1ps

module tb_CPU();

    reg clk;
    reg reset;
    wire Halt;

    CPU uut (
        .clk(clk),
        .reset(reset),
        .Halt(Halt)
    );

    initial begin
        clk = 0;
    end
    always #5 clk = ~clk;

    initial begin
        $display("============================================================");
        $display(" BAT DAU MO PHONG (DEBUG MODE)");
        $display("============================================================");
        $display("Time(ns) | PC   | Instr | R1($1) | R2($2) | R4($4) | Note");
        $display("---------|------|-------|--------|--------|--------|--------");

        reset = 1;
        #50;
        reset = 0; 
        
        wait(Halt);
        
        #10;
        $display("------------------------------------------------------------");
        $display(" [INFO] CPU DA DUNG (HALT DETECTED) TAI %t ns", $time);
        $display("------------------------------------------------------------");
        
        if (uut.RF.R[1] === 16'd5 && uut.RF.R[4] === 16'd13 && uut.pc === 16'h000A) begin
            $display(" [KET QUA] PASSED: CHUC MUNG! Mach chay dung.");
        end else begin
            $display(" [KET QUA] FAILED: Ket qua sai hoac PC dung sai cho.");
            $display("           PC Hien tai: %h (Ky vong: 000A)", uut.pc);
            $display("           R1: %d, R4: %d", uut.RF.R[1], uut.RF.R[4]);
        end
        $finish;
    end

    always @(posedge clk) begin
        if (!reset) begin
            $write("%4t     | %h | %h  | %4d   | %4d   | %4d   | ", 
                   $time, uut.pc, uut.instruction, uut.RF.R[1], uut.RF.R[2], uut.RF.R[4]);

            if (uut.pc === 16'h0000) $display("Khoi tao / ADDI R1");
            else if (uut.pc === 16'h0002) $display("ADDI R2");
            else if (uut.pc === 16'h0004) $display("ADDI R4");
            else if (uut.pc === 16'h0006) $display("BNEQ Check (R4!=R1?)");
            else if (uut.pc === 16'h0008) $display("!!! VAO JUMP (Loi Branch)");
            else if (uut.pc === 16'h000A) $display("Dich den (HALT)");
            else $display("Running...");
        end
    end

    initial begin
        #1000; 
        if (!Halt) begin
            $display("------------------------------------------------------------");
            $display(" [ERROR] TIMEOUT: CPU khong dung sau 1000ns.");
            $display("         Kiem tra xem co bi lap vo tan (Infinite Loop) khong?");
            $display("------------------------------------------------------------");
            $stop;
        end
    end

endmodule