`timescale 1ns / 1ps

module mem_32b (
    input clk,
    input MemWrite,
    input MemRead,
    input [31:0] Address,
    input [31:0] WriteData,
    output [31:0] ReadData
);

   
    reg [7:0] mem_byte0 [0:19]; 
    reg [7:0] mem_byte1 [0:19];
    reg [7:0] mem_byte2 [0:19];
    reg [7:0] mem_byte3 [0:19];

    integer i;
    initial begin
        for (i = 0; i < 20; i = i + 1) begin
            mem_byte0[i] = 8'b0;
            mem_byte1[i] = 8'b0;
            mem_byte2[i] = 8'b0;
            mem_byte3[i] = 8'b0;
        end
    end

    assign ReadData = (MemRead) ? { mem_byte3[Address[7:0]], 
                                    mem_byte2[Address[7:0]], 
                                    mem_byte1[Address[7:0]], 
                                    mem_byte0[Address[7:0]] } : 32'b0;

    always @(posedge clk) begin
        if (MemWrite) begin
            mem_byte0[Address[7:0]] <= WriteData[7:0];
            mem_byte1[Address[7:0]] <= WriteData[15:8];
            mem_byte2[Address[7:0]] <= WriteData[23:16];
            mem_byte3[Address[7:0]] <= WriteData[31:24];
        end
    end

endmodule
