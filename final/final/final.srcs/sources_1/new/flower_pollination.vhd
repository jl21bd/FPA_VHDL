
package flower_pollination_package is
    -- type that holds a dymanic amount of real numbers to represent a vector
    type real_vector is array(natural range <>) of real;
    -- type that holds a dynamic amount of real_vector(1 to 3) to represent a matrix
    type real_vector_vector is array(natural range <>) of real_vector(1 to 3);
end flower_pollination_package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.flower_pollination_package.all;

entity flower_pollination is
    port (
        clk: in std_logic;                     -- clock signal
        reset: in std_logic;                   -- reset signal
        flower_count: in integer;              -- numnber of flowers
        min: in integer;                       -- min value
        max: in integer;                       -- max value
        gamma: in real;                        -- gamma value
        lamb: in real;                         -- lambda value
        p: in real;                            -- probability value
        iterations: in integer;                -- number of iterations
        best_solution: out real_vector(1 to 3) -- best solution output
    );
end flower_pollination;

architecture beh of flower_pollination is
    -- generates two random real numbers
    function random_real return real_vector is
            variable seed1: integer := 123456789;
            variable seed2: integer := 987654321;
            variable seed3: integer := 239438458;
            variable rand_real1: real;
            variable rand_real2: real;
            variable random: real_vector(1 to 2);
    begin
        -- generate the first random real number
        uniform(seed1, seed2, rand_real1);
        -- generate the second random real number
        uniform(seed2, seed3, rand_real2);
        random(1) := rand_real1;
        random(2) := rand_real2;
        return random;
    end random_real;
    
    -- generate a random integer bounded by the min and max values
    function random_integer(min_value: integer; max_value: integer) return integer is
        variable real_random: real;
        variable seed1, seed2: positive := 987654321;
    begin
        -- generate the random real number
        uniform(seed1, seed2, real_random);
        -- bound the number and convert it to an integer
        return integer(real(min_value) + real_random * real(max_value - min_value + 1));
    end random_integer;
    
    -- Six Hump Camel Back objective function
    function six_hump_camel_back(variables: real_vector) return real is
            variable x: real := variables(1);
            variable y: real := variables(2);
    begin
        return 4.0 * (x**2) - 2.1 * (x**4) + ((1.0/3.0) * (x**6)) + x * y - 4.0 * (y**2) + 4.0 * (y**4);
    end six_hump_camel_back;
    
    -- compare the fitness of two positions
    function fitness_compare(a: real_vector; b: real_vector) return boolean is
    begin
        return (six_hump_camel_back(a) <= six_hump_camel_back(b));
    end fitness_compare;
    
    -- initialize the flower's positions
    function initial_positions(flower_count: integer; min: integer; max: integer) return real_vector_vector is
        variable positions: real_vector_vector(1 to flower_count);
    begin
        -- iterate through each flower
        for i in 1 to flower_count - 1 loop
            -- generate a random coordinate for each x and y value within the specified search space
            for j in 1 to 2 loop
                positions(i)(j) := real(min) + random_real(j) * real(max - min + 1);
            end loop;
            -- evaluate the fitness of the position
            positions(i)(3) := six_hump_camel_back(positions(i));
        end loop;
        return positions;
    end initial_positions;
    
    -- calculate the step length using Levy flight to determine how far a solution moves
    function levy_flight(beta: real) return real is
        constant sig_num: real := 0.9399856029866254;
        constant sig_den: real := 1.6168504121556964;
        variable sigma: real;
        variable levy: real;
        variable r1, r2: real;
    begin
        r1 := random_real(1);
        r2 := random_real(1);
        sigma := (sig_num / sig_den) ** (1.0 / beta);
        levy := (0.01 * r1 * sigma) / (real(abs(r2)) ** (1.0 / beta));
        return levy;
    end levy_flight;
    
    -- performs global pollination where a flower can pollinate with any flower in the environment
    function pollination_global(positions: real_vector_vector; best_position: real_vector; min: integer; 
                                max: integer; flower: integer; gamma: real; lamb: real) return real_vector is
        variable x: real_vector(1 to 3);
        variable delta: real;
    begin
        -- create a new x and y coordinate position using global pollination
        for i in 1 to 2 loop
            x(i) := positions(flower)(i) + gamma * levy_flight(lamb) * (best_position(i) - positions(flower)(i));
            -- ensure the value is within boundaries
            if x(i) < real(min) then
                x(i) := real(min);
            elsif x(i) > real(max) then
                x(i) := real(max);
            end if;
        end loop;
        -- evaluate the fitness of the position
        x(3) := six_hump_camel_back(x);
        return x;
    end pollination_global;
    
    -- performs local pollination where a flower can only pollinate with its neighboring flowers
    function pollination_local(flower_count: integer; flower: integer; positions: real_vector_vector; 
                               min: integer; max: integer) return real_vector is 
        variable x: real_vector(1 to 3);
        variable delta: real;
        variable r: real;
        variable nb_flower_1: integer := random_integer(1, flower_count);
        variable nb_flower_2: integer := random_integer(1, flower_count);
     begin
        r := random_real(1);
        -- create a new x and y coordinate position using local pollination
        for i in 1 to 2 loop
            delta := r * (positions(nb_flower_1)(i) - positions(nb_flower_2)(i));
            -- ensure the value is within boundaries
            if (positions(flower)(i) + delta) > real(max) then
                x(i) := real(max);
            elsif (positions(flower)(i) + delta) < real(min) then
                x(i) := real(min);
            else
                x(i) := positions(flower)(i) + delta;
            end if;
        end loop;
        -- evaluate the fitness of the position
        x(3) := six_hump_camel_back(x);
        return x;
    end pollination_local;
    
    signal count: integer := 0;
begin
    process (clk, reset)
        variable positions: real_vector_vector(1 to 175);
        variable best_position: real_vector(1 to 3);
        variable x: real_vector(1 to 3);
    begin
        if (reset = '1') then
            -- reset the count, initialize the flower positions, and set the default best position
            count <= 0;
            positions := initial_positions(flower_count, min, max);
            best_position := positions(1);
        elsif (rising_edge(clk)) then
            -- keep running the algorithm for the specified number of iterations
            if (count < iterations) then
                -- iterate through each flower
                for i in 1 to flower_count loop
                    -- if a random number is less than p then perform global pollination
                    -- otherwise perform local pollination
                    if (random_real(1) < p) then
                        x := pollination_global(positions, best_position, min, max, i, gamma, lamb);
                    else
                        x := pollination_local(flower_count, i, positions, min, max);
                    end if;
                    -- compare the new position to the best position and update if better
                    if (fitness_compare(positions(i), best_position)) then
                        best_position := positions(i);
                    end if;
                end loop;
                -- increment the count
                count <= count + 1;
            end if;
        else
            -- set the output best solution to the best position found
            best_solution <= best_position;
        end if;
    end process;
end beh;
