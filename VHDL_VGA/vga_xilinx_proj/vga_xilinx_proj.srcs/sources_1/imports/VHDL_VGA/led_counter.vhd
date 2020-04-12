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


-- count = (T*f)/(units us)
entity led_counter is
  generic(
    INPUT_CLK_FREQ_M     : real := 100.0e6;
    DESIRED_LED_PER_us   : real := 1.0e6
    );
  port(
    input_clk : in std_logic;
    rst       : in std_logic;
    out_pulse : out std_logic
    );
end entity led_counter;

architecture behav of led_counter is
  signal out_pulse_sig : std_logic;
begin

  out_pulse <= out_pulse_sig;
  
  cntr: process(input_clk) is
  --constant mx_cnt      : real := (INPUT_CLK_FREQ_M*1000000.0)/(DESIRED_LED_PER_us);
  --constant mx_cnt_nat  : natural := natural(mx_cnt);
    --constant mx_cnt_bits : natural := natural(log2(ceil(mx_cnt)));
  constant u_second             : real := 1.0e-6;
  variable count_real           : real := (INPUT_CLK_FREQ_M*DESIRED_LED_PER_us)/(u_second);
  variable count_integer        : integer := integer(count_real);
  variable count_bits           : integer := integer(log2(ceil(real(count_integer))));  
  variable cntr                 : unsigned(count_bits-1 downto 0);
  
  begin
    if (rising_edge(input_clk)) then
      if (rst = '1') then
        cntr := (others => '0');
        out_pulse_sig <= '0';
      else
        out_pulse_sig <= out_pulse_sig;
        if (cntr = count_integer) then
          cntr := (others => '0');
          out_pulse_sig<= not out_pulse_sig;
        else
          cntr := cntr + 1;          
        end if;
                  
      end if;
    end if;
  end process cntr;
    
end architecture behav;


