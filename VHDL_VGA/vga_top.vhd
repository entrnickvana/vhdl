library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use IEEE.numeric_bit.all;
use ieee.std_logic_arith.ALL;
use IEEE.std_logic_signed.all;
use ieee.math_real.all;
library std;
use ieee.std_logic_textio.all;
use std.textio.all;

entity vga_top is
  port( ref_clk_100M : in std_logic);
end entity vga_top;

architecture struct of vga_top is

--module clk_wiz_0_clk_wiz 
--
-- (// Clock in ports
--  // Clock out ports
--  output        clk_out1,
--  output        clk_out2,
--  // Status and control signals
--  input         reset,
--  output        locked,
--  input         clk_in1
--  );
--
--
--
component VGA_controller
    generic(
    	RES_WIDTH   	: in natural := 1920; 
    	RES_HEIDTH  	: in natural := 1200; 
    	S_CLK_FREQ  	: in real    := 100.0;
    	PIXEL_CLK_FREQ  : in real    := 193.16  	
    	EXT_CLK_MODE    : in boolean := "true"
    	);

    port(
	s_clk           : in  std_logic;
	ext_clk     	: in  std_logic;
	disp_en 	: in  std_logic;
	n_sync      	: out std_logic;
	n_blank     	: out std_logic;
	h_sync      	: out std_logic;
	v_sync      	: out std_logic;
	pixel_clk_out 	: out std_logic;
	row     	: in  std_logic_vector(31 downto 0);
	col     	: in  std_logic_vector(31 downto 0)
      );
end component;
  
begin

  vga1 : work.VGA_controller(behav)
    generic(
    	RES_WIDTH   	=> 1920; ,
    	RES_HEIDTH  	=> 1200; ,
    	S_CLK_FREQ  	=> 100.0;,
    	PIXEL_CLK_FREQ  => 193.16,  	
    	EXT_CLK_MODE    => "true"
    	);              
    port map(
	s_clk         => ,       
	ext_clk       => ,  
	disp_en       => ,  
	n_sync        => ,  
	n_blank       => ,  
	h_sync        => ,  
	v_sync        => ,  
	pixel_clk_out => ,	
	row           => ,  
	col           =>
	);
      
  
end architecture struct;
