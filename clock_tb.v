`timescale 1ms/1ms

module clock_tb;

// Khai báo tín hiệu kết nối tới DUT (Device Under Test)
reg clk_1Hz;
reg reset;
reg set_time_mode;
reg [5:0] set_minutes;
reg [4:0] set_hours;
wire [5:0] seconds;
wire [5:0] minutes;
wire [4:0] hours;
wire carry;

// Gọi module clock
clock uut (
    .clk_1Hz(clk_1Hz),
    .reset(reset),
    .set_time_mode(set_time_mode),
    .set_minutes(set_minutes),
    .set_hours(set_hours),
    .seconds(seconds),
    .minutes(minutes),
    .hours(hours),
    .carry(carry)
);

// Tạo xung clock 1Hz (ở đây 1ms = 1Hz để mô phỏng nhanh)
initial begin
    clk_1Hz = 0;
    forever #500 clk_1Hz = ~clk_1Hz; // mỗi 500ms đổi trạng thái -> 1Hz
end

// Test logic
initial begin
    // Bắt đầu reset
    reset = 1;
    set_time_mode = 0;
    set_minutes = 0;
    set_hours = 0;
    #1000; // Đợi 1s
    reset = 0;

    // Đồng hồ chạy bình thường 5s
    #5000; 

    // Bây giờ bật chế độ chỉnh giờ
    set_time_mode = 1;
    set_minutes = 45;
    set_hours = 12;
    #1000; // giữ 1s

    set_time_mode = 0; // Tắt chỉnh giờ, đồng hồ tiếp tục chạy bình thường

    // Để đồng hồ chạy tiếp 20s
    #100000;

    // Kết thúc mô phỏng
    $stop;
end

endmodule
