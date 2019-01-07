`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:09:49 12/10/2018
// Design Name:   tetris
// Module Name:   /home/ise/tetris/tetris_tb.v
// Project Name:  tetris
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: tetris
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tetris_tb;

	// Inputs
	reg board_clk;
	reg btn_rotate;
	reg btn_left;
	reg btn_right;
	reg btn_down;
	reg sw_pause;
	reg btn_rst;
	reg sw_drop;

	// Outputs
	wire [7:0] rgb;
	wire hsync;
	wire vsync;
	wire [7:0] seg;
	wire [3:0] an;
	// Instantiate the Unit Under Test (UUT)
	tetris uut (
		.board_clk(board_clk), 
		.btn_rotate(btn_rotate), 
		.btn_left(btn_left), 
		.btn_right(btn_right), 
		.btn_down(btn_down), 
		.sw_pause(sw_pause), 
		.btn_rst(btn_rst), 
		.sw_drop(sw_drop), 
		.rgb(rgb), 
		.hsync(hsync), 
		.vsync(vsync),
		.seg(seg),
		.an(an)
	);

	initial begin
		// Initialize Inputs
		board_clk = 0;
		btn_rotate = 0;
		btn_left = 0;
		btn_right = 0;
		btn_down = 0;
		sw_pause = 0;
		btn_rst = 0;
		sw_drop = 0;

		// Wait 100 ns for global reset to finish
		#100;	
		       
		// Add stimulus here
		btn_rst = 1;
		#40;
		btn_left = 1;
		#40;
		btn_left = 0;
		#100;
		

	end
	always #20 board_clk = ~board_clk;
      
endmodule

