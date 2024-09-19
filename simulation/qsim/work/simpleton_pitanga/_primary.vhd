library verilog;
use verilog.vl_types.all;
entity simpleton_pitanga is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        oEndMem_7s      : out    vl_logic_vector(6 downto 0);
        oEndMem_MS      : out    vl_logic;
        oMem128_7s      : out    vl_logic_vector(6 downto 0);
        OutAC           : out    vl_logic_vector(7 downto 0);
        OutPC           : out    vl_logic_vector(7 downto 0);
        OutREM          : out    vl_logic_vector(7 downto 0);
        resultado       : out    vl_logic_vector(7 downto 0);
        oEA             : out    vl_logic_vector(2 downto 0)
    );
end simpleton_pitanga;
