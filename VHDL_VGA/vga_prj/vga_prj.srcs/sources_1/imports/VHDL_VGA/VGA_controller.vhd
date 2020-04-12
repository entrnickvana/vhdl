

entity VGA_controller is
    generic(
    	RES_WIDTH   	: in natural := 1920;
    	RES_HEIDTH  	: in natural := 1200;
    	S_CLK_FREQ  	: in real    := 100.0;
    	PIXEL_CLK_FREQ  : in real    := 193.16  	
    	EXT_CLK_MODE    : in boolean := "true"
    	);

	port(
		s_clk   		: in  std_logic;
		ext_clk     	: in  std_logic;
		disp_en 		: in  std_logic;
		n_sync      	: out std_logic;
		n_blank     	: out std_logic;
		h_sync      	: out std_logic;
		v_sync      	: out std_logic;
		pixel_clk_out 	: out std_logic;

		row     		: in  std_logic_vector(31 downto 0);
		col     		: in  std_logic_vector(31 downto 0)
      );
end entity VGA_controller;

architecture behav of VGA_controller is
	signal pixel_clk 		: std_logic;
	signal pixel_clk_out	: std_logic;

begin

	--Multiplex pixel_clk for higher resolutions
	if (EXT_CLK_MODE = "true") then
		pixel_clk_out <= ext_clk;
	else
		pixel_clk_out <= pixel_clk;
	end if;

	-- count = 
	pixel_clk_gen : process (s_clk) is
	  variable count_real_ns 		: real 		:= (S_CLK_FREQ/PIXEL_CLK_FREQ)*1.0e3;
	  variable count_integer_ns    	: integer   := integer(count_real_ns);
	  variable count_unsigned       : unsigned(natural(log2(ceil(real(count_integer_ns)))) downto 0)
	  begin
	  	if (rising_edge(s_clk)) then
		   	pixel_clk <= '0';	  	
	  		count_unsigned <= count_unsigned +1;	  				   	
	  		if(count_unsigned = integer(count_integer_ns)) then
	  			pixel_clk <= '1';
	  			count_unsigned <= (others => '0');
	  		end if;
		end if;
	end process pixel_clk_gen;



	frame_state : process (pixel_clk_out) is
	  variable h_length     : natural   := 1280;
	  variable v_length     : natural   := 1024;	  
	  variable h_f_porch 	: natural	:= 48;
	  variable h_b_porch 	: natural	:= 248;	  
	  variable h_sync_len 	: natural	:= 112;	  	  
	  variable h_sync_beg   : natural   := h_length + h_f_porch;  
	  variable h_sync_end   : natural   := h_length + h_f_porch + h_sync_len;  	  

	  variable v_f_porch 	: natural 	:= 1;
	  variable v_b_porch 	: natural 	:= 38;	  
	  variable v_sync_beg   : natural   := v_length + v_f_porch;  
	  variable v_sync_end   : natural   := v_length + v_f_porch + v_sync_len;  	  

	  variable v_sync_len 	: natural 	:= 3;	  	  
	  variable blank_state  : std_logic := '0';	  
	  variable h_total_len  : natural := h_length + h_f_porch + h_sync_len + h_b_porch;
	  variable v_total_len  : natural := v_length + v_f_porch + v_sync_len + v_b_porch;	  
	  variable h_bits       : natural := natural(log2(ceil(real(h_total_len))));
	  variable v_bits       : natural := natural(log2(ceil(real(v_total_len))));
	  variable h_count      : unsigned(h_bits downto 0);
	  variable v_count      : unsigned(v_bits downto 0);	  


	  begin
	  	if(rising_edge(pixel_clk_out)) then
	  		v_count <= v_count;
	  		h_count <= h_count + 1;

	  		if(h_count = h_total_len) then
	  			h_count <= (others => '0');
	  			v_count <= v_count + 1;

	  			if(v_count = v_total_len) then
	  				h_count <= (others => '0');
	  				v_count <= (others => '0');	  				
	  			end if;
	  		end if;

	  		h_sync  <= '1';
			if((h_count >= h_sync_beg) and (h_sync_end >= h_count)) then
				h_sync <= '0';
			end if;	  		

	  		v_sync  <= '1';	  		
			if((v_count >= v_sync_beg) and (v_sync_end >= v_count)) then
				v_sync <= '0';
			end if;	  		

			blank_state <= '0';
			if((h_count >= h_length) or (v_count >= v_length)) then
				blank_state <= '1';
			end if;

	  	end if;
	end process frame_state;

end architecture behav;



--************************************************ RESOLUTION SPECS *************************************************************
--Resolution (pixels)		Refresh Rate (Hz)		Pixel Clock (MHz)		Horizontal (pixel clocks)		Vertical (rows)						               	h_sync Polarity   v_sync Polarity
--																		Front 	Porch	Sync Pulse	Back Porch	Display	Front Porch	Sync Pulse	Back Porch
--640x350					70						25.175					640		16		96			48			350		37			2			60			p					n
--640x350					85						31.5					640		32		64			96			350		32			3			60			p					n
--640x400					70						25.175					640		16		96			48			400		12			2			35			n					p
--640x400					85						31.5					640		32		64			96			400		1			3			41			n					p
--640x480					60						25.175					640		16		96			48			480		10			2			33			n					n
--640x480					73						31.5					640		24		40			128			480		9			2			29			n					n
--640x480					75						31.5					640		16		64			120			480		1			3			16			n					n
--640x480					85						36						640		56		56			80			480		1			3			25			n					n
--640x480					100						43.16					640		40		64			104			480		1			3			25			n					p
--720x400					85						35.5					720		36		72			108			400		1			3			42			n					p
--768x576					60						34.96					768		24		80			104			576		1			3			17			n					p
--768x576					72						42.93					768		32		80			112			576		1			3			21			n					p
--768x576					75						45.51					768		40		80			120			576		1			3			22			n					p
--768x576					85						51.84					768		40		80			120			576		1			3			25			n					p
--768x576					100						62.57					768		48		80			128			576		1			3			31			n					p
--800x600					56						36						800		24		72			128			600		1			2			22			p					p
--800x600					60						40						800		40		128			88			600		1			4			23			p					p
--800x600					75						49.5					800		16		80			160			600		1			3			21			p					p
--800x600					72						50						800		56		120			64			600		37			6			23			p					p
--800x600					85						56.25					800		32		64			152			600		1			3			27			p					p
--800x600					100						68.18					800		48		88			136			600		1			3			32			n					p
--1024x768					43						44.9					1024	8		176			56			768		0			8			41			p					p
--1024x768					60						65						1024	24		136			160			768		3			6			29			n					n
--1024x768					70						75						1024	24		136			144			768		3			6			29			n					n
--1024x768					75						78.8					1024	16		96			176			768		1			3			28			p					p
--1024x768					85						94.5					1024	48		96			208			768		1			3			36			p					p
--1024x768					100						113.31					1024	72		112			184			768		1			3			42			n					p
--1152x864					75						108						1152	64		128			256			864		1			3			32			p					p
--1152x864					85						119.65					1152	72		128			200			864		1			3			39			n					p
--1152x864					100						143.47					1152	80		128			208			864		1			3			47			n					p
--1152x864					60						81.62					1152	64		120			184			864		1			3			27			n					p
--1280x1024					60						108						1280	48		112			248			1024	1			3			38			p					p
--1280x1024					75						135						1280	16		144			248			1024	1			3			38			p					p
--1280x1024					85						157.5					1280	64		160			224			1024	1			3			44			p					p
--1280x1024					100						190.96					1280	96		144			240			1024	1			3			57			n					p
--1280x800					60						83.46					1280	64		136			200			800		1			3			24			n					p
--1280x960					60						102.1					1280	80		136			216			960		1			3			30			n					p
--1280x960					72						124.54					1280	88		136			224			960		1			3			37			n					p
--1280x960					75						129.86					1280	88		136			224			960		1			3			38			n					p
--1280x960					85						148.5					1280	64		160			224			960		1			3			47			p					p
--1280x960					100						178.99					1280	96		144			240			960		1			3			53			n					p
--1368x768					60						85.86					1368	72		144			216			768		1			3			23			n					p
--1400x1050					60						122.61					1400	88		152			240			1050	1			3			33			n					p
--1400x1050					72						149.34					1400	96		152			248			1050	1			3			40			n					p
--1400x1050					75						155.85					1400	96		152			248			1050	1			3			42			n					p
--1400x1050					85						179.26					1400	104		152			256			1050	1			3			49			n					p
--1400x1050					100						214.39					1400	112		152			264			1050	1			3			58			n					p
--1440x900					60						106.47					1440	80		152			232			900		1			3			28			n					p
--1600x1200					60						162						1600	64		192			304			1200	1			3			46			p					p
--1600x1200					65						175.5					1600	64		192			304			1200	1			3			46			p					p
--1600x1200					70						189						1600	64		192			304			1200	1			3			46			p					p
--1600x1200					75						202.5					1600	64		192			304			1200	1			3			46			p					p
--1600x1200					85						229.5					1600	64		192			304			1200	1			3			46			p					p
--1600x1200					100						280.64					1600	128		176			304			1200	1			3			67			n					p
--1680x1050					60						147.14					1680	104		184			288			1050	1			3			33			n					p
--1792x1344					60						204.8					1792	128		200			328			1344	1			3			46			n					p
--1792x1344					75						261						1792	96		216			352			1344	1			3			69			n					p
--1856x1392					60						218.3					1856	96		224			352			1392	1			3			43			n					p
--1856x1392					75						288						1856	128		224			352			1392	1			3			104			n					p
--1920x1200					60						193.16					1920	128		208			336			1200	1			3			38			n					p
--1920x1440					60						234						1920	128		208			344			1440	1			3			56			n					p
--1920x1440					75						297						1920	144		224			352			1440	1			3			56			n					p	