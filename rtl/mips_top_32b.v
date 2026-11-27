`timescale 1ns / 1ps

module mips_top_32b(
	input wire clk,
	input wire rst,
	output wire [31:0]instr,
	output wire [31:0]PC,
	output wire exit_o
    );
	 

	wire [3:0] ALUop;	//ALU oprand 4bit
	wire RegDst,RegWrite,ALUSrc,MemWrite,MemtoReg,MemRead,Jump,Branch;
	
	datapath datapath (
    .clk(clk), 
    .rst(rst), 
    .ALUop(ALUop), 
    .RegDst(RegDst), 
    .RegWrite(RegWrite), 
    .ALUSrc(ALUSrc), 
    .MemWrite(MemWrite), 
    .MemtoReg(MemtoReg), 
    .MemRead(MemRead), 
    .Jump(Jump), 
    .Branch(Branch),
	.instr(instr),
	.PC(PC)
    );
	 
	 ControlUnit control (
    .opcode(instr[31:26]), 
    .ALUop(ALUop), 
    .Branch(Branch), 
    .RegWrite(RegWrite), 
    .MemRead(MemRead), 
    .MemWrite(MemWrite), 
    .MemtoReg(MemtoReg), 
    .ALUSrc(ALUSrc), 
    .RegDst(RegDst), 
    .Jump(Jump),
	.exit_o(exit_o) // custom HALT
    );


endmodule
