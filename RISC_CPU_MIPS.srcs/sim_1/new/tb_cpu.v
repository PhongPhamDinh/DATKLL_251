`timescale 1ns / 1ps

module tb_cpu;

    reg clk = 0;
    reg reset = 1;

    // Clock 10ns
    always #5 clk = ~clk;

    CPU test (
        .clk(clk),
        .reset(reset),
        .Halt()
    );

    integer cycle = 0;

    initial begin
        $display("==============================================================");
        $display(" BASIC PIPELINE FLOW TEST (NO HAZARD / NO FORWARD)");
        $display("==============================================================");
        $display(" CYCLE | PC   | IF/ID | ID/EX rd | EX/MEM rd | MEM/WB rd ");
        $display("--------------------------------------------------------------");

        #12 reset = 0;
    end

    always @(posedge clk) begin
        if (!reset) begin
            cycle = cycle + 1;
            $display(" %5d | %4h | %4h | %8d | %9d | %9d",
                cycle,
                test.pc,
                test.IFID_instruction,
                test.IDEX_rd,
                test.EXMEM_rd,
                test.MEMWB_rd
            );

            if (test.Halt) begin
                $display("--------------------------------------------------------------");
                $display(" HALT at cycle %0d, PC = %h", cycle, test.pc);
                $display("==============================================================");
                $finish;
            end
        end
    end

endmodule