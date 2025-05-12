module clock(
    input clk_1Hz,
    input reset,

    // ==== Chức năng Đồng hồ ====
    input set_time_mode,
    input inc_minutes,
    input inc_hours,

    // ==== Chức năng Stopwatch ====
    input stopwatch_mode,
    input start_stopwatch,
    input stop_stopwatch,
    input reset_stopwatch,

    // ==== Chức năng Timer ====
    input timer_mode,
    input set_timer_mode,
    input inc_timer_hours,
	 input inc_timer_minutes,
	 input inc_timer_seconds,
    input start_timer,
    input stop_timer,
    input reset_timer,

    // ==== Outputs ====
    output reg [5:0] seconds,
    output reg [5:0] minutes,
    output reg [4:0] hours,
    output reg [5:0] stopwatch_seconds,
    output reg [5:0] stopwatch_minutes,
    output reg [4:0] stopwatch_hours,
    output reg [5:0] timer_seconds,
    output reg [5:0] timer_minutes,
    output reg [4:0] timer_hours,
    output reg is_stopwatch_running,
    output reg is_timer_running,
    output reg timer_done,
    output reg carry
);

    reg stopwatch_running = 0;
    reg timer_running = 0;

    always @(posedge clk_1Hz or posedge reset) begin
        if (reset) begin
            seconds <= 0;
            minutes <= 0;
            hours <= 0;

            stopwatch_seconds <= 0;
            stopwatch_minutes <= 0;
            stopwatch_hours <= 0;
            stopwatch_running <= 0;
            is_stopwatch_running <= 0;

            timer_seconds <= 0;
            timer_minutes <= 0;
            timer_hours <= 0;
            timer_running <= 0;
            is_timer_running <= 0;
            timer_done <= 0;

            carry <= 0;

        end else begin
            // ==== Stopwatch logic ====
            if (reset_stopwatch) begin
                stopwatch_seconds <= 0;
                stopwatch_minutes <= 0;
                stopwatch_hours <= 0;
                stopwatch_running <= 0;
            end else if (start_stopwatch) begin
                stopwatch_running <= 1;
            end else if (stop_stopwatch) begin
                stopwatch_running <= 0;
            end

            // ==== Timer logic ====
            if (set_timer_mode) begin
					 if (inc_timer_seconds)
						  timer_seconds <= (timer_seconds == 6'd59) ? 0 : timer_seconds + 1;
					 if (inc_timer_minutes)
						  timer_minutes <= (timer_minutes == 6'd59) ? 0 : timer_minutes + 1;
					 if (inc_timer_hours)
						  timer_hours <= (timer_hours == 5'd23) ? 0 : timer_hours + 1;

					 timer_done <= 0;
				end else if (reset_timer) begin
                timer_hours <= 0;
                timer_minutes <= 0;
                timer_seconds <= 0;
                timer_running <= 0;
                timer_done <= 0;
            end else if (start_timer) begin
                timer_running <= 1;
                timer_done <= 0;
            end else if (stop_timer) begin
                timer_running <= 0;
            end

            // ==== Set clock time ====
            if (set_time_mode) begin
                if (inc_minutes)
                    minutes <= (minutes == 6'd59) ? 0 : minutes + 1;
                if (inc_hours)
                    hours <= (hours == 5'd23) ? 0 : hours + 1;
            end

// ==== Main clock counting ====
if (seconds == 6'd59) begin
    seconds <= 0;
    if (minutes == 6'd59) begin
        minutes <= 0;
        if (hours == 5'd23)
            hours <= 0;
        else
            hours <= hours + 1;
    end else begin
        minutes <= minutes + 1;
    end
end else begin
    seconds <= seconds + 1;
end

            // ==== Stopwatch counting ====
            if (stopwatch_mode && stopwatch_running) begin
                if (stopwatch_seconds == 6'd59) begin
                    stopwatch_seconds <= 0;
                    if (stopwatch_minutes == 6'd59) begin
                        stopwatch_minutes <= 0;
                        if (stopwatch_hours == 5'd23)
                            stopwatch_hours <= 0;
                        else
                            stopwatch_hours <= stopwatch_hours + 1;
                    end else begin
                        stopwatch_minutes <= stopwatch_minutes + 1;
                    end
                end else begin
                    stopwatch_seconds <= stopwatch_seconds + 1;
                end
            end

            // ==== Timer counting down ====
            if (timer_mode && timer_running && !timer_done) begin
                if (timer_hours == 0 && timer_minutes == 0 && timer_seconds == 0) begin
                    timer_done <= 1;
                    timer_running <= 0;
                end else begin
                    if (timer_seconds == 0) begin
                        timer_seconds <= 59;
                        if (timer_minutes == 0) begin
                            timer_minutes <= 59;
                            if (timer_hours != 0)
                                timer_hours <= timer_hours - 1;
                        end else begin
                            timer_minutes <= timer_minutes - 1;
                        end
                    end else begin
                        timer_seconds <= timer_seconds - 1;
                    end
                end
            end

            is_stopwatch_running <= stopwatch_running;
            is_timer_running <= timer_running;
        end
    end
endmodule
