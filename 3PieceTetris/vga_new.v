`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:30:38 03/19/2013 
// Design Name: 
// Module Name:    vga640x480 
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
//////////////////////////////////////////////////////////////////////////////////
`include "tetris_def.vh"
module vga640x480(
	input wire dclk,			//pixel clock: 25MHz
	input wire clr,			//asynchronous reset
	output wire hsync,		//horizontal sync out
	output wire vsync,		//vertical sync out
	output reg [7:0] rgb,	//blue vga output
    input wire [`BITS_PER_BLOCK-1:0]        cur_tetromino,
    input wire [`BLK_POS-1:0]               cur_blk_1,
    input wire [`BLK_POS-1:0]               cur_blk_2,
    input wire [`BLK_POS-1:0]               cur_blk_3,
    input wire [`BLK_POS-1:0]               cur_blk_4,
    input wire [(`BLOCK_WIDTH*`BLOCK_HEIGHT)-1:0] placed_tetrominos
	);

// video structure constants
parameter hpixels = 800;// horizontal pixels per line
parameter vlines = 521; // vertical lines per frame
parameter hpulse = 96; 	// hsync pulse length
parameter vpulse = 2; 	// vsync pulse length
parameter hbp = 144; 	// end of horizontal back porch
parameter hfp = 784; 	// beginning of horizontal front porch
parameter vbp = 31; 		// end of vertical back porch
parameter vfp = 511; 	// beginning of vertical front porch
// active horizontal video is therefore: 784 - 144 = 640
// active vertical video is therefore: 511 - 31 = 480

// registers for storing the horizontal & vertical counters
reg [9:0] hc;
reg [9:0] vc;

reg [9:0] block = 0;
reg [9:0] block2 = 9;


always @(posedge dclk or posedge clr)
begin
	// reset condition
	if (clr == 1)
	begin
		hc <= 0;
		vc <= 0;
	end
	else
	begin
		// keep counting until the end of the line
		if (hc < hpixels - 1)
			hc <= hc + 1;
		else
		// When we hit the end of the line, reset the horizontal
		// counter and increment the vertical counter.
		// If vertical counter is at the end of the frame, then
		// reset that one too.
		begin
			hc <= 0;
			if (vc < vlines - 1)
				vc <= vc + 1;
			else
				vc <= 0;
		end
		
	end
end

// generate sync pulses (active low)
// ----------------
// "assign" statements are a quick way to
// give values to variables of type: wire
assign hsync = (hc < hpulse) ? 0:1;
assign vsync = (vc < vpulse) ? 0:1;

wire [9:0] cur_blk_index = ((hc-hbp)/`PIXELS_PER_BLOCK) + (((vc-vbp)/`PIXELS_PER_BLOCK)*`BLOCK_WIDTH);

always @(*)
begin
	// first check if we're within vertical active video range
	if (vc >= vbp && vc < vbp + `BOARD_HEIGHT_PX )
    begin
        //if (vc >= `BOARD_Y_START && vc < `BOARD_Y_END)
            //begin
                //check if we're within h board range
                if (hc >= (hbp) && hc < (hbp+`BOARD_WIDTH_PX))
                begin
                    if (cur_blk_index == cur_blk_1 ||
                        cur_blk_index == cur_blk_2 ||
                        cur_blk_index == cur_blk_3 ||
                        cur_blk_index == cur_blk_4                        
                        ) 
                        begin
                                case (cur_tetromino)
                                    `EMPTY_BLOCK: rgb = `BLACK;
                                    `I_BLOCK: rgb = `CYAN;
                                    `O_BLOCK: rgb = `YELLOW;
                                    `T_BLOCK: rgb = `PURPLE;
                                endcase
                                
                        end 
						else 
                        begin
                            rgb = placed_tetrominos[cur_blk_index] ? `WHITE : `ORANGE;
                        end
                end 
				else
                begin
                    rgb = `BLACK;
                end
    end 
    else
    // we're outside active vertical range so display orange
    begin
        rgb = `BLACK;
    end
end

endmodule
