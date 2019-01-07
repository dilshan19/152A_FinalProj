`include "tetris_def.vh"

module score_display(
    input wire       clk,
    input wire [3:0] score_1, // 1's place
    input wire [3:0] score_2, 
    input wire [3:0] score_3, 
    input wire [3:0] score_4, // 1000's place
    output reg [7:0] seg,
    output reg [3:0] an
    );

    // Divide the clock to 250Hz for display
	// 1/ ((1/25e6) * 50000 *2)
    reg [17:0] counter;
    reg seg_clk;
    always @ (posedge clk) begin
        if (counter == 50000) begin
            counter <= 0;
            seg_clk <= 1;
        end else begin
            counter <= counter + 1;
            seg_clk <= 0;
        end
    end

    // Which digit we are currently displaying
    reg [1:0] digit;

    initial begin
        digit = 0;
        counter = 0;
    end

    always @ (posedge seg_clk) begin
        digit <= digit + 1;
        if (digit == 2'b00) begin
            an <= 4'b0111;
            display_digit(score_4);
        end else if (digit == 1) begin
            an <= 4'b1011;
            display_digit(score_3);
        end else if (digit == 2) begin
            an <= 4'b1101;
            display_digit(score_2);
        end else begin
            an <= 4'b1110;
            display_digit(score_1);
        end
    end

    task display_digit;
        input [3:0] in;
        begin
            case (in)
                0: seg <= 8'b11000000;
                1: seg <= 8'b11111001;
                2: seg <= 8'b10100100;
                3: seg <= 8'b10110000;
                4: seg <= 8'b10011001;
                5: seg <= 8'b10010010;
                6: seg <= 8'b10000010;
                7: seg <= 8'b11111000;
                8: seg <= 8'b10000000;
				9: seg <= 8'b10010000;          
            default: seg <=  8'b11111111 ;
            endcase
        end
    endtask

endmodule
