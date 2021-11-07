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


entity n_bits_buffer_be_behavior_test_suite is
end n_bits_buffer_be_behavior_test_suite;

architecture test_suite of n_bits_buffer_be_behavior_test_suite is
	constant test_width : integer := 5 ;
    constant index_msb : integer := test_width - 1 ;

	-- declare record type
    type test_vector is record
    	oe, cs : hi ;
        d, q : vc(index_msb downto 0) ;
    end record;

    type test_vector_array is array (natural range <>) of test_vector;
    constant test_vectors : test_vector_array := (
        -- oe, cs, d, expected value after clock main edge
        -- | oe | cs | d | q |
        (hi_asserted, hi_asserted, "11111", "11111"),
        (hi_asserted, hi_asserted, "10101", "10101"),
        (hi_negated,  hi_asserted, "01010", "10101"),
        (hi_asserted, hi_negated,  "11011", "01010"),
        (hi_asserted, hi_asserted, "00011", "00011")
    );

    -- test signals
    -- inputs
    -- -- asserted
    signal in_clk,in_rst,in_cs,in_oe: std_logic ; -- cannot use subtype, not added in epwave...
    signal in_d : vc(index_msb downto 0) ;

    -- outputs
    signal out_q : vc(index_msb downto 0) ;

begin
	dut : entity work.n_bits_buffer_be
    generic map (
    	width => test_width
    )
    port map (
    	-- inputs
    	cs => in_cs,
        oe => in_oe,
        clk => in_clk,
        rst => in_rst,

        d => in_d,

        -- outputs
        q => out_q
    );

    execute:process
    begin
        report "prepare" ;
        in_clk <= hi_negated;
        in_rst <= hi_negated;
        in_cs <= hi_asserted;
        in_oe <= hi_asserted;


        report "Testing reset state..." ;

        in_rst <= '1';
        wait for 2 ns ;
        in_clk <= '1';

        assert out_q = "00000" report "Reset state is wrong" ;

        in_clk <= '0';
        in_rst <= '0';

        report "Testing operation state..." ;

		for i in test_vectors'range loop
            in_oe <= test_vectors(i).oe;
            in_cs <= test_vectors(i).cs;
            in_d <= test_vectors(i).d ;
			wait for 1 ns;

            in_clk <= '1';
            wait for 1 ns;

            assert out_q = test_vectors(i).q
            report "test_vector " & integer'image(i) & " failed " &
                    " got '" & to_string(out_q) &
                    "' instead of '" & to_string(test_vectors(i).q) & "'" ;

            wait for 1 ns;
            in_clk <= '0';
            wait for 1 ns;

        end loop;
        report "Done." ;
        finish ;
    end process execute ;
end test_suite ;
