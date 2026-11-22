`timescale 1ns / 1ps

module pc_32b(
    input clk,
    input rst,             
    input [31:0] PC_Next,  
    output reg [31:0] PC   
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            PC <= 32'd0;       
        end else begin
            PC <= PC_Next;
        end
    end
endmodule
