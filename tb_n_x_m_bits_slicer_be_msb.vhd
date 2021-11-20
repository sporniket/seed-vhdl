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
-- See https://github.com/sporniket/seed-vhdl/wiki/n_x_m_bits_slicer_be_msb
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
entity n_x_m_bits_slicer_be_msb_behavior_test_suite is
end n_x_m_bits_slicer_be_msb_behavior_test_suite;

architecture test_suite of n_x_m_bits_slicer_be_msb_behavior_test_suite is
  constant test_slice_count : integer := 5;
  constant test_slice_width : integer := 2;
  constant width_of_input : integer := test_slice_count * test_slice_width ;
  constant loaded_value : vc(width_of_input - 1 downto 0) := "1001100110";

  -- declare record type
  type test_vector is record
    rst : hi;
    oe : hi;
    cs : hi;
    q : vc(test_slice_width - 1 downto 0);
    q_bar : vc(test_slice_width - 1 downto 0);
    q_clk : hi;
    q_strobe : hi
  end record;

  type test_vector_array is array (natural range <>) of test_vector;
  constant test_vectors : test_vector_array := (
    -- When rst is asserted, the expected value is tested without clock pulse
    -- | rst | oe | cs | x_strobe | q | q_bar | q_ckl | q_strobe |
    (hi_asserted, hi_negated, hi_negated, hi_negated, "00", "11", '0', '0'),
    (hi_negated, hi_asserted, hi_negated, hi_asserted, "00", "11", '0', '0'),
    (hi_negated, hi_asserted, hi_asserted, hi_asserted, "10", "01", '1', '0'),
    (hi_negated, hi_asserted, hi_asserted, hi_negated, "01", "10", '1', '0'),
    (hi_negated, hi_asserted, hi_asserted, hi_negated, "10", "01", '1', '0'),
    (hi_negated, hi_negated, hi_asserted, hi_negated, "10", "01", '0', '0'),
    (hi_negated, hi_asserted, hi_negated, hi_negated, "01", "10", '1', '0'),
    (hi_negated, hi_asserted, hi_asserted, hi_negated, "10", "01", '1', '1'),
    (hi_negated, hi_asserted, hi_asserted, hi_negated, "00", "11", '1', '0'),
    (hi_negated, hi_asserted, hi_asserted, hi_negated, "00", "11", '1', '0')
  );

  -- test signals
  -- control
  signal in_clk : hi;
  signal in_rst : hi;
  signal in_cs : hi;
  signal in_oe : hi;

  -- inputs
  signal in_x : vc(width_of_input - 1 downto 0) := loaded_value;
  signal in_x_strobe : hi

  -- outputs
  signal out_q: vc(test_slice_width - 1 downto 0);
  signal out_q_bar: vc(test_slice_width - 1 downto 0);
  signal out_q_clk : hi;
  signal out_q_strobe : hi

begin
  dut : entity sporniket.n_x_m_bits_slicer_be_msb
    generic map
    (
      slice_count => test_slice_count,
      slice_width => test_slice_width
    )
    port map
    (
      -- inputs
      cs => in_cs,
      oe => in_oe,
      clk => in_clk,
      rst => in_rst,

      x => in_x,
      x_strobe => in_x_strobe,

      -- outputs
      q => out_q,
      q_bar => out_q_bar,
      q_clk => out_q_clk,
      q_strobe => out_q_strobe
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
      in_x_strobe <= test_vectors(i).x_strobe;

      -- clock pulse if appropriate
      wait for 1 ns;
      if test_vectors(i).rst = hi_negated then
        in_clk <= '1';
      end if;
      wait for 1 ns;

      -- verify
      assert
        out_q = test_vectors(i).q
        and out_q_bar = test_vectors(i).q_bar
        and out_q_strobe = test_vectors(i).q_strobe
      report "test_vector " & integer'image(i) & " failed " &
        " got '" & to_string(out_q & out_q_bar & out_q_strobe) &
        "' instead of '" &
        to_string(test_vectors(i).q &
        test_vectors(i).q_bar &
        test_vectors(i).q_strobe) & "'"
      severity failure ;

      -- end of clock pulse, anyway
      wait for 1 ns;
      in_clk <= '0';
      wait for 1 ns;

    end loop;
    report "Done.";
    finish;
  end process execute;
end test_suite;
