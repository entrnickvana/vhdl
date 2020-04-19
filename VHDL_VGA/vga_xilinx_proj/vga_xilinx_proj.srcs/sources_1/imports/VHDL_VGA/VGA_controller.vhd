library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
--USE ieee.numeric_std.ALL;
--use IEEE.numeric_bit.all;
use ieee.std_logic_arith.ALL;
--use IEEE.std_logic_signed.all;
use ieee.math_real.all;
library std;
use ieee.std_logic_textio.all;
use std.textio.all;

--Resolution (pixels)	Refresh Rate (Hz)	Pixel Clock (MHz)	Horizontal (pixel clocks)				Vertical (rows)				h_sync Polarity	v_sync Polarity
--                                                                      Display	Front Porch	Sync Pulse	Back Porch	Display	Front Porch	Sync Pulse	Back Porch		
--1280x1024	        60	                108	                1280	48	        112	        248	        1024	1	        3	        38	           p	p


entity VGA_controller is
    generic(
    	RES_WIDTH   	: in natural := 1280;
    	RES_HEIDTH  	: in natural := 1024;
        H_POL           : in std_logic := '1';
        V_POL           : in std_logic := '1';        
    	S_CLK_FREQ  	: in real    := 100.0;
    	PIXEL_CLK_FREQ  : in real    := 108.0;
    	EXT_CLK_MODE    : in boolean := TRUE
    	);

	port(
		s_clk   	: in  std_logic;
		ext_clk     	: in  std_logic;
		disp_en 	: out  std_logic;
		n_sync      	: out std_logic;
		n_blank     	: out std_logic;
		h_sync      	: out std_logic;
		v_sync      	: out std_logic;
		row     	: out  std_logic_vector(31 downto 0);
		col     	: out  std_logic_vector(31 downto 0)
      );
end entity VGA_controller;

architecture behav of VGA_controller is
	signal pixel_clk : std_logic;

begin

  n_sync <= '0';
  n_blank <= '0';
  
  
	--Multiplex pixel_clk for higher resolutions
	gen_clk_sel_ext: if EXT_CLK_MODE = true GENERATE
		pixel_clk <= ext_clk;
	end generate gen_clk_sel_ext;
	
	gen_clk_sel_int: if EXT_CLK_MODE = false GENERATE
		pixel_clk <= s_clk;
	end GENERATE gen_clk_sel_int;

	frame_state : process (pixel_clk) is
	  variable h_length     : natural   := 1280;
	  variable h_f_porch 	: natural   := 48;
	  variable h_b_porch 	: natural   := 248;	  
	  variable h_sync_len 	: natural   := 112;	  	  
	  variable h_sync_beg   : natural   := h_length + h_f_porch;  
	  variable h_sync_end   : natural   := h_length + h_f_porch + h_sync_len;
          
	  variable v_length     : natural   := 1024;	  
	  variable v_f_porch 	: natural   := 1;
	  variable v_b_porch 	: natural   := 38;	  
	  variable v_sync_len   : natural   := 3;
	  variable v_sync_beg   : natural   := v_length + v_f_porch;  
	  variable v_sync_end   : natural   := v_length + v_f_porch + v_sync_len;  	  
	  
	  variable blank_state  : std_logic := '0';
          --                                  1280    +    48     +     112 + 248=1688
	  variable h_total_len  : natural := h_length + h_f_porch + h_sync_len + h_b_porch;
          --                                  1024    + 1         +3+38=1066
	  variable v_total_len  : natural := v_length + v_f_porch + v_sync_len + v_b_porch;	  
	  --variable h_bits       : natural := natural(log2(ceil(real(h_total_len))));
	  variable h_bits       : natural := 32;
	  --variable v_bits       : natural := natural(log2(ceil(real(v_total_len))));
	  variable v_bits       : natural := 32;
	  variable h_count      : unsigned(h_bits-1 downto 0);
	  variable v_count      : unsigned(v_bits-1 downto 0);	  
	  begin
            if(rising_edge(pixel_clk)) then



              -- horizontal counter
              if(h_count = (h_total_len-1)) then
                h_count := (others => '0');
              else
                h_count := h_count + 1;
              end if;

              if(h_count = (h_total_len-1)) and (v_count = (v_total_len-1)) then
                v_count := (others => '0');
              elsif (h_count = (h_total_len-1)) then
                v_count := v_count + 1;
              end if;

              if(h_count >= (h_f_porch + h_f_porch-1)) and (h_count < (h_f_porch + h_f_porch + h_sync_len-1)) then
                h_sync <= H_POL;
              else
                h_sync <= not(H_POL);
              end if;

              if(v_count >= (v_f_porch + v_length-1)) and (v_count < (v_f_porch + v_length + v_sync_len-1)) then
                v_sync <= V_POL;
              else
                v_sync <= not(V_POL);
              end if;

              if( h_count < h_length) and (v_count < v_length) then
                disp_en <= '1';
              else
                disp_en <= '0';
              end if;
                
              --disp_en <= '1' when h_count < h_length and v_count < v_length else '0';

              row <= std_logic_vector(v_count);
              col <= std_logic_vector(h_count);
              
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
