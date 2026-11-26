`timescale 1ns / 1ps

module inst_32b(
    input [31:0] Address,
    output [31:0] Instruction
);

    reg [31:0] memory [0:40];//you should incrase memory

    initial begin
        
        memory[0] = 32'b00000000001000100001100000000010; // add $R3, $R2, $R1
        memory[4] = 32'b00000100010000110000000000001010; // addi $R3, $R2, 10
		memory[8] = 32'b00011001010000110000000000000000; // sw R3 0(R10)
		  //memory[12]= 32'b00100100000000000000000000000000; // j 0
		memory[12]= 32'b00100000001000100000000000000100; // bne($R1,R2,4)
		memory[32]= 32'b00100100000000000000000000000000; // j 0
    end

    assign Instruction = memory[Address[7:0]];

endmodule

