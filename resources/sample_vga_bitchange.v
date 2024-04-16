`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:15:38 12/14/2017 
// Design Name: 
// Module Name:    vgaBitChange 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
// Date: 04/04/2020
// Author: Yue (Julien) Niu
// Description: Port from NEXYS3 to NEXYS4
//////////////////////////////////////////////////////////////////////////////////
module vga_bitchange(
	input clk,
	input bright,
	input button,
	input [9:0] hCount, vCount,
	output reg [11:0] rgb,
	output reg [15:0] score
   );
	
	parameter BLACK = 12'b0000_0000_0000;
	parameter WHITE = 12'b1111_1111_1111;
	parameter RED   = 12'b1111_0000_0000;
	parameter GREEN = 12'b0000_1111_0000;
	//parameter BLUE = 12'b0000_0000_1111;

	wire whiteZone;
	wire greenMiddleSquare;
	reg reset;
	reg[9:0] greenMiddleSquareY;
	reg[49:0] greenMiddleSquareSpeed; 

	initial begin
		greenMiddleSquareY = 10'd320;
		score = 15'd0;
		reset = 1'b0;
	end
	
	
	always@ (*) // paint a white box on a red background
    	if (~bright)
		rgb = BLACK; // force black if not bright
	 else if (greenMiddleSquare == 1)
		rgb = GREEN;
	 else if (whiteZone == 1)
		rgb = WHITE; // white box
	 else
		rgb = RED; // background color

	
	always@ (posedge clk)
		begin
		greenMiddleSquareSpeed = greenMiddleSquareSpeed + 50'd1;
		if (greenMiddleSquareSpeed >= 50'd500000) //500 thousand
			begin
			greenMiddleSquareY = greenMiddleSquareY + 10'd1;
			greenMiddleSquareSpeed = 50'd0;
			if (greenMiddleSquareY == 10'd779)
				begin
				greenMiddleSquareY = 10'd0;
				end
			end
		end

	always@ (posedge clk)
		if ((reset == 1'b0) && (button == 1'b1) && (hCount >= 10'd144) && (hCount <= 10'd784) && (greenMiddleSquareY >= 10'd400) && (greenMiddleSquareY <= 10'd475))
			begin
			score = score + 16'd1;
			reset = 1'b1;
			end
		else if (greenMiddleSquareY <= 10'd20)
			begin
			reset = 1'b0;
			end

	assign whiteZone = ((hCount >= 10'd144) && (hCount <= 10'd784)) && ((vCount >= 10'd400) && (vCount <= 10'd475)) ? 1 : 0;

	assign greenMiddleSquare = ((hCount >= 10'd340) && (hCount < 10'd380)) &&
				   ((vCount >= greenMiddleSquareY) && (vCount <= greenMiddleSquareY + 10'd40)) ? 1 : 0;
	
endmodule
