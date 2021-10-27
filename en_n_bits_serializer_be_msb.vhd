-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- Written in 2021 by David SPORN.
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- This file is part of [seed-vhdl] : 
-- <https://github.com/sporniket/seed-vhdl>
--
-- [seed-vhdl] is free hardware design : 
--
-- To the extent possible under law, David SPORN has waived all copyright
-- and related or neighboring rights to this under the terms of the Creative 
-- Commons CC0 License as published by the Creative Commons global nonprofit 
-- organization <https://creativecommons.org/>, either version 1.0 of the 
-- License, or (at your option) any later version.
--
-- This project is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the Creative Commons CC0 License
-- for more details.
--
-- You should have received a copy of the Creative Commons CC0 License along
-- with this project. If not, see 
-- <http://creativecommons.org/publicdomain/zero/1.0/>.
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
--- n-bits serializer -- Big Endian, MSB first
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- Shifting is operated at leading edge
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
entity n_bits_serializer_be_msb is
	generic(
    	width : integer := 32
    ) ;
    port(
    	-- -- control signals
        -- data strobe : when asserted at leading clock edge, the register loads its value from data.
        ds : in hi ;
        -- chip select : when asserted, and ds is negated, at leading clock edge, internal value
        --     is shifted to send next bit
        cs : in hi ;
        -- output enable : when asserted, at leading clock edge, the output bit is updated
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
        q : out hi ;
        -- q bar : the inverse of q (q bar = not q)
        q_bar : out lo ;
        -- q watch : asserted when it is the last bit.
        q_watch : out hi

    );
end n_bits_serializer_be_msb;

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- n-bit -- Big Endian
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
--
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
architecture behavior of n_bits_serializer_be_msb is
	constant index_msb : integer := width - 1;
    constant value_zero : vc(index_msb downto 0) := (others => '0');
    constant init_value_of_bit_watcher : vc(index_msb downto 0) := std_logic_vector(to_unsigned(1, width));

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
    	variable bit_watcher : vc(index_msb downto 0) := init_value_of_bit_watcher;
    begin
    	if hi_asserted = rst then
        	value := value_zero;
            bit_watcher := init_value_of_bit_watcher;
            send_to_output(value, bit_watcher, q, q_bar, q_watch) ;
        elsif hi_is_leading_edge(clk) then
            if hi_asserted = cs then
               if hi_asserted = ds then
                  value := d;
                  bit_watcher := init_value_of_bit_watcher;
               else
                  value := value(index_msb - 1 downto 0) & '0' ;
                  bit_watcher := bit_watcher(index_msb - 1 downto 0) & '0' ;
               end if;
            end if;
            if hi_asserted = oe then
            	send_to_output(value, bit_watcher, q, q_bar, q_watch) ;
            end if;
        end if;
    end process on_event;
end behavior ;
