library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;
use ieee.math_real.all;
use work.flower_pollination_package.all;

entity final2_tb is
end;

architecture bench of final2_tb is

  component final2
  Port ( clk, rst : in std_logic;   -- clock and reset signal
        flower_count: in integer;   -- number of flowers
        iteration : in integer;     -- number of iterations 
        min, max: in integer;       -- minimum and maximum boundary
        gamma, lamb: in real;       -- gamma and lmbda value
        p: in real;                 -- probability value
        xxx : in real;              -- random real value
         -- vector with random real value for functions and equations
        x_vector,levy_vector, local_vector : in real_vector(1 to 2);
        best_x : out real_vector(1 to 2); -- vector of best values
        fx : out real );            -- best solution(minimum) 
  end component;

  signal clk, rst: std_logic;
  signal flower_count: integer;
  signal iteration : integer;
  signal min, max: integer;
  signal gamma, lamb: real;
  signal p: real;
  signal xxx : real;
  signal  x_vector,levy_vector, local_vector : real_vector(1 to 2);
  signal best_x : real_vector(1 to 2);
  signal fx: real;

  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

begin
  uut: final2 port map ( clk          => clk,
                         rst          => rst,
                         flower_count => flower_count,
                         iteration => iteration,
                         min          => min,
                         max          => max,
                         gamma        => gamma,
                         lamb         => lamb,
                         p            => p,
                         xxx          => xxx,
                         x_vector     => x_vector,
                         levy_vector  => levy_vector,
                         local_vector  => local_vector,
                         best_x  => best_x,
                         fx           => fx );

  stimulus: process
  variable seed1, seed2, seed3, seed4, seed5 : positive;
  variable xx, y, z, levy1, levy2, local1, local2 : real;
  begin
    -- reset the values
    rst <= '1';
        wait for 10 ns;
    rst <= '0';
    -- initialization for each inputs
    flower_count  <= 175;
    iteration <= 300; 
    min           <= -5;
    max           <= 5;
    gamma         <= 0.1;
    lamb          <= 1.5;
    p             <= 0.8;
    
    -- seed numbers for random number generator
    seed1 := 1;
    seed2 := 2;
    seed3 := 3;
    seed4 := 4;
    seed5 := 5;
    for n in 1 to 300 loop
        -- using the seed values to generate random numbers each iterations
        uniform(seed1, seed2, xx);
        uniform(seed1, seed3, y);
        uniform(seed2, seed3, z);
        uniform(seed1, seed4, levy1);
        uniform(seed1, seed5, levy2);
        uniform(seed2, seed4, local1);
        uniform(seed3, seed5, local2);
        -- assigning each random values to each inputs
        xxx <= xx;
        x_vector(1) <= y-0.002;
        x_vector(2) <= z-0.984;
        levy_vector(1) <= levy1;
        levy_vector(2) <= levy2;
        local_vector(1) <= local1;
        local_vector(2) <= local2;
            wait for 10 ns;
    end loop;
       
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
