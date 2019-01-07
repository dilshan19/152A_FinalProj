`include "tetris_def.vh"

module randomizer(
    input wire       clk,
    output reg [`BITS_PER_BLOCK-1:0] random
    );

    initial begin
        random = 1;
    end

    //Outputs "random" depending on user input, so random
    always @ (posedge clk) begin
        if (random == `BLOCK_TYPES) begin
            random <= 1;
        end else begin
            random <= random + 1;
        end
    end

endmodule
