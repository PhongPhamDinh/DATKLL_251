`timescale 1ns / 1ps

module tb_cpu;

    reg clk   = 0;
    reg reset = 1;
    integer cycle = 0;

    // Clock 100MHz
    always #5 clk = ~clk;

    // DUT
    CPU test (
        .clk(clk),
        .reset(reset),
        .Halt()
    );

    // Reset & header
    initial begin
        reset = 1;
        #12 reset = 0;

        $display("==============================================================================================================");
        $display("  CYCLE | PC   | IF/ID | IDEX_rd | IDEX_MR | IF_rs IF_rt | PCW IFIDW FLUSH | FA FB");
        $display("--------|------|-------|---------|---------|-------------|----------------|------");
    end

    // ============================
    // DEBUG: BEFORE clock edge
    // ============================
    always @(negedge clk) begin
        if (!reset) begin
            $display(" PRE %4d | %4h | %5h | %3d |   %b     |  %d    %d   |  %b    %b     %b   | %b  %b",
                cycle,
                test.pc,
                test.IFID_instruction[15:0],
                test.IDEX_rd,
                test.IDEX_MemRead,
                test.read_reg1,
                test.read_reg2,
                test.PCWrite,
                test.IFIDWrite,
                test.IDFlush,
                test.ForwardA,
                test.ForwardB
            );
        end
    end

    // ============================
    // DEBUG: AFTER clock edge
    // ============================
    always @(posedge clk) begin
        if (!reset) begin
            cycle = cycle + 1;

            $display("POST %4d | %4h | %5h | %3d |   %b     |  %d    %d   |  %b    %b     %b   | %b  %b",
                cycle,
                test.pc,
                test.IFID_instruction[15:0],
                test.IDEX_rd,
                test.IDEX_MemRead,
                test.read_reg1,
                test.read_reg2,
                test.PCWrite,
                test.IFIDWrite,
                test.IDFlush,
                test.ForwardA,
                test.ForwardB
            );

            if (test.Halt) begin
                $display("==============================================================================================================");
                $display(" HALT detected at PC = %h, cycle = %0d", test.pc, cycle);
                $display("==============================================================================================================");
                $finish;
            end
        end
    end

    // Timeout
    initial begin
        #2000;
        $display(" ERROR: TIMEOUT ");
        $finish;
    end

endmodule
