`include "tetris_def.vh"

module complete_row(
    input wire                                   clk,
    input wire                                   pause,
    input wire [(`BLOCK_WIDTH*`BLOCK_HEIGHT)-1:0] placed_tetrominos,
    output reg [`Y_POS_IN_BITS-1:0]                 row,
    output wire                                  enabled
    );

    initial begin
        row = 0;
    end

     // Check if each row is complete
     assign enabled = &placed_tetrominos[row*`BLOCK_WIDTH +: `BLOCK_WIDTH];

     // Continuously check each row
     always @ (posedge clk) begin
         if (!pause) begin
             if (row == `BLOCK_HEIGHT - 1) begin
                 row <= 0;
             end else begin
                 row <= row + 1;
             end
         end
     end

endmodule
