module clock(
    // ==== INPUTS ====
    input clk_1Hz,                      // Clock 1Hz dùng cho mọi chức năng đếm
    input reset,                        // Reset toàn bộ hệ thống

    // Set Time Inputs
    input set_time_mode,               // Bật chế độ chỉnh thời gian hiện tại
    input inc_minutes,                 // Tăng phút hiện tại
    input inc_hours,                   // Tăng giờ hiện tại
    input inc_seconds,                // Tăng giây hiện tại

    // Stopwatch Inputs
    input stopwatch_mode,             // Bật chế độ đồng hồ bấm giờ
    input start_stopwatch,            // Bắt đầu stopwatch
    input stop_stopwatch,             // Dừng stopwatch
    input reset_stopwatch,            // Reset stopwatch

    // Timer Inputs
    input timer_mode,                 // Bật chế độ hẹn giờ
    input set_timer_mode,             // Bật chế độ thiết lập thời gian timer
    input inc_timer_hours,            // Tăng giờ timer
    input inc_timer_minutes,          // Tăng phút timer
    input inc_timer_seconds,          // Tăng giây timer
    input start_timer,                // Bắt đầu timer
    input stop_timer,                 // Dừng timer
    input reset_timer,                // Reset timer

    // Alarm Inputs
    input set_alarm_mode,             // Bật chế độ cài báo thức
    input inc_alarm_hours,            // Tăng giờ báo thức
    input inc_alarm_minutes,          // Tăng phút báo thức
    input alarm_reset,                // Tắt báo thức khi đang reo

    // ==== OUTPUTS ====
    output reg [5:0] seconds,          // Giây hiện tại
    output reg [5:0] minutes,          // Phút hiện tại
    output reg [4:0] hours,            // Giờ hiện tại

    output reg [5:0] stopwatch_seconds, // Stopwatch: giây
    output reg [5:0] stopwatch_minutes, // Stopwatch: phút
    output reg [4:0] stopwatch_hours,   // Stopwatch: giờ
    output reg [5:0] timer_seconds,     // Timer: giây
    output reg [5:0] timer_minutes,     // Timer: phút
    output reg [4:0] timer_hours,       // Timer: giờ

    output reg is_stopwatch_running,    // Trạng thái stopwatch đang chạy
    output reg is_timer_running,        // Trạng thái timer đang chạy
    output reg timer_done,              // Báo hiệu timer đã kết thúc

    output reg alarm_trigger,           // Cờ báo thức kích hoạt

    output reg [4:0] debug_alarm_hours,   // Debug: giờ báo thức
    output reg [5:0] debug_alarm_minutes, // Debug: phút báo thức
    output reg [4:0] alarm_hours,         // Giờ báo thức
    output reg [5:0] alarm_minutes        // Phút báo thức
);

    reg stopwatch_running = 0;         // Lưu trạng thái stopwatch có đang chạy không
    reg timer_running = 0;             // Lưu trạng thái timer có đang chạy không

    // Các biến dùng để phát hiện rising edge của tín hiệu điều khiển (edge detection)
    reg prev_start_stopwatch = 0;
    reg prev_stop_stopwatch = 0;
    reg prev_reset_stopwatch = 0;
    reg prev_start_timer = 0;
    reg prev_stop_timer = 0;
    reg prev_reset_timer = 0;
    reg prev_alarm_reset = 0;

    always @(posedge clk_1Hz or posedge reset) begin
        if (reset) begin
		      // Reset toàn bộ trạng thái về 0
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
            alarm_hours <= 0;
            alarm_minutes <= 0;
            alarm_trigger <= 0;
            prev_start_stopwatch <= 0;
            prev_stop_stopwatch <= 0;
            prev_reset_stopwatch <= 0;
            prev_start_timer <= 0;
            prev_stop_timer <= 0;
            prev_reset_timer <= 0;
            prev_alarm_reset <= 0;
            debug_alarm_hours <= 0;
            debug_alarm_minutes <= 0;
        end else begin
            if (stopwatch_mode && !set_alarm_mode) begin
                if (start_stopwatch && !prev_start_stopwatch)
                    stopwatch_running <= 1;
                if (stop_stopwatch && !prev_stop_stopwatch)
                    stopwatch_running <= 0;
                // Reset thời gian và dừng stopwatch
					 if (reset_stopwatch && !prev_reset_stopwatch) begin
                    stopwatch_seconds <= 0;
                    stopwatch_minutes <= 0;
                    stopwatch_hours <= 0;
                    stopwatch_running <= 0;
                end
            end
				
            prev_start_stopwatch <= start_stopwatch;
            prev_stop_stopwatch <= stop_stopwatch;
            prev_reset_stopwatch <= reset_stopwatch;
            
				// Tăng timer theo các nút bấm
            if (set_timer_mode && !set_alarm_mode) begin
                if (inc_timer_seconds)
                    timer_seconds <= (timer_seconds == 6'd59) ? 0 : timer_seconds + 1;
                if (inc_timer_minutes)
                    timer_minutes <= (timer_minutes == 6'd59) ? 0 : timer_minutes + 1;
                if (inc_timer_hours)
                    timer_hours <= (timer_hours == 5'd23) ? 0 : timer_hours + 1;
                timer_done <= 0;
            end

            if (timer_mode && !set_alarm_mode) begin
                if (start_timer && !prev_start_timer) begin
                    timer_running <= 1;
                    timer_done <= 0;
                end
                if (stop_timer && !prev_stop_timer)
                    timer_running <= 0;
					 // Reset timer về 0
                if (reset_timer && !prev_reset_timer) begin
                    timer_hours <= 0;
                    timer_minutes <= 0;
                    timer_seconds <= 0;
                    timer_running <= 0;
                    timer_done <= 0;
                end
            end
				
            prev_start_timer <= start_timer;
            prev_stop_timer <= stop_timer;
            prev_reset_timer <= reset_timer;

				// Tăng giờ/phút/giây hiện tại
            if (set_time_mode && !set_alarm_mode) begin
                if (inc_minutes)
                    minutes <= (minutes == 6'd59) ? 0 : minutes + 1;
                if (inc_hours)
                    hours <= (hours == 5'd23) ? 0 : hours + 1;
                if (inc_seconds)
                    seconds <= (seconds == 6'd59) ? 0 : seconds + 1;
            end

            if (!set_time_mode && !set_alarm_mode) begin
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
            end

				// Tăng thời gian stopwatch nếu đang chạy
            if (stopwatch_mode && stopwatch_running && !set_alarm_mode) begin
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

            if (timer_mode && timer_running && !timer_done && !set_alarm_mode) begin
                if (timer_hours == 0 && timer_minutes == 0 && timer_seconds == 0) begin
                    timer_done <= 1;
                    timer_running <= 0;
                end else begin
                    if (timer_seconds == 0) begin
                        timer_seconds <= 6'd59;
                        if (timer_minutes == 0) begin
                            timer_minutes <= 6'd59;
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

				// Tăng giờ/phút báo thức khi ở chế độ set alarm
            if (set_alarm_mode) begin
                if (inc_alarm_hours)
                    alarm_hours <= (alarm_hours == 5'd23) ? 0 : alarm_hours + 1;
                if (inc_alarm_minutes)
                    alarm_minutes <= (alarm_minutes == 6'd59) ? 0 : alarm_minutes + 1;
                alarm_trigger <= 0;
            end

				// Kích hoạt đúng giờ báo thức
            if (!alarm_trigger && !set_alarm_mode) begin
                if (hours == alarm_hours && minutes == alarm_minutes && seconds == 0)
                    alarm_trigger <= 1;
            end

				// Tắt báo thức bằng nút bấm
            if (alarm_reset && !prev_alarm_reset)
                alarm_trigger <= 0;
            prev_alarm_reset <= alarm_reset;

				// Nếu đến đúng giờ báo thức thì bật cờ alarm_trigger
            is_stopwatch_running <= stopwatch_running;
            is_timer_running <= timer_running;

            debug_alarm_hours <= alarm_hours;
            debug_alarm_minutes <= alarm_minutes;
        end
    end
endmodule