`timescale 1ns / 1ps

module reg_32b(
    input clk,
    input RegWrite,
	 input rst,
    input [4:0] read_addr_1, read_addr_2, write_addr,
    input [31:0] write_data,
    output [31:0] read_data_1, read_data_2
);
    reg [31:0] registers [31:0];

    assign read_data_1 = (read_addr_1 == 0) ? 32'b0 : registers[read_addr_1];
    assign read_data_2 = (read_addr_2 == 0) ? 32'b0 : registers[read_addr_2];
	 
	 integer i;
	 
	 initial begin
		for (i = 0; i < 32; i = i + 1) begin
					registers[i] <= i;
			end
	 end
	 
    always @(posedge clk) begin
		  if (RegWrite && write_addr != 0) begin
					 registers[write_addr] <= write_data;
        end
    end
	 
endmodule
