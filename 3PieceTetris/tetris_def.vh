//Board dimensions and size of each block in pixels
`define PIXEL_WIDTH 800
`define PIXEL_HEIGHT 521

`define PIXELS_PER_BLOCK 20
`define BLOCK_WIDTH 10
`define BLOCK_HEIGHT 20
`define BOARD_WIDTH_PX (`BLOCK_WIDTH * `PIXELS_PER_BLOCK)	//200
`define BOARD_HEIGHT_PX (`BLOCK_HEIGHT * `PIXELS_PER_BLOCK)	//400

//store the 3 different BLOCKS: O,I,T
`define BITS_PER_BLOCK 2

//store the size of each piece(max 4)
`define BITS_BLK_SIZE 3

//need 3 bits to represent 4 possible rot's
`define BITS_ROT 2

//number of different pieces
`define BLOCK_TYPES 3

`define X_POS_IN_BITS 4	//2^3 < 8 < 2^4
`define Y_POS_IN_BITS 5

//8x20 possiblilities in placed_tetrominos[]
//position in the array
`define BLK_POS 8

//pieces
`define EMPTY_BLOCK 3'b000
`define I_BLOCK 3'b001
`define O_BLOCK 3'b010
`define T_BLOCK 3'b011

//screen params
`define HSYNC_FRONT_PORCH 144
`define HSYNC_PULSE_WIDTH 96
`define HSYNC_BACK_PORCH 784
`define VSYNC_FRONT_PORCH 31
`define VSYNC_PULSE_WIDTH 2
`define VSYNC_BACK_PORCH 511

`define BOARD_X_START (`PIXEL_WIDTH/2) - (`BOARD_WIDTH_PX/2)-1 //219
`define BOARD_X_END `BOARD_X_START + (`BOARD_WIDTH_PX)	//420

`define BOARD_Y_START (`PIXEL_HEIGHT/2) - (`BOARD_HEIGHT_PX/2)-1	// 39
`define BOARD_Y_END `BOARD_HEIGHT_PX+`BOARD_Y_START

// Color mapping
`define ORANGE 8'b00011111
`define BLACK 8'b00000000
`define CYAN 8'b11110000
`define YELLOW 8'b00111111
`define PURPLE 8'b11000111
`define WHITE 8'b11111111

`define MODE_BITS 3
`define MODE_PLAY 0
`define MODE_DROP 1
`define MODE_PAUSE 2
`define MODE_IDLE 3
`define MODE_CLEAR 4

`define DROP_TIMER_MAX 10000
`define ERR_BLK_POS 8'b11111111


