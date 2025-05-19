module test_button(
    input CLOCK_50,
    input [3:0] KEY,
    output reg [3:0] led
);
    wire key1 = ~KEY[1];
    always @(posedge CLOCK_50) begin
        if (key1)
            led <= led + 1;
    end
endmodule
