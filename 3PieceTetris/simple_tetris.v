`include "tetris_def.vh"

module tetris(
    input wire        board_clk,
    input wire        btn_rotate,
    input wire        btn_left,
    input wire        btn_right,
    input wire        btn_down,
    input wire        sw_pause,
    input wire        btn_rst,
	 input wire        sw_drop,
    output wire [7:0] rgb,
    output wire       hsync,
    output wire       vsync,
    output wire [7:0] seg,
    output wire [3:0] an
    );
	
	 // Use 25 MHz for VGA output
    reg count25;
    reg clk; 
    initial begin
        count25 = 0;
        clk = 0;
    end
    always @ (posedge board_clk) begin
        count25 <= ~count25;
        if (count25) begin
            clk <= ~clk;
        end
    end
	
	wire [`BITS_PER_BLOCK-1:0] random_tetromino;// = $urandom % 4;//outputs 0 to 2

    randomizer randomizer_ (
        .clk(clk),
        .random(random_tetromino)
    );
	
	//debounced signals
	//switches need to keep track of both enabled disabled signal
    wire sw_pause_en;
    wire sw_pause_dis;

    wire sw_drop_en;
    wire sw_drop_dis;
	//btns need to keep track of enabled
    wire btn_rotate_en;
    wire btn_left_en;
    wire btn_right_en;
    wire btn_down_en;
    wire btn_rst_en;

	debouncer debouncer_pause_ (
        .raw(sw_pause),
        .clk(clk),
        .enabled(sw_pause_en),
		.disabled(sw_pause_dis)
    );
	debouncer debouncer_drop_ (
        .raw(sw_drop),
        .clk(clk),
        .enabled(sw_drop_en),
		.disabled(sw_drop_dis)		
    );
    debouncer debouncer_rotate_ (
        .raw(btn_rotate),
        .clk(clk),
        .enabled(btn_rotate_en),
		  .disabled()
    );
    debouncer debouncer_left_ (
        .raw(btn_left),
        .clk(clk),
        .enabled(btn_left_en),
		  .disabled()
    );
    debouncer debouncer_right_ (
        .raw(btn_right),
        .clk(clk),
        .enabled(btn_right_en),
		  .disabled()
    );
    debouncer debouncer_down_ (
        .raw(btn_down),
        .clk(clk),
        .enabled(btn_down_en),
		  .disabled()
    );
	debouncer debouncer_rst_ (
        .raw(btn_rst),
        .clk(clk),
        .enabled(btn_rst_en),
		  .disabled()
    );
	
	//y_pos * BLOCK_WIDTH + x_pos
    reg [(`BLOCK_WIDTH*`BLOCK_HEIGHT)-1:0] placed_tetrominos;
	
	//keep track of colors of fallen pieces
    reg [(`BLOCK_WIDTH*`BLOCK_HEIGHT)-1:0] O_tetrominos;
    reg [(`BLOCK_WIDTH*`BLOCK_HEIGHT)-1:0] I_tetrominos;
    reg [(`BLOCK_WIDTH*`BLOCK_HEIGHT)-1:0] T_tetrominos;
	
    reg [`BITS_PER_BLOCK-1:0] cur_tetromino;
    reg [`X_POS_IN_BITS-1:0] curr_x;
    reg [`Y_POS_IN_BITS-1:0] curr_y;
	
    //(0 == 0 degrees, 1 == 90 degrees, etc)
    reg [`BITS_ROT-1:0] cur_rot;
	
    // The 4 position of each piece in the flattened array
    wire [`BLK_POS-1:0] cur_blk_1;
    wire [`BLK_POS-1:0] cur_blk_2;
    wire [`BLK_POS-1:0] cur_blk_3;
    wire [`BLK_POS-1:0] cur_blk_4;
	
    // Width and height based on rotation and type
    wire [`BITS_BLK_SIZE-1:0] cur_width;
    wire [`BITS_BLK_SIZE-1:0] cur_height;
    // Use a calc_cur_blk module to get the values of the wires above from
    // the current position, type, and rotation of the falling tetromino.
	
	// 
    reg [31:0] drop_timer;  
    
    calc_cur_blk calc_cur_blk_(
        .piece(cur_tetromino),
        .pos_x(curr_x),
        .pos_y(curr_y),
        .rot(cur_rot),
        .blk_1(cur_blk_1),
        .blk_2(cur_blk_2),
        .blk_3(cur_blk_3),
        .blk_4(cur_blk_4),
        .width(cur_width),
        .height(cur_height)
    );
    
	vga640x480 vga_(
        .dclk(clk),
        .clr(btn_rst_en),
        .cur_tetromino(cur_tetromino),
        .cur_blk_1(cur_blk_1),
        .cur_blk_2(cur_blk_2),
        .cur_blk_3(cur_blk_3),
        .cur_blk_4(cur_blk_4),
        .placed_tetrominos(placed_tetrominos),
        .rgb(rgb),
        .hsync(hsync),
        .vsync(vsync)
    );
	
	reg [`MODE_BITS-1:0] mode;
    reg [`MODE_BITS-1:0] old_mode;
    // 1 Hz clock
    wire game_clk;
    // Software reset
    reg game_clk_rst;

    game_clock game_clock_ (
        .clk(clk),
        .rst(game_clk_rst),
        .pause(mode != `MODE_PLAY),
        .game_clk(game_clk)
    );
    wire [`X_POS_IN_BITS-1:0] test_pos_x;
    wire [`Y_POS_IN_BITS-1:0] test_pos_y;
    wire [`BITS_ROT-1:0] test_rot;
    // Combinational logic to determine what position/rotation we are testing.
    // Essentially calculates the next move based on button inputs 
	//	"test_pos_x" represents the next cycle's x position
	// Will update test_block_x and y if curr_x and curr_y change
    test_pos_rot test_pos_rot_ (
        .mode(mode),
        .game_clk_rst(game_clk_rst),
        .game_clk(game_clk),
        .btn_left_en(btn_left_en),
        .btn_right_en(btn_right_en),
        .btn_rotate_en(btn_rotate_en),
        .btn_down_en(btn_down_en),
        .sw_drop_en(sw_drop),
        .curr_x(curr_x),
        .curr_y(curr_y),
        .cur_rot(cur_rot),
        .test_pos_x(test_pos_x),
        .test_pos_y(test_pos_y),
        .test_rot(test_rot)
    );
	
	// Calculate the position in the array that test_pos_x will land on
	// based off tetromino type and rotation
	wire [`BLK_POS-1:0] test_blk_1;
    wire [`BLK_POS-1:0] test_blk_2;
    wire [`BLK_POS-1:0] test_blk_3;
    wire [`BLK_POS-1:0] test_blk_4;
    wire [2:0] test_width;
    wire [2:0] test_height;
    calc_cur_blk calc_test_block_ (
        .piece(cur_tetromino),
        .pos_x(test_pos_x),
        .pos_y(test_pos_y),
        .rot(test_rot),
        .blk_1(test_blk_1),
        .blk_2(test_blk_2),
        .blk_3(test_blk_3),
        .blk_4(test_blk_4),
        .width(test_width),
        .height(test_height)
    );

	// Checks whether its input block positions intersect
    // with any stored fallen pieces.
    function intersects_placed_tetrominos;
        input wire [7:0] blk1;
        input wire [7:0] blk2;
        input wire [7:0] blk3;
        input wire [7:0] blk4;
        begin
            intersects_placed_tetrominos = placed_tetrominos[blk1] ||
                                       placed_tetrominos[blk2] ||
                                       placed_tetrominos[blk3] ||
                                       placed_tetrominos[blk4];
        end
    endfunction
	
	wire intersection = intersects_placed_tetrominos(test_blk_1, test_blk_2, test_blk_3, test_blk_4);
	
    // If the falling piece can be moved left, moves it left
	task move_left;
        begin
            if (curr_x > 0 && !intersection) begin
                curr_x <= curr_x - 1;
            end
        end
    endtask

    // If the falling piece can be moved right, moves it right
    task move_right;
        begin
            if (curr_x + cur_width < `BLOCK_WIDTH && !intersection) begin
                curr_x <= curr_x + 1;
            end
        end
    endtask

    // Rotates the current block if it would not cause any part of the
    // block to go off screen and would not intersect with any fallen blocks.
    task rotate;
        begin
            if (curr_x + test_width <= `BLOCK_WIDTH &&
                curr_y + test_height <= `BLOCK_HEIGHT &&
                !intersection) begin
                cur_rot <= cur_rot + 1;
            end
        end
    endtask
	
	task add_to_placed_tetrominos;
        begin
            placed_tetrominos[cur_blk_1] <= 1;
            placed_tetrominos[cur_blk_2] <= 1;
            placed_tetrominos[cur_blk_3] <= 1;
            placed_tetrominos[cur_blk_4] <= 1;
			case(cur_tetromino)
				`I_BLOCK:begin	//keep track of color
					I_tetrominos[cur_blk_1] <= 1;
					I_tetrominos[cur_blk_2] <= 1;
					I_tetrominos[cur_blk_3] <= 1;
					I_tetrominos[cur_blk_4] <= 1;
				end
				`O_BLOCK: begin
					O_tetrominos[cur_blk_1] <= 1;
					O_tetrominos[cur_blk_2] <= 1;
					O_tetrominos[cur_blk_3] <= 1;
					O_tetrominos[cur_blk_4] <= 1;
				end
				`T_BLOCK: begin
					T_tetrominos[cur_blk_1] <= 1;
					T_tetrominos[cur_blk_2] <= 1;
					T_tetrominos[cur_blk_3] <= 1;
					T_tetrominos[cur_blk_4] <= 1;
				end
			endcase
		end
    endtask

	// Choose a new block
    task get_new_block;
        begin
            // Reset the drop timer, can't drop until this is high enough
            drop_timer <= 0;
            cur_tetromino <= random_tetromino;
            curr_x <= (`BLOCK_WIDTH / 2) - 1;
            curr_y <= 0;
            cur_rot <= 0;
            // reset the game timer so the user has a full
            // cycle before the block falls
            game_clk_rst <= 1;
        end
    endtask

    // Moves the current piece down one, getting a new block if
    // the piece would go off the board or intersect with another block.
    task move_down;
        begin
            if (curr_y + cur_height < `BLOCK_HEIGHT && !intersection) begin
                curr_y <= curr_y + 1;
            end else begin
                add_to_placed_tetrominos();
                get_new_block();
            end
        end
    endtask

    // Sets the mode to MODE_DROP, in which the current block will not respond
    // to user input and it will move down at one cycle per second until it hits
    // a block or the bottom of the board.
    task drop_to_bottom;
        begin
            mode <= `MODE_DROP;
        end
    endtask
	
	reg [3:0] score_1; // 1's place
    reg [3:0] score_2; // 10's place
    reg [3:0] score_3; // 100's place
    reg [3:0] score_4; // 1000's place
	
	score_display score_display_ (
        .clk(clk),
        .score_1(score_1),
        .score_2(score_2),
        .score_3(score_3),
        .score_4(score_4),
        .an(an),
        .seg(seg)
    );
    // The module that determines which row, if any, is complete
    // and needs to be removed and the score incremented
    wire [`Y_POS_IN_BITS-1:0] remove_row_y;
    wire remove_row_en;
    complete_row complete_row_ (
        .clk(clk),
        .pause(mode != `MODE_PLAY),
        .placed_tetrominos(placed_tetrominos),
        .row(remove_row_y),
        .enabled(remove_row_en)
    );

    // This task removes the completed row from placed_tetrominos
    // and increments the score
    reg [`Y_POS_IN_BITS-1:0] shifting_row;
    task remove_row;
        begin
            // Shift away remove_row_y
            mode <= `MODE_CLEAR;
            shifting_row <= remove_row_y;
            // Increment the score
            if (score_1 == 9) begin
                if (score_2 == 9) begin
                    if (score_3 == 9) begin
                        if (score_4 != 9) begin
                            score_4 <= score_4 + 1;
                            score_3 <= 0;
                            score_2 <= 0;
                            score_1 <= 0;
                        end
                    end else begin
                        score_3 <= score_3 + 1;
                        score_2 <= 0;
                        score_1 <= 0;
                    end
                end else begin
                    score_2 <= score_2 + 1;
                    score_1 <= 0;
                end
            end else begin
                score_1 <= score_1 + 1;
            end
        end
    endtask
	
	initial begin
        mode = `MODE_IDLE;
        placed_tetrominos = 0;
		O_tetrominos = 0;
		I_tetrominos = 0;
		T_tetrominos = 0;
        cur_tetromino = `EMPTY_BLOCK;
        curr_x = 0;
        curr_y = 0;
        cur_rot = 0;
        score_1 = 0;
        score_2 = 0;
        score_3 = 0;
        score_4 = 0;
    end

	task start_game;
        begin
            mode <= `MODE_PLAY;
            placed_tetrominos <= 0;
			O_tetrominos <= 0;
			I_tetrominos <= 0;
			T_tetrominos <= 0;
            score_1 <= 0;
            score_2 <= 0;
            score_3 <= 0;
            score_4 <= 0;
            get_new_block();
        end
    endtask
	
    // Determine if the game is over because the current position
    // intersects with a fallen block
    wire game_over = curr_y == 0 && intersects_placed_tetrominos(cur_blk_1, cur_blk_2, cur_blk_3, cur_blk_4);
	always @ (posedge clk) begin
        if (drop_timer < `DROP_TIMER_MAX) begin
            drop_timer <= drop_timer + 1;
        end
        game_clk_rst <= 0;
        if (mode == `MODE_IDLE && (btn_rst_en)) begin
            start_game();
        end else if (btn_rst_en || game_over) begin
            mode <= `MODE_IDLE;
            add_to_placed_tetrominos();
            cur_tetromino <= `EMPTY_BLOCK;
        end else if ((sw_pause_en || sw_pause_dis) && mode == `MODE_PLAY) begin
            mode <= `MODE_PAUSE;
        end else if ((sw_pause_en || sw_pause_dis) && mode == `MODE_PAUSE) begin
            mode <= `MODE_PLAY;
        end else if (mode == `MODE_PLAY) begin
            // Normal gameplay
            if (game_clk) begin
                move_down();
            end else if (btn_left_en) begin
                move_left();
            end else if (btn_right_en) begin
                move_right();
            end else if (btn_rotate_en) begin
                rotate();
            end else if (btn_down_en) begin
                move_down();
            end else if (sw_drop_en && drop_timer == `DROP_TIMER_MAX) begin
                drop_to_bottom();
            end else if (remove_row_en) begin
                remove_row();
            end
        end else if (mode == `MODE_DROP) begin
            if (game_clk_rst && !sw_pause_en) begin
                mode <= `MODE_PLAY;
            end else begin
                move_down();
            end
        end else if (mode == `MODE_CLEAR) begin
            if (shifting_row == 0) begin
                placed_tetrominos[0 +: `BLOCK_WIDTH] <= 0;
                mode <= `MODE_PLAY;
            end else begin
                placed_tetrominos[shifting_row*`BLOCK_WIDTH +: `BLOCK_WIDTH] <= placed_tetrominos[(shifting_row - 1)*`BLOCK_WIDTH +: `BLOCK_WIDTH];
                shifting_row <= shifting_row - 1;
            end
        end
    end
	
endmodule	