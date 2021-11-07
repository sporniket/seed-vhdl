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
-- or FITNESS FOR A PARTICULAR PURPOSE. See the Creative Commons CC0 License
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

-- require the sporniket core package
library sporniket;
use sporniket.core.all;
use sporniket.test.all;

entity n_bits_serializer_be_msb_behavior_test_suite is
end n_bits_serializer_be_msb_behavior_test_suite;

architecture test_suite of n_bits_serializer_be_msb_behavior_test_suite is
	constant test_width : integer := 5 ;
    constant loaded_value : vc(test_width - 1 downto 0) := "10101" ;

	-- declare record type
    type test_vector is record
    	oe, cs, ds, q, q_bar, watcher : std_logic ;
    end record;

    type test_vector_array is array (natural range <>) of test_vector;
    constant test_vectors : test_vector_array := (
        -- expected values after clock main edge, starting after reset has been
        -- asserted then negated
        -- | oe | cs | ds | q | q_bar | q_watch |
        (hi_asserted, hi_negated,  hi_asserted, '0', '1', '0'),
        (hi_asserted, hi_asserted, hi_asserted, '1', '0', '0'),
        (hi_asserted, hi_asserted, hi_negated,  '0', '1', '0'),
        (hi_asserted, hi_asserted, hi_negated,  '1', '0', '0'),
        (hi_negated,  hi_asserted, hi_negated,  '1', '0', '0'),
        (hi_asserted, hi_negated,  hi_negated,  '0', '1', '0'),
        (hi_asserted, hi_asserted, hi_negated,  '1', '0', '1'),
        (hi_asserted, hi_asserted, hi_negated,  '0', '1', '0'),
        (hi_asserted, hi_asserted, hi_negated,  '0', '1', '0')
    );

    -- test signals
    -- inputs
    signal in_clk,in_rst,in_ds,in_cs,in_oe: std_logic ; -- cannot use subtype, not added in epwave...
    signal data : vc(test_width - 1 downto 0) := loaded_value ;

    -- outputs
    signal out_q, out_q_bar, out_q_watch : std_logic;

begin
	dut : entity work.n_bits_serializer_be_msb
    generic map (
    	width => test_width
    )
    port map (
    	-- inputs
        ds => in_ds,
    	  cs => in_cs,
        oe => in_oe,
        clk => in_clk,
        rst => in_rst,

        d => data,

        -- outputs
        q => out_q,
        q_bar => out_q_bar,
        q_watch => out_q_watch
    );

    execute:process
    begin
        report "prepare" ;
        in_clk <= hi_negated;
        in_rst <= hi_negated;
        in_cs <= hi_asserted;
        in_oe <= hi_asserted;
        in_ds <= hi_negated;


        report "Testing reset state..." ;

        in_rst <= '1';
        wait for 2 ns ;
        in_clk <= '1';

        assert out_q = '0' and out_q_watch = '0' report "Reset state is wrong" ;

        in_clk <= '0';
        in_rst <= '0';

        wait for 1 ns;

        report "Testing operation state..." ;

		for i in test_vectors'range loop
            in_oe <= test_vectors(i).oe;
            in_cs <= test_vectors(i).cs;
            in_ds <= test_vectors(i).ds;
			wait for 1 ns;

            in_clk <= '1';
            wait for 1 ns;

            assert out_q = test_vectors(i).q
            	and out_q_bar = test_vectors(i).q_bar
                and out_q_watch = test_vectors(i).watcher
            report "test_vector " & integer'image(i) & " failed " &
                    " got '" & to_string(out_q & out_q_bar & out_q_watch) &
                    "' instead of '" &
                    to_string(test_vectors(i).q &
                    test_vectors(i).q_bar &
                    test_vectors(i).watcher) & "'" ;

            wait for 1 ns;
            in_clk <= '0';
            wait for 1 ns;

        end loop;
        report "Done." ;
        finish ;
    end process execute ;
end test_suite ;
