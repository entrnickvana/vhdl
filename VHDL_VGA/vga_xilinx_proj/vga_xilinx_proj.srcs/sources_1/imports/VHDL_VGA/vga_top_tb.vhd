--library IEEE;
--use IEEE.std_logic_1164.ALL;
--ENTITY myadder_tb is
--END myadder_tb;
--ARCHITECTURE simulate OF myadder_tb IS
------------------------------------------------------
----- The parent design, myadder8_top, is instantiated
----- in this testbench. Note the component
----- declaration and the instantiation.
------------------------------------------------------
--COMPONENT myadder8_top
--PORT (
--    AP :  IN std_logic_vector(7 downto 0);
--    BP : IN std_logic_vector(7 downto 0);
--    CLKP: IN std_logic ;
--    C_INP: IN std_logic;
--    QP: OUT std_logic_VECTOR (8 downto 0));
--END COMPONENT;
--SIGNAL a_data_input : std_logic_vector(7 DOWNTO 0);
--SIGNAL b_data_input  : std_logic_vector(7 DOWNTO 0);
--SIGNAL clock            : std_logic;
--SIGNAL carry_in : std_logic;
--SIGNAL sum : std_logic_vector (8 DOWNTO 0);
--BEGIN
--uut: myadder8_top 
--PORT MAP ( 
--    AP => a_data_input,
--    BP => b_data_input,
--    CLKP => clock,
--    C_INP=> carry_in,
--    QP => Q);
--stimulus: PROCESS 
--  BEGIN
-------------------------------------------------------
-----Provide stimulus in this section. (not shown here) 
-------------------------------------------------------
--   wait;
--   end process; -- stimulus
--END simulate;
--
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use IEEE.math_real.all;
library std;
use IEEE.std_logic_textio.all;
use std.textio.all;

entity vga_top_tb is
  --port();
end vga_top_tb;

architecture simulate of vga_top_tb is
  
  component vga_top
    port(
      s_clk           : in std_logic;
      VGA_R           : out std_logic_vector(3 downto 0);
      VGA_G           : out std_logic_vector(3 downto 0);
      VGA_B           : out std_logic_vector(3 downto 0);
      VGA_HS          : out std_logic;
      VGA_VS          : out std_logic;
      LED             : out std_logic_vector(1 downto 0)
    );
  end component vga_top;

  

  signal s_clk_stim  : std_logic;
  signal VGA_R_stim  : std_logic_vector(3 downto 0);
  signal VGA_G_stim  : std_logic_vector(3 downto 0);
  signal VGA_B_stim  : std_logic_vector(3 downto 0);
  signal VGA_HS_stim : std_logic;
  signal VGA_VS_stim : std_logic;
  signal LED_stim    : std_logic_vector(1 downto 0);
  constant Tpw_clk   : time := 12.5 ns;

begin

  uut: vga_top
    port map(
      s_clk => s_clk_stim, 
      VGA_R => VGA_R_stim, 
      VGA_G => VGA_G_stim, 
      VGA_B => VGA_B_stim, 
      VGA_HS => VGA_HS_stim,
      VGA_VS => VGA_VS_stim,
      LED => LED_stim   
      );

  stimulus : process
  begin
    wait for 100 ns;

    --place stimulus here
    
    wait; -- will wait forever
    end process stimulus; --

    clock_gen : process is
      begin
        s_clk_stim <= '0' after Tpw_clk, '1' after 2*Tpw_clk;
        wait for 2*Tpw_clk;
      end process clock_gen;
      
end simulate;
