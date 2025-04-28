module clock(
    input wire clk_1Hz,
    input wire reset,
    input wire set_time_mode, // << tín hiệu chế độ chỉnh giờ mới
    input wire [5:0] set_minutes, // << giá trị phút cần set
    input wire [4:0] set_hours,   // << giá trị giờ cần set
    output reg [5:0] seconds,
    output reg [5:0] minutes,
    output reg [4:0] hours,
    output reg carry
);


reg sec_carry;
reg min_carry;

always @(posedge clk_1Hz or posedge reset) begin
    if (reset) begin
        seconds <= 0;
        minutes <= 0;
        hours <= 0;
        carry <= 0;
    end else if (set_time_mode) begin
        // Chế độ chỉnh giờ: set thẳng
        minutes <= set_minutes;
        hours <= set_hours;
        seconds <= 0; // reset giây luôn cho đẹp
        carry <= 0;
    end else begin
        // Chế độ đếm giờ bình thường
        if (seconds == 6'd59) begin
            seconds <= 0;
            carry <= 1;

            if (minutes == 6'd59) begin
                minutes <= 0;
                if (hours == 5'd23) begin
                    hours <= 0;
                end else begin
                    hours <= hours + 1;
                end
            end else begin
                minutes <= minutes + 1;
            end

        end else begin
            seconds <= seconds + 1;
            carry <= 0;
        end
    end
end


endmodule
