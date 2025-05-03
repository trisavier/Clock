`timescale 1s / 1ms  // 1Hz clock

module clock_tb;

    reg clk_1Hz = 0;
    reg reset = 0;

    // Clock inputs
    reg set_time_mode = 0;
    reg inc_minutes = 0;
    reg inc_hours = 0;

    // Stopwatch
    reg stopwatch_mode = 0;
    reg start_stopwatch = 0;
    reg stop_stopwatch = 0;
    reg reset_stopwatch = 0;

    // Timer
    reg timer_mode = 0;
    reg set_timer_mode = 0;
    reg inc_timer_hours = 0;
    reg inc_timer_minutes = 0;
    reg inc_timer_seconds = 0;
    reg start_timer = 0;
    reg stop_timer = 0;
    reg reset_timer = 0;

    // Outputs
    wire [5:0] seconds, minutes, stopwatch_seconds, stopwatch_minutes, timer_seconds, timer_minutes;
    wire [4:0] hours, stopwatch_hours, timer_hours;
    wire is_stopwatch_running, is_timer_running, timer_done, carry;

    // Instantiate the module
    clock uut (
        .clk_1Hz(clk_1Hz), .reset(reset),
        .set_time_mode(set_time_mode), .inc_minutes(inc_minutes), .inc_hours(inc_hours),
        .stopwatch_mode(stopwatch_mode), .start_stopwatch(start_stopwatch), .stop_stopwatch(stop_stopwatch), .reset_stopwatch(reset_stopwatch),
        .timer_mode(timer_mode), .set_timer_mode(set_timer_mode),
        .inc_timer_hours(inc_timer_hours), .inc_timer_minutes(inc_timer_minutes), .inc_timer_seconds(inc_timer_seconds),
        .start_timer(start_timer), .stop_timer(stop_timer), .reset_timer(reset_timer),
        .seconds(seconds), .minutes(minutes), .hours(hours),
        .stopwatch_seconds(stopwatch_seconds), .stopwatch_minutes(stopwatch_minutes), .stopwatch_hours(stopwatch_hours),
        .timer_seconds(timer_seconds), .timer_minutes(timer_minutes), .timer_hours(timer_hours),
        .is_stopwatch_running(is_stopwatch_running), .is_timer_running(is_timer_running),
        .timer_done(timer_done), .carry(carry)
    );

    // Clock generation: 1Hz
    always #0.5 clk_1Hz = ~clk_1Hz;

    initial begin
        $display("=== TEST START ===");
        reset = 1;
        #1;
        reset = 0;

        // ======================
        // TEST 1: Đếm giờ chính
        // ======================
        $display("Test: Main Clock Counting");
        #5;

        // ======================
        // TEST 2: Set Time Mode
        // ======================
        $display("Test: Set Time");
        set_time_mode = 1;
        inc_minutes = 1;
        #1; inc_minutes = 0;
        inc_hours = 1;
        #1; inc_hours = 0;
        set_time_mode = 0;

        #3;

        // ======================
        // TEST 3: Stopwatch
        // ======================
        $display("Test: Stopwatch Start/Stop/Reset");
        stopwatch_mode = 1;
        start_stopwatch = 1;
        #1; start_stopwatch = 0;
        #3;
        stop_stopwatch = 1;
        #1; stop_stopwatch = 0;
        #2;
        reset_stopwatch = 1;
        #1; reset_stopwatch = 0;
        stopwatch_mode = 0;

        // ======================
        // TEST 4: Timer
        // ======================
        $display("Test: Timer Set/Start/Stop");
        timer_mode = 1;
        set_timer_mode = 1;

        repeat (5) begin
            inc_timer_seconds = 1;
            #1;
            inc_timer_seconds = 0;
        end

        set_timer_mode = 0;

        start_timer = 1;
        #1;
        start_timer = 0;

        #6; // chờ hết 5 giây

        $display("Timer Done: %d", timer_done);

        $display("=== TEST END ===");
        $finish;
    end

endmodule
