// Top-level module for DE2 board with clock, stopwatch, and timer functions

module top(
    input CLOCK_50,
    input [17:0] SW,
    input [3:0] KEY,
    output [6:0] HEX0,
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3,
    output [6:0] HEX4,
    output [6:0] HEX5
);

    wire clk_1Hz;
    wire reset = ~KEY[0];

    // Divide clock from 50MHz to 1Hz
    clock_divider clkdiv(
        .clk_50MHz(CLOCK_50),
        .reset(reset),
        .clk_1Hz(clk_1Hz)
    );

    wire [5:0] seconds, minutes;
    wire [4:0] hours;

    clock clock_inst(
        .clk_1Hz(clk_1Hz),
        .reset(reset),
        .set_time_mode(SW[0]),
        .inc_minutes(~KEY[1]),
        .inc_hours(~KEY[2]),
        .stopwatch_mode(SW[1]),
        .start_stopwatch(~KEY[3]),
        .stop_stopwatch(~KEY[3]),
        .reset_stopwatch(~KEY[3]),
        .timer_mode(SW[2]),
        .set_timer_mode(SW[3]),
        .inc_timer_hours(~KEY[3]),
        .inc_timer_minutes(~KEY[3]),
        .inc_timer_seconds(~KEY[3]),
        .start_timer(~KEY[3]),
        .stop_timer(~KEY[3]),
        .reset_timer(~KEY[3]),
        .seconds(seconds),
        .minutes(minutes),
        .hours(hours),
        .stopwatch_seconds(),
        .stopwatch_minutes(),
        .stopwatch_hours(),
        .timer_seconds(),
        .timer_minutes(),
        .timer_hours(),
        .is_stopwatch_running(),
        .is_timer_running(),
        .timer_done(),
        .carry()
    );

    // Display clock time on HEX displays
    seg7 decoder0(.in(seconds % 10), .out(HEX0));
    seg7 decoder1(.in(seconds / 10), .out(HEX1));
    seg7 decoder2(.in(minutes % 10), .out(HEX2));
    seg7 decoder3(.in(minutes / 10), .out(HEX3));
    seg7 decoder4(.in(hours % 10), .out(HEX4));
    seg7 decoder5(.in(hours / 10), .out(HEX5));

endmodule

// Clock Divider 50MHz -> 1Hz
module clock_divider(
    input clk_50MHz,
    input reset,
    output reg clk_1Hz
);
    reg [25:0] counter;
    always @(posedge clk_50MHz or posedge reset) begin
        if (reset) begin
            counter <= 0;
            clk_1Hz <= 0;
        end else if (counter == 25_000_000) begin
            counter <= 0;
            clk_1Hz <= ~clk_1Hz;
        end else begin
            counter <= counter + 1;
        end
    end
endmodule

// 7-segment decoder (0–9 only)
module seg7(
    input [3:0] in,
    output reg [6:0] out
);
    always @(*) begin
        case (in)
            4'd0: out = 7'b1000000;
            4'd1: out = 7'b1111001;
            4'd2: out = 7'b0100100;
            4'd3: out = 7'b0110000;
            4'd4: out = 7'b0011001;
            4'd5: out = 7'b0010010;
            4'd6: out = 7'b0000010;
            4'd7: out = 7'b1111000;
            4'd8: out = 7'b0000000;
            4'd9: out = 7'b0010000;
            default: out = 7'b1111111;
        endcase
    end
endmodule