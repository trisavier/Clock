library verilog;
use verilog.vl_types.all;
entity clock is
    port(
        clk_1Hz         : in     vl_logic;
        reset           : in     vl_logic;
        set_time_mode   : in     vl_logic;
        inc_minutes     : in     vl_logic;
        inc_hours       : in     vl_logic;
        stopwatch_mode  : in     vl_logic;
        start_stopwatch : in     vl_logic;
        stop_stopwatch  : in     vl_logic;
        reset_stopwatch : in     vl_logic;
        timer_mode      : in     vl_logic;
        set_timer_mode  : in     vl_logic;
        set_timer_hours : in     vl_logic_vector(4 downto 0);
        set_timer_minutes: in     vl_logic_vector(5 downto 0);
        set_timer_seconds: in     vl_logic_vector(5 downto 0);
        start_timer     : in     vl_logic;
        stop_timer      : in     vl_logic;
        reset_timer     : in     vl_logic;
        seconds         : out    vl_logic_vector(5 downto 0);
        minutes         : out    vl_logic_vector(5 downto 0);
        hours           : out    vl_logic_vector(4 downto 0);
        stopwatch_seconds: out    vl_logic_vector(5 downto 0);
        stopwatch_minutes: out    vl_logic_vector(5 downto 0);
        stopwatch_hours : out    vl_logic_vector(4 downto 0);
        timer_seconds   : out    vl_logic_vector(5 downto 0);
        timer_minutes   : out    vl_logic_vector(5 downto 0);
        timer_hours     : out    vl_logic_vector(4 downto 0);
        is_stopwatch_running: out    vl_logic;
        is_timer_running: out    vl_logic;
        timer_done      : out    vl_logic;
        carry           : out    vl_logic
    );
end clock;
