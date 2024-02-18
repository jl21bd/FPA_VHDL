package flower_pollination_package is
 -- type for a vector with real values
    type real_vector is array(natural range <>) of real;
end flower_pollination_package;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.flower_pollination_package.all;

entity final2 is
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
end final2;

architecture Behavioral of final2 is
    -- function to calculate the levy flight value
    function levy_flight(beta: real; levy_vector: real_vector) return real is
        constant sig_num: real := 0.9399856029866254;
        constant sig_den: real := 1.6168504121556964;
        variable sigma, levy: real;
        variable r1, r2: real;
    begin
        r1 := levy_vector(1);
        r2 := levy_vector(2);
        sigma := (sig_num / sig_den) ** (1.0 / beta);
        levy := (0.01 * r1 * sigma) / (real(abs(r2)) ** (1.0 / beta));
        return levy;
    end levy_flight;

    -- function to calculate the global pollination value
    function pollination_global(position: real_vector; levy_vector: real_vector; best_position: real_vector; 
                                        min: integer; max: integer; gamma: real; lamb: real) return real_vector is
        variable x: real_vector(1 to 2);
        variable delta: real;
    begin
        -- calculate each coordinate positions
        for i in 1 to 2 loop
            x(i) := position(i) + gamma * levy_flight(lamb, levy_vector) * (best_position(i) - position(i));
            -- make sure the positions are within the boundaries 
            -- otherwise set to min or max
            if x(i) < real(min) then
                x(i) := real(min);
            elsif x(i) > real(max) then
                x(i) := real(max);
            end if;
        end loop;
        return x;
    end pollination_global;

    -- function to calculate the local pollination value
    function pollination_local(local_vector: real_vector; position: real_vector; xxx: real; min: integer;                                                               max: integer) return real_vector is 
        variable x: real_vector(1 to 2);
        variable delta: real;
        variable r: real;
     begin
        r := xxx; -- random real value
        -- find the delta value to calculate each coordinate positions
        for i in 1 to 2 loop
            delta := r * (position(i) - local_vector(i));
            -- make sure the positions are within the boundaries 
            -- otherwise set to min or max
            if (position(i) + delta) > real(max) then
                x(i) := real(max);
            elsif (position(i) + delta) < real(min) then
                x(i) := real(min);
            else
                x(i) := position(i) + delta;
            end if;
        end loop;
        return x;
    end pollination_local;
    
begin
    process (clk, rst) 
        variable xx : real_vector(1 to 2);
        variable temp, minimum : real := 0.0;
        variable best_vector : real_vector(1 to 2) := (others => 0.0);
        variable count : integer;
    begin 
        if (rst = '1') then -- reset 
            best_vector := (others => 0.0);
            minimum := 0.0;
        elsif (rising_edge(clk)) then  -- every clock cycle execute the algorithm
            -- if a random number is less than the input probability value then global pollination
            -- otherwise local pollination 
            if (xxx < p) then
                xx := pollination_global(x_vector, levy_vector, best_vector, min, max, gamma, lamb);
            else
                xx := pollination_local(local_vector, x_vector, xxx, min, max);
            end if;   
            -- using the positions found from global or local pollination, calculate the function value             
            temp := ((4.0 - 2.1*(xx(1)**2) + (xx(1)**4)/3.0))*(xx(1)**2)
                                 + (xx(1)*xx(2)) + (-4.0 + 4.0*(xx(2)**2))*(xx(2)**2);
                    -- check if the value is the minimum 
                    -- if less change the minimum and the best positoins accordingly
                    if (temp <= minimum) then
                        minimum := temp;
                        best_vector(1) := xx(1);
                        best_vector(2) := xx(2);
                    end if;  
        -- output the signal of best positions and the minimum
        best_x(1) <= best_vector(1);
        best_x(2) <= best_vector(2); 
        fx <= minimum;
        end if;
    end process;
end Behavioral;

