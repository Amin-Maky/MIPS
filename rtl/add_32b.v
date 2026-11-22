`timescale 1ns / 1ps

module add_32b(
	input wire [31:0]	input_A,
	input wire [31:0]	input_B,
	output wire [31:0] add_result
    );
	 
	 assign add_result=input_A+input_B;
endmodule
