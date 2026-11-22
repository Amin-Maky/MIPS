`timescale 1ns / 1ps


module datapath(
	input clk,
	input rst,
	input wire [3:0] ALUop,	//ALU oprand 4bit
	input wire RegDst,RegWrite,ALUSrc,MemWrite,MemtoReg,MemRead,Jump,Branch,
	output wire [31:0]instr,
	output wire [31:0]PC
	//what do you want for output signal from datapath
    );

	wire Zero,PCSrc;
	wire [31:0] reg_1,reg_2,immed,input_B,alu_result,mem_read_data,write_back,
					pcPlus4,shift_immed,branch_address_result,jump_address,mux_4,PC_Next;
	wire [4:0]  write_addr;
	
	
	
	add_32b add_32b_1 (
    .input_A(PC), 
    .input_B(32'd4),//aligning 
    .add_result(pcPlus4)
    );
	
	
	assign shift_immed= immed << 2;
	
	add_32b add_32b_2 (
    .input_A(pcPlus4), 
    .input_B(shift_immed), 
    .add_result(branch_address_result)//to MUX4
    );
	 
	 assign jump_address={pcPlus4[31:28],instr[25:0],2'b00};  //make jump address
	 
	 assign PCSrc=Branch&Zero; //AND1
	 
	 assign mux_4 = PCSrc?branch_address_result:pcPlus4;// MUX4
	 assign PC_Next = Jump ? jump_address: mux_4;		 // MUX5
	 
	 
	
	pc_32b pc_32b (
    .clk(clk), 
    .rst(rst), 
    .PC_Next(PC_Next), 
    .PC(PC)
    );
	 
	 inst_32b inst_32b (
    .Address(PC),//from pc block 
    .Instruction(instr)
    );
	 
	 assign write_addr= RegDst?instr[15:11]:instr[20:16]; //MUX1
	 
	 reg_32b reg_32b (
    .clk(clk), 
    .RegWrite(RegWrite), 
    .rst(rst), 
    .read_addr_1(instr[25:21]), 
    .read_addr_2(instr[20:16]), 
    .write_addr(write_addr),//from mux1 
    .write_data(write_back),//from memory write back 
    .read_data_1(reg_1), 
    .read_data_2(reg_2)
    );
	 
	 assign input_B=ALUSrc?immed:reg_2; //MUX2


	 
	 alu_32b alu_32b (
    .input_A(reg_1), 
    .input_B(input_B), 		//from MUX2 
    .op(ALUop), 
    .func(instr[5:0]), 		// func from instruction[5:0] 
    .Zero(Zero), 				//to AND1
    .alu_result(alu_result)//to MUX3 and write data
    );

	 
	 mem_32b mem_32b (
    .clk(clk), 
    .MemWrite(MemWrite), 
    .MemRead(MemRead), 
    .Address(alu_result),
    .WriteData(reg_2),//from register file 
    .ReadData(mem_read_data)//to MUX3
    );

	 
	 
	assign write_back=MemtoReg?mem_read_data:alu_result; //MUX3
	
	
	sgnExt_32b sgnExt_32b (
    .in(instr[15:0]), 
    .out(immed) //to MUX2,shift_immed
    );

//SN
endmodule
