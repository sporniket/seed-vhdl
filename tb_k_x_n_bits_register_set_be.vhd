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
-- See https://github.com/sporniket/seed-vhdl/wiki/k_x_n_bits_register_set_be
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
entity k_x_n_bits_register_set_be_behavior_test_suite is
end k_x_n_bits_register_set_be_behavior_test_suite;

architecture test_suite of k_x_n_bits_register_set_be_behavior_test_suite is
  constant test_register_count : positive := 2;
  constant test_register_width : integer := 2;
  constant width_of_input : integer := test_register_width ;
  constant width_of_output : integer := test_register_width ;

  -- declare record type
  type test_vector is record
    rst, oe, cs : hi;
    x_select : natural range 0 to test_register_count - 1;
    x_strobe : hi;
    x_value : vc(width_of_input - 1 downto 0);
    q : vc(width_of_output - 1 downto 0);
  end record;

  type test_vector_array is array (natural range <>) of test_vector;
  constant test_vectors : test_vector_array := (
    -- When rst is asserted, the expected value is tested without clock pulse
    -- | rst | oe | cs | x_select | x_strobe | x_value | q |
    (hi_asserted, hi_negated, hi_negated, 0, hi_negated, "11", "00"),
    (hi_negated, hi_asserted, hi_asserted, 0, hi_negated, "11", "00"),
    (hi_negated, hi_asserted, hi_asserted, 1, hi_negated, "11", "00"),
    (hi_negated, hi_asserted, hi_asserted, 0, hi_asserted, "01", "01"),
    (hi_negated, hi_negated, hi_asserted, 1, hi_asserted, "10", "01"),
    (hi_negated, hi_asserted, hi_negated, 1, hi_negated, "11", "10"),
    (hi_negated, hi_asserted, hi_asserted, 0, hi_negated, "11", "01"),
    (hi_negated, hi_asserted, hi_negated, 1, hi_negated, "11", "01"),
    (hi_negated, hi_asserted, hi_asserted, 1, hi_negated, "11", "10")
  );

  -- test signals
  -- control
  signal in_clk, in_rst, in_cs, in_oe : std_logic;

  -- inputs
  signal in_x_select : natural range 0 to test_register_count - 1;
  signal in_x_strobe : hi;
  signal in_x_value : vc(width_of_input - 1 downto 0);

  -- outputs
  signal out_q: vc(width_of_output - 1 downto 0);

begin
  dut : entity work.k_x_n_bits_register_set_be
    generic map
    (
      register_count => test_register_count,
      register_width => test_register_width
    )
    port map
    (
      -- inputs
      cs => in_cs,
      oe => in_oe,
      clk => in_clk,
      rst => in_rst,

      x_select => in_x_select,
      x_strobe => in_x_strobe,
      x_value => in_x_value,

      -- outputs
      q => out_q
    );

  execute : process
  begin
    report "prepare";
    in_clk <= hi_negated;
    in_rst <= hi_negated;
    in_cs <= hi_asserted;
    in_oe <= hi_asserted;

    wait for 1 ns;

    report "Testing operation state...";

    for i in test_vectors'range loop
      -- prepare
      in_rst <= test_vectors(i).rst;
      in_oe <= test_vectors(i).oe;
      in_cs <= test_vectors(i).cs;
      in_x_select <= test_vectors(i).x_select;
      in_x_strobe <= test_vectors(i).x_strobe;
      in_x_value <= test_vectors(i).x_value;

      -- clock pulse if appropriate
      wait for 1 ns;
      if test_vectors(i).rst = hi_negated then
        in_clk <= '1';
      end if;
      wait for 1 ns;

      -- verify
      assert
        out_q = test_vectors(i).q
      report "test_vector " & integer'image(i) & " failed " &
        " got '" &
        to_string(out_q) &
        "' instead of '" &
        to_string(test_vectors(i).q) & "'"
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
