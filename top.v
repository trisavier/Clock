module top(
    input CLOCK_50,                     // Clock hệ thống 50MHz
    input [17:0] SW,                    // Các công tắc gạt (SW[0–5] dùng để chọn chế độ)
    input [3:0] KEY,                    // Các nút nhấn KEY[0–3]
    output [6:0] HEX0, HEX1, HEX2,      // 6 LED 7 đoạn để hiển thị giờ:phút:giây
                   HEX3, HEX4, HEX5,
    output [17:0] LEDR                 // Đèn LED hiển thị trạng thái debug và báo thức
);

	// Chống dội phím để tránh reset bị nhiễu
	reg [19:0] debounce_counter;
	reg debounced_reset;

	always @(posedge CLOCK_50) begin
		 if (~KEY[0]) begin
			  debounce_counter <= 0;
			  debounced_reset <= 1; // Khi nhấn KEY[0], reset active
		 end else begin
			  if (debounce_counter < 500_000) begin // Delay 10ms tại 50MHz
					debounce_counter <= debounce_counter + 1;
					debounced_reset <= 1;
			  end else begin
					debounced_reset <= 0;
			  end
		 end
	end

	wire reset = debounced_reset;

	// Clock divider chia từ 50MHz xuống 1Hz
	reg [25:0] counter;
	reg clk_1Hz;

	always @(posedge CLOCK_50 or posedge reset) begin
		 if (reset) begin
			  counter <= 0;
			  clk_1Hz <= 0;
		 end else if (counter == 25_000_000) begin
			  counter <= 0;
			  clk_1Hz <= ~clk_1Hz; // Đảo xung mỗi 0.5s => tần số 1Hz
		 end else begin
			  counter <= counter + 1;
		 end
	end

	// Các tín hiệu giờ, phút, giây cho các chế độ
	wire [5:0] seconds, minutes, stopwatch_seconds, stopwatch_minutes, timer_seconds, timer_minutes;
	wire [4:0] hours, stopwatch_hours, timer_hours;
	wire [5:0] alarm_minutes;
	wire [4:0] alarm_hours;
	wire alarm_trigger;

	// Debug: xuất giá trị giờ/phút báo thức ra LED
	wire [4:0] debug_alarm_hours;
	wire [5:0] debug_alarm_minutes;

	// Chế độ hoạt động tùy theo các công tắc SW
	wire stopwatch_mode = SW[1];
	wire timer_mode = SW[2] && !SW[3];
	wire set_timer_mode = SW[3];
	wire set_time_mode = SW[0];
	wire alarm_display_mode = SW[4];
	wire set_alarm_mode = SW[5];
	wire timer_display_mode = timer_mode || set_timer_mode;

	// Biến nút nhấn thành tín hiệu logic
	wire key1_pressed = ~KEY[1];
	wire key2_pressed = ~KEY[2];
	wire key3_pressed = ~KEY[3];

	clock clock_inst(
		 // Clock và reset
		 .clk_1Hz(clk_1Hz),
		 .reset(reset),

		 // Set thời gian đồng hồ
		 .set_time_mode(set_time_mode),
		 .inc_minutes(key1_pressed && set_time_mode),
		 .inc_hours(key2_pressed && set_time_mode),
		 .inc_seconds(key3_pressed && set_time_mode),

		 // Stopwatch (bấm giờ)
		 .stopwatch_mode(stopwatch_mode),
		 .start_stopwatch(stopwatch_mode && key3_pressed),
		 .stop_stopwatch(stopwatch_mode && key2_pressed),
		 .reset_stopwatch(stopwatch_mode && key1_pressed),

		 // Timer (đếm ngược)
		 .timer_mode(timer_mode),
		 .set_timer_mode(set_timer_mode),
		 .inc_timer_hours(set_timer_mode && key2_pressed),
		 .inc_timer_minutes(set_timer_mode && key1_pressed),
		 .inc_timer_seconds(set_timer_mode && key3_pressed),
		 .start_timer(timer_mode && key3_pressed),
		 .stop_timer(timer_mode && key2_pressed),
		 .reset_timer(timer_mode && key1_pressed),

		 // Alarm (báo thức)
		 .set_alarm_mode(set_alarm_mode),
		 .inc_alarm_hours(set_alarm_mode && key2_pressed),
		 .inc_alarm_minutes(set_alarm_mode && key1_pressed),
		 .alarm_reset(key3_pressed),

		 // Output các giá trị thời gian
		 .seconds(seconds), .minutes(minutes), .hours(hours),
		 .stopwatch_seconds(stopwatch_seconds), .stopwatch_minutes(stopwatch_minutes), .stopwatch_hours(stopwatch_hours),
		 .timer_seconds(timer_seconds), .timer_minutes(timer_minutes), .timer_hours(timer_hours),

		 // Trạng thái
		 .is_stopwatch_running(), .is_timer_running(), .timer_done(),
		 .alarm_trigger(alarm_trigger),
		 .debug_alarm_hours(debug_alarm_hours),
		 .debug_alarm_minutes(debug_alarm_minutes),
		 .alarm_hours(alarm_hours),
		 .alarm_minutes(alarm_minutes)
	);

	// Chọn giá trị giờ/phút/giây để hiển thị tùy theo chế độ
	wire [5:0] display_sec = (alarm_display_mode || set_alarm_mode) ? 6'd0 :
									 stopwatch_mode ? stopwatch_seconds :
									 timer_display_mode ? timer_seconds : seconds;

	wire [5:0] display_min = (alarm_display_mode || set_alarm_mode) ? alarm_minutes :
									 stopwatch_mode ? stopwatch_minutes :
									 timer_display_mode ? timer_minutes : minutes;

	wire [4:0] display_hr  = (alarm_display_mode || set_alarm_mode) ? alarm_hours :
									 stopwatch_mode ? stopwatch_hours :
									 timer_display_mode ? timer_hours : hours;

	// Chia ra hàng đơn vị và hàng chục cho giờ:phút:giây
	wire [3:0] sec_ones = display_sec % 10;
	wire [3:0] sec_tens = display_sec / 10;
	wire [3:0] min_ones = display_min % 10;
	wire [3:0] min_tens = display_min / 10;
	wire [3:0] hr_ones  = display_hr % 10;
	wire [3:0] hr_tens  = display_hr / 10;

	// Mỗi case giải mã số từ 0–9 sang mã LED 7 đoạn
	// Đặt vào các thanh ghi hex0_out → hex5_out tương ứng HEX0 → HEX5
    reg [6:0] hex0_out, hex1_out, hex2_out, hex3_out, hex4_out, hex5_out;
    always @(*) begin
        case (sec_ones)
            4'd0: hex0_out = 7'b1000000;
            4'd1: hex0_out = 7'b1111001;
            4'd2: hex0_out = 7'b0100100;
            4'd3: hex0_out = 7'b0110000;
            4'd4: hex0_out = 7'b0011001;
            4'd5: hex0_out = 7'b0010010;
            4'd6: hex0_out = 7'b0000010;
            4'd7: hex0_out = 7'b1111000;
            4'd8: hex0_out = 7'b0000000;
            4'd9: hex0_out = 7'b0010000;
            default: hex0_out = 7'b1111111;
        endcase
        case (sec_tens)
            4'd0: hex1_out = 7'b1000000;
            4'd1: hex1_out = 7'b1111001;
            4'd2: hex1_out = 7'b0100100;
            4'd3: hex1_out = 7'b0110000;
            4'd4: hex1_out = 7'b0011001;
            4'd5: hex1_out = 7'b0010010;
            4'd6: hex1_out = 7'b0000010;
            4'd7: hex1_out = 7'b1111000;
            4'd8: hex1_out = 7'b0000000;
            4'd9: hex1_out = 7'b0010000;
            default: hex1_out = 7'b1111111;
        endcase
        case (min_ones)
            4'd0: hex2_out = 7'b1000000;
            4'd1: hex2_out = 7'b1111001;
            4'd2: hex2_out = 7'b0100100;
            4'd3: hex2_out = 7'b0110000;
            4'd4: hex2_out = 7'b0011001;
            4'd5: hex2_out = 7'b0010010;
            4'd6: hex2_out = 7'b0000010;
            4'd7: hex2_out = 7'b1111000;
            4'd8: hex2_out = 7'b0000000;
            4'd9: hex2_out = 7'b0010000;
            default: hex2_out = 7'b1111111;
        endcase
        case (min_tens)
            4'd0: hex3_out = 7'b1000000;
            4'd1: hex3_out = 7'b1111001;
            4'd2: hex3_out = 7'b0100100;
            4'd3: hex3_out = 7'b0110000;
            4'd4: hex3_out = 7'b0011001;
            4'd5: hex3_out = 7'b0010010;
            4'd6: hex3_out = 7'b0000010;
            4'd7: hex3_out = 7'b1111000;
            4'd8: hex3_out = 7'b0000000;
            4'd9: hex3_out = 7'b0010000;
            default: hex3_out = 7'b1111111;
        endcase
        case (hr_ones)
            4'd0: hex4_out = 7'b1000000;
            4'd1: hex4_out = 7'b1111001;
            4'd2: hex4_out = 7'b0100100;
            4'd3: hex4_out = 7'b0110000;
            4'd4: hex4_out = 7'b0011001;
            4'd5: hex4_out = 7'b0010010;
            4'd6: hex4_out = 7'b0000010;
            4'd7: hex4_out = 7'b1111000;
            4'd8: hex4_out = 7'b0000000;
            4'd9: hex4_out = 7'b0010000;
            default: hex4_out = 7'b1111111;
        endcase
        case (hr_tens)
            4'd0: hex5_out = 7'b1000000;
            4'd1: hex5_out = 7'b1111001;
            4'd2: hex5_out = 7'b0100100;
            4'd3: hex5_out = 7'b0110000;
            4'd4: hex5_out = 7'b0011001;
            4'd5: hex5_out = 7'b0010010;
            4'd6: hex5_out = 7'b0000010;
            4'd7: hex5_out = 7'b1111000;
            4'd8: hex5_out = 7'b0000000;
            4'd9: hex5_out = 7'b0010000;
            default: hex5_out = 7'b1111111;
        endcase
    end

	assign HEX0 = hex0_out; // Giây hàng đơn vị
	assign HEX1 = hex1_out; // Giây hàng chục
	assign HEX2 = hex2_out; // Phút hàng đơn vị
	assign HEX3 = hex3_out; // Phút hàng chục
	assign HEX4 = hex4_out; // Giờ hàng đơn vị
	assign HEX5 = hex5_out; // Giờ hàng chục

	assign LEDR[4] = SW[4]; // LED báo bật chế độ báo thức
	assign LEDR[5] = SW[5]; // LED báo bật chế độ set báo thức
	assign LEDR[1] = ~KEY[1]; // Báo nút nhấn
	assign LEDR[2] = ~KEY[2];
	assign LEDR[3] = ~KEY[3];
	assign LEDR[0] = alarm_trigger; // Báo thức đang kêu
	assign LEDR[10:6] = debug_alarm_hours; // Hiển thị debug giờ báo thức
	assign LEDR[16:11] = debug_alarm_minutes; // Hiển thị debug phút báo thức
	assign LEDR[17] = clk_1Hz; // Clock debug 1Hz

endmodule