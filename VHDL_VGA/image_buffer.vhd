

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


entity image_buffer is
    generic(
    	RES_WIDTH   : in natural := 1280;
    	RES_HEIDTH  : in natural := 1024    	
    	);
    port(
        disp_en 	: in  std_logic;
        row     	: in  std_logic_vector(31 downto 0);
        col     	: in  std_logic_vector(31 downto 0);
        red     	: out std_logic_vector(7 downto 0);		
        green   	: out std_logic_vector(7 downto 0);		
        blue  		: out std_logic_vector(7 downto 0)
      );
end entity image_buffer;

architecture behav of image_buffer is
  
  type pixel is array (7 downto 0, 7 downto 0, 7 downto 0) of std_logic;
  type frame is array (RES_WIDTH-1 downto 0, RES_HEIDTH-1 downto 0) of pixel;
  
  begin

  red <= (others => '1');
  green <= (others => '1');
  blue <= (others => '1');  


end architecture behav;
