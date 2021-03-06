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

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- See https://github.com/sporniket/seed-vhdl/wiki/n_bits_counter_be
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
entity n_bits_counter_be_behavior_test_suite is
end n_bits_counter_be_behavior_test_suite;

architecture test_suite of n_bits_counter_be_behavior_test_suite is
  constant test_width : integer := 3;
  constant index_msb : integer := test_width - 1;

  -- declare record type
  type test_vector is record
    rst : hi;
    oe :  hi;
    cs : hi;
    q : vc(index_msb downto 0);
    q_clk : hi;
  end record;

  type test_vector_array is array (natural range <>) of test_vector;
  constant test_vectors : test_vector_array := (
    -- When rst is asserted, the expected value is tested without clock pulse
    -- | rst | oe | cs | q | q_clk |
    (hi_asserted, hi_asserted, hi_asserted, "000", '0'),
    (hi_negated, hi_asserted, hi_asserted, "001", '1'),
    (hi_negated, hi_asserted, hi_asserted, "010", '1'),
    (hi_negated, hi_asserted, hi_asserted, "011", '1'),
    (hi_negated, hi_negated, hi_asserted, "011", '0'),
    (hi_negated, hi_negated, hi_asserted, "011", '0'),
    (hi_negated, hi_asserted, hi_negated, "101", '1'),
    (hi_negated, hi_asserted, hi_negated, "101", '0'),
    (hi_negated, hi_asserted, hi_asserted, "110", '1'),
    (hi_negated, hi_asserted, hi_asserted, "111", '1'),
    (hi_negated, hi_asserted, hi_asserted, "000", '1'),
    (hi_negated, hi_asserted, hi_asserted, "001", '1')
  );

  -- test signals
  -- control
  signal in_clk : hi;
  signal in_rst : hi;
  signal in_cs : hi;
  signal in_oe : hi;

  -- inputs

  -- outputs
  signal out_q : vc(index_msb downto 0);
  signal out_q_clk : hi;

begin
  dut : entity sporniket.n_bits_counter_be
    generic map
    (
      width => test_width
    )
    port map
    (
      -- inputs
      cs => in_cs,
      oe => in_oe,
      clk => in_clk,
      rst => in_rst,

      -- outputs
      q => out_q,
      q_clk => out_q_clk
    );

  execute : process
  begin
    wait for 1 ns;
    report "Testing operation state...";

    for i in test_vectors'range loop
      -- prepare
      in_rst <= test_vectors(i).rst;
      in_oe <= test_vectors(i).oe;
      in_cs <= test_vectors(i).cs;

      -- clock pulse if appropriate
      wait for 1 ns;
      if test_vectors(i).rst = hi_negated then
        in_clk <= '1';
      end if;
      wait for 1 ns;

      -- verify -- general
      assert out_q = test_vectors(i).q
      report "test_vector " & integer'image(i) & " failed " &
        " got '" & to_string(out_q) &
        "' instead OF '" & to_string(test_vectors(i).q) & "'"
      severity failure;
      -- verify -- q_clk
      assert
        out_q_clk = test_vectors(i).q_clk
      report "test_vector " & integer'image(i) & " failed **for q_clk** " &
        " got '" &
        to_string(out_q_clk) &
        "' instead of '" &
        to_string(test_vectors(i).q_clk) & "'"
      severity failure ;

      -- end of clock pulse, anyway
      wait for 1 ns;
      in_clk <= '0';
      wait for 1 ns;

      -- verify -- end of q_clk pulse.
      assert
        out_q_clk = hi_negated
      report "test_vector " & integer'image(i) & " failed, q_clk is not negated."
      severity failure ;

    end loop;
    report "Done.";
    finish;
  end process execute;
end test_suite;
