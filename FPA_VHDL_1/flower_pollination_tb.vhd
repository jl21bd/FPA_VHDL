package flower_pollination_package is
    type real_vector is array(natural range <>) of real;
    type real_vector_vector is array(natural range <>) of real_vector(1 to 3);
end flower_pollination_package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.flower_pollination_package.all;

entity flower_pollination_tb is
end;

architecture bench of flower_pollination_tb is

  component flower_pollination
      port (
          clk: in std_logic;
          reset: in std_logic;
          flower_count: in integer;
          min: in integer;
          max: in integer;
          gamma: in real;
          lamb: in real;
          p: in real;
          iterations: in integer;
          best_solution: out real_vector(1 to 3)
      );
  end component;

  signal clk: std_logic;
  signal reset: std_logic;
  signal flower_count: integer;
  signal min: integer;
  signal max: integer;
  signal gamma: real;
  signal lamb: real;
  signal p: real;
  signal iterations: integer;
  signal best_solution: real_vector(1 to 3) ;

  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

begin

  uut: flower_pollination port map ( clk           => clk,
                                     reset         => reset,
                                     flower_count  => 175,
                                     min           => -5,
                                     max           => 5,
                                     gamma         => 0.1,
                                     lamb          => 1.5,
                                     p             => 0.8,
                                     iterations    => 300,
                                     best_solution => best_solution);

  stimulus: process
  begin
  
    reset <= '1';
    wait for 10 ns;
    reset <= '0';

    wait;
  end process;

  clocking: process
  begin
    while not stop_the_clock loop
      clk <= '0', '1' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;

end;
