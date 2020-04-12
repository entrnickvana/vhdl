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

entity vga_top is
  port(
    s_clk           : in std_logic;
    VGA_R           : out std_logic_vector(3 downto 0);
    VGA_G           : out std_logic_vector(3 downto 0);
    VGA_B           : out std_logic_vector(3 downto 0);
    VGA_HS          : out std_logic;
    VGA_VS          : out std_logic;
    LED             : out std_logic_vector(1 downto 0)
    );
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

--module testoverlay_0(
--  input wire                 rst_n,
--  input wire                 clk,
--  
--  output reg[23:0]      RGBOut,
--  output reg                HSync1,
--  output reg                VSync1
--);
--
-- 
--
--VHDL:
--
------

  signal mmcm_locked1       : std_logic;
  signal pxl_clk_108M       : std_logic;
  signal n_sync_sig         : std_logic;
  signal n_blank_sig        : std_logic;
  signal h_sync_sig         : std_logic;
  signal v_sync_sig         : std_logic;
  signal pixel_clk_out_sig  : std_logic;
  signal row_sig            : std_logic_vector(31 downto 0);
  signal col_sig            : std_logic_vector(31 downto 0);
  signal clk_1_sig          : std_logic;  
  signal clk_2_sig          : std_logic;
  signal dummy_reset        : std_logic;
  

  

component clk_wiz_0
    port(
      clk_out1 : out std_logic;
      clk_out2 : out std_logic; 
      reset    : in std_logic;
      locked   : out std_logic;
      clk_in1  : in std_logic
      );
end component;
  
component VGA_controller
    generic(
    	RES_WIDTH   	: in natural := 1920; 
    	RES_HEIDTH  	: in natural := 1200; 
    	S_CLK_FREQ  	: in real    := 100.0;
    	PIXEL_CLK_FREQ  : in real    := 108.0;  	
    	EXT_CLK_MODE    : in boolean := true
    	);

    port(
	  s_clk                 : in  std_logic;
	  ext_clk     	        : in  std_logic;
	  disp_en 	        : in  std_logic;
	  n_sync      	        : out std_logic;
	  n_blank     	        : out std_logic;
	  h_sync      	        : out std_logic;
	  v_sync      	        : out std_logic;
	  pixel_clk_out 	: out std_logic;
	  row     	        : in  std_logic_vector(31 downto 0);
	  col     	        : in  std_logic_vector(31 downto 0)
      );
end component;

--component image_buffer
--    generic(
--      RES_WIDTH   : in natural := 1280;
--      RES_HEIDTH  : in natural := 1024    	
--    	);
--    port(
--       disp_en     : in  std_logic;
--       row         : in  std_logic_vector(31 downto 0);
--       col         : in  std_logic_vector(31 downto 0);
--       red         : out std_logic_vector(7 downto 0);		
--       green       : out std_logic_vector(7 downto 0);		
--       blue  	    : out std_logic_vector(7 downto 0)
--      );

begin

  dummy_reset <= '0';
  VGA_HS <= h_sync_sig;
  VGA_VS <= v_sync_sig;  

clk_wiz_inst :  component clk_wiz_0
    port map (
      clk_out1 => clk_1_sig,
      clk_out2 => pxl_clk_108M,
      --control_signals => ,
      reset => '0',         
      locked => mmcm_locked1,        
      clk_in1 => s_clk
      );
  
  vga1 : entity work.VGA_controller
    generic map(
      RES_WIDTH   	=> 1280,
      RES_HEIDTH  	=> 1024,
      S_CLK_FREQ  	=> 100.0,
      PIXEL_CLK_FREQ    => 108.0,  	
      EXT_CLK_MODE      => true)             
    port map(
      s_clk         => pxl_clk_108M,       
      ext_clk       => pxl_clk_108M,  
      disp_en       => '1',  
      n_sync        => n_sync_sig,  
      n_blank       => n_blank_sig,  
      h_sync        => h_sync_sig,  
      v_sync        => v_sync_sig,  
      pixel_clk_out => pixel_clk_out_sig,	
      row           => row_sig,  
      col           => col_sig);

    buf1 : entity work.image_buffer(behav)
    generic map(
      RES_WIDTH  => 1280,
      RES_HEIDTH => 1024)
    port map(
      disp_en => '1',
      row     => row_sig,
      col     => col_sig,
      red     => VGA_R,      
      green   => VGA_G,       	
      blue    => VGA_B);
  
  led0_cntr : entity work.led_counter(behav)
    generic map(
      INPUT_CLK_FREQ_M => 100.0e6,
      DESIRED_LED_PER_us => 1.0e6
      )
    port map(
      input_clk => s_clk,
      rst => '0',
      out_pulse => LED(0)
      );
  
  led1_cntr : entity work.led_counter(behav)
    generic map(
      INPUT_CLK_FREQ_M => 108.0e6,
      DESIRED_LED_PER_us => 1.0e6
      )
    port map(
      input_clk => pxl_clk_108M,
      rst => dummy_reset,
      out_pulse => LED(1)
      );
      
  
end architecture struct;
