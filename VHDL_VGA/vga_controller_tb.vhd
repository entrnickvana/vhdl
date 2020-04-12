
entity VGA_controller_tb is
--port();
end entity VGA_controller_tb;	

--    generic(
--    	RES_WIDTH   	: in natural := 1920;
--    	RES_HEIDTH  	: in natural := 1200;
--    	S_CLK_FREQ  	: in real    := 100.0;
--    	PIXEL_CLK_FREQ  : in real    := 193.16  	
--    	EXT_CLK_MODE    : in boolean := "true"
--    	);
--
--	port(
--		s_clk   		: in  std_logic;
--		ext_clk     	: in  std_logic;
--		disp_en 		: in  std_logic;
--		n_sync      	: out std_logic;
--		n_blank     	: out std_logic;
--		h_sync      	: out std_logic;
--		v_sync      	: out std_logic;
--		pixel_clk_out 	: out std_logic;
--
--		row     		: in  std_logic_vector(31 downto 0);
--		col     		: in  std_logic_vector(31 downto 0)
--      );

architecture behav of VGA_controller_tb is

component

begin

  clk_gen_p : process(s_clk)

end architecture behav;