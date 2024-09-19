library verilog;
use verilog.vl_types.all;
entity simpleton_pitanga_vlg_check_tst is
    port(
        OutAC           : in     vl_logic_vector(7 downto 0);
        OutPC           : in     vl_logic_vector(7 downto 0);
        OutREM          : in     vl_logic_vector(7 downto 0);
        oEA             : in     vl_logic_vector(2 downto 0);
        oEndMem_7s      : in     vl_logic_vector(6 downto 0);
        oEndMem_MS      : in     vl_logic;
        oMem128_7s      : in     vl_logic_vector(6 downto 0);
        resultado       : in     vl_logic_vector(7 downto 0);
        sampler_rx      : in     vl_logic
    );
end simpleton_pitanga_vlg_check_tst;
