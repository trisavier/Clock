library verilog;
use verilog.vl_types.all;
entity clock is
    port(
        clk_1Hz         : in     vl_logic;
        reset           : in     vl_logic;
        seconds         : out    vl_logic_vector(5 downto 0);
        carry           : out    vl_logic
    );
end clock;
