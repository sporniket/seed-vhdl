-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- Copyright (C) 2021 David SPORN.
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- This file is part of @TERM{Project}.
--
-- @TERM{Project} is free hardware design : you can redistribute it and/or
-- modify it under the terms of the Lesser GNU General Public License as
-- published by the Free Software Foundation, either version 3 of the License,
-- or (at your option) any later version.
--
-- @TERM{Project} is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the Lesser GNU General Public
-- License for more details.
--
-- You should have received a copy of the Lesser GNU General Public License
-- along with Foobar.  If not, see <https://www.gnu.org/licenses/>.
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

-- require the sporniket core package
library sporniket;
use sporniket.core.all;

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
--- n-bit counter -- Big Endian
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
--
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
entity n_bits_counter_be is
	generic(
    	width : integer := 32
    ) ;
    port(
    	-- -- control signals
    	-- Chip Select : when asserted at leading clock edge, internal counter is running.
        cs : in hi ;
        -- Output Enable : when asserted at leading clock edge, q is updated.
        oe : in hi ;
        -- Clock.
        clk : in hi ;
        -- Asynchronous reset : when asserted, all is set to zero.
        rst : in hi ;

    	-- -- input signals

    	-- -- output signals
        -- output value.
        q : out vc(width - 1 downto 0)
    );
end n_bits_counter_be;

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- n-bit counter -- Big Endian
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
--
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
architecture behavior of n_bits_counter_be is
	constant max_value : integer := (2**width) ;
begin
	on_event:process(clk,rst)
    	variable value : integer := 0;
    begin
    	if hi_asserted = rst then
        	value := 0;
           	q <= std_logic_vector(to_unsigned(value, q'length));
        elsif hi_is_leading_edge(clk) then
        	if hi_asserted = cs then
            	value := value + 1 ;
                if (value >= max_value) then
                	value := 0 ;
                end if;
            end if;
            if hi_asserted = oe then
            	q <= std_logic_vector(to_unsigned(value, q'length));
            end if;
        end if;
    end process on_event;
end behavior ;
