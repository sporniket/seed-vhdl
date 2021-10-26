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
--- n-bits buffer -- Big Endian
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- Shifting is operated at leading edge
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
entity n_bits_buffer_be is
	generic(
    	width : integer := 32
    ) ;
    port(
    	-- -- control signals
        -- chip select : when asserted at leading clock edge, input data is loaded
        cs : in hi ;
        -- output enable : when asserted at leading clock edge, the output bit is updated
        oe : in hi ;
        -- clock : on leading edge, the state is updated.
        clk : in hi ;
        -- asynchronous reset : value is reset to zero.
        rst : in hi ;

        -- -- input signals
        -- data to load the register
        d : in vc(width - 1 downto 0) ;

        -- -- output signals
        -- q : the next bit, starting from the most significant byte
        q : out vc(width - 1 downto 0)
    );
end n_bits_buffer_be;

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
--- n-bits buffer -- Big Endian
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
--
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
architecture behavior of n_bits_buffer_be is
	constant index_msb : integer := width - 1;
    constant value_zero : vc(index_msb downto 0) := (others => '0');

    procedure send_to_output(
    	variable source_value : in vc(index_msb downto 0) ;
    	variable source_watcher : in vc(index_msb downto 0) ;
        signal recipient_q : out hi;
        signal recipient_q_bar : out lo;
        signal recipient_watcher : out hi
    ) is
    begin
    	recipient_q <= source_value(index_msb) ;
        recipient_q_bar <= not source_value(index_msb);
        recipient_watcher <= source_watcher(index_msb);
    end procedure;

begin
	on_event:process(clk,rst)
    	variable value : vc(index_msb downto 0) := value_zero;
    begin
    	if hi_asserted = rst then
        	value := value_zero;
            q <= value;
        elsif hi_is_leading_edge(clk) then
        	if hi_asserted = cs then
            	value := d;
            end if;
            if hi_asserted = oe then
            	q <= value;
            end if;
        end if;
    end process on_event;
end behavior ;