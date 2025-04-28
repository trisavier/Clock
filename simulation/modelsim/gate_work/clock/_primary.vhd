library verilog;
use verilog.vl_types.all;
entity clock is
    port(
        clk_1Hz         : in     vl_logic;
        reset           : in     vl_logic;
        seconds         : out    vl_logic_vector(5 downto 0);
        minutes         : out    vl_logic_vector(5 downto 0);
        hours           : out    vl_logic_vector(4 downto 0)
    );
end clock;
