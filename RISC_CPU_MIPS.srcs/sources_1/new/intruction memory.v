`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/20/2025 07:30:07 PM
// Design Name: 
// Module Name: intruction memory
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


module instruction_memory (
    input  [15:0] addr,      
    output [15:0] instr     
);

    reg [15:0] memory [0:255];

    `ifndef SYNTHESIS
    initial begin
        $readmemh("program.mem", memory);
        $display("Instruction memory loaded from program.mem");
    end
    `endif
    assign instr = memory[addr[15:1]]; 

endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/20/2025 07:30:07 PM
// Design Name: 
// Module Name: intruction memory
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


module instruction_memory (
    input  [15:0] addr,       // địa chỉ từ PC
    output [15:0] instr       // câu lệnh 16-bit
);

    // Bộ nhớ ROM chứa chương trình
    reg [15:0] memory [0:255]; // 256 lệnh, có thể mở rộng

    // Khởi tạo từ file .mem 
    `ifndef SYNTHESIS
    initial begin
        $readmemh("program.mem", memory);
        $display("Instruction memory loaded from program.mem");
    end
    `endif
    // Xuất lệnh tại địa chỉ PC
    assign instr = memory[addr[15:1]]; 
    // dùng addr[15:1] vì mỗi lệnh chiếm 2 byte

endmodule

