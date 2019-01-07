`include "tetris_def.vh"

module test_pos_rot(
    input wire [`MODE_BITS-1:0]  mode,
    input wire                   game_clk_rst,
    input wire                   game_clk,
    input wire                   btn_left_en,
    input wire                   btn_right_en,
    input wire                   btn_rotate_en,
    input wire                   btn_down_en,
    input wire                   sw_drop_en,
    input wire [`X_POS_IN_BITS-1:0] curr_x,
    input wire [`Y_POS_IN_BITS-1:0] curr_y,
    input wire [`BITS_ROT-1:0]   cur_rot,
    output reg [`X_POS_IN_BITS-1:0] test_pos_x,
    output reg [`Y_POS_IN_BITS-1:0] test_pos_y,
    output reg [`BITS_ROT-1:0]   test_rot
    );

    always @ (*) begin
        if (mode == `MODE_PLAY) begin
            if (game_clk) begin
                test_pos_x = curr_x;
                test_pos_y = curr_y + 1; // move down
                test_rot = cur_rot;
            end else if (btn_left_en) begin
                test_pos_x = curr_x - 1; // move left
                test_pos_y = curr_y;
                test_rot = cur_rot;
            end else if (btn_right_en) begin
                test_pos_x = curr_x + 1; // move right
                test_pos_y = curr_y;
                test_rot = cur_rot;
            end else if (btn_rotate_en) begin
                test_pos_x = curr_x;
                test_pos_y = curr_y;
                test_rot = cur_rot + 1; // rotate
            end else if (btn_down_en) begin
                test_pos_x = curr_x;
                test_pos_y = curr_y + 1; // move down
                test_rot = cur_rot;
            end else if (sw_drop_en) begin
                // do nothing, we set to drop mode
                test_pos_x = curr_x;
                test_pos_y = curr_y;
                test_rot = cur_rot;
            end else begin
                // do nothing, the waiting period in cycle
                test_pos_x = curr_x;
                test_pos_y = curr_y;
                test_rot = cur_rot;
            end
        end else if (mode == `MODE_DROP) begin
            if (game_clk_rst) begin
                // do nothing, we set to play mode
                test_pos_x = curr_x;
                test_pos_y = curr_y;
                test_rot = cur_rot;
            end else begin
                test_pos_x = curr_x;
                test_pos_y = curr_y + 1; // move down
                test_rot = cur_rot;
            end
        end else begin
            // Other mode, do nothing
            test_pos_x = curr_x;
            test_pos_y = curr_y;
            test_rot = cur_rot;
        end
    end

endmodule
