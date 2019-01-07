`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:19:51 11/30/2018
// Design Name:   randomizer
// Module Name:   C:/Users/152/Desktop/EZ1/simple_tetris1/random_tb.v
// Project Name:  simple_tetris1
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: randomizer
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////
`timescale 1 ns / 10 ps
module random_tb;

	// Inputs
	reg clk;

	// Outputs
	wire [1:0] random;

	// Instantiate the Unit Under Test (UUT)
	randomizer uut (
		.clk(clk), 
		.random(random)
	);

	initial begin
		// Initialize Inputs
		clk = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
	always #20 clk = ~clk;
	
	
      
endmodule

