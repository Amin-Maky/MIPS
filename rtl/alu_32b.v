`timescale 1ns / 1ps

module alu_32b( 
	input wire [31:0]  input_A,input_B ,
	input wire [3:0] op,
	input [5:0] func,
	output reg Zero,					//branch
	output reg [31:0] alu_result	
);
    always @(*) begin
        Zero = 1'b0;    
        alu_result = 32'd0; 

        case (op)
            4'b0000: // R_type
                case (func)
                    6'b000000: alu_result = input_A & input_B;
                    6'b000001: alu_result = input_A | input_B;
                    6'b000010: alu_result = input_A + input_B;
                    6'b000011: alu_result = input_A >> input_B;
                    6'b000100: alu_result = input_A << input_B;
                    6'b000101: alu_result = input_A - input_B;
                    6'b000110: alu_result = (input_A < input_B) ? 32'd1 : 32'd0;
                    default: alu_result = 32'd0;
                endcase
            4'b0001: alu_result = input_A + input_B;
            4'b0010: alu_result = input_A & input_B;
            4'b0011: alu_result = input_A | input_B;
            4'b0100: alu_result = (input_A < input_B) ? 32'd1 : 32'd0;
				4'b0110: alu_result = input_A + input_B; //sw
				4'b0101: alu_result = input_A + input_B; //lw
            4'b0111: begin
                Zero = (input_A == input_B) ? 1'b1 : 1'b0;
                alu_result = 32'd0; 
			end
            4'b1000: begin
                Zero = (input_A != input_B) ? 1'b1 : 1'b0;
                alu_result = 32'd0; 
			end
            default: begin
                alu_result = 32'd0;
                Zero = 1'b0;
            end
        endcase
    end
endmodule
