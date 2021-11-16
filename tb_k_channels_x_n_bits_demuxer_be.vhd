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
-- See https://github.com/sporniket/seed-vhdl/wiki/k_channels_x_n_bits_demuxer_be
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
entity k_channels_x_n_bits_demuxer_be_behavior_test_suite is
end k_channels_x_n_bits_demuxer_be_behavior_test_suite;

architecture test_suite of k_channels_x_n_bits_demuxer_be_behavior_test_suite is
  constant test_channel_count : integer := 2;
  constant test_channel_width : integer := 2;
  constant width_of_input : integer := test_channel_width ;
  constant width_of_output : integer := test_channel_count * test_channel_width ;

  -- declare record type
  type test_vector is record
    rst, oe, cs : std_logic;
    x : vc(width_of_input - 1 downto 0);
    x_latch : hi;
    x_sel : natural range 0 to 1;
    q : vc(width_of_output - 1 downto 0);
  end record;

  type test_vector_array is array (natural range <>) of test_vector;
  constant test_vectors : test_vector_array := (
    -- When rst is asserted, the expected value is tested without clock pulse
    -- | rst | oe | cs | x | x_latch | x_sel | q |
    (hi_asserted, hi_negated, hi_negated, "10", hi_asserted, 0, "0000"),
    (hi_asserted, hi_negated, hi_negated, "10", hi_asserted, 1, "0000"),
    (hi_negated, hi_asserted, hi_negated, "10", hi_asserted, 1, "0000"),
    (hi_negated, hi_asserted, hi_negated, "01", hi_asserted, 0, "0000"),
    (hi_negated, hi_asserted, hi_asserted, "01", hi_asserted, 0, "0001"),
    (hi_negated, hi_asserted, hi_asserted, "10", hi_asserted, 1, "1001"),
    (hi_negated, hi_asserted, hi_negated, "11", hi_asserted, 0, "1001"),
    (hi_negated, hi_negated, hi_asserted, "11", hi_asserted, 0, "1001"),
    (hi_negated, hi_negated, hi_asserted, "00", hi_asserted, 1, "1001"),
    (hi_negated, hi_asserted, hi_negated, "10", hi_asserted, 0, "0011"),
    (hi_negated, hi_asserted, hi_asserted, "10", hi_negated, 1, "1000")
  );

  -- test signals
  -- control
  signal in_clk, in_rst, in_cs, in_oe : std_logic;

  -- inputs
  signal in_x : vc(width_of_input - 1 downto 0);
  signal in_x_latch : hi;
  signal in_x_sel : natural range 0 to test_channel_count - 1;

  -- outputs
  signal out_q: vc(width_of_output - 1 downto 0);

begin
  dut : entity sporniket.k_channels_x_n_bits_demuxer_be
    generic map
    (
      channel_count => test_channel_count,
      channel_width => test_channel_width
    )
    port map
    (
      -- inputs
      cs => in_cs,
      oe => in_oe,
      clk => in_clk,
      rst => in_rst,

      x => in_x,
      x_latch => in_x_latch,
      x_sel => in_x_sel,

      -- outputs
      q => out_q
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
      in_x <= test_vectors(i).x;
      in_x_latch <= test_vectors(i).x_latch;
      in_x_sel <= test_vectors(i).x_sel;

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
