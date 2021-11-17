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
use ieee.numeric_std.all;

-- require the sporniket core package
library sporniket;
use sporniket.core.all;

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- Demuxer that outputs a stream of n-bit value into a k×n-bits value representing
-- the concatenation of k channels of n-bits values.
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- See https://github.com/sporniket/seed-vhdl/wiki/k_channels_x_n_bits_demuxer_be
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
entity k_channels_x_n_bits_demuxer_be is
  generic
  (
    channel_count : positive := 2;
    channel_width : integer := 32
  );
  port
  (
    -- control signals
    rst : in hi; -- asynchronous reset : value is reset to «zero»
    clk : in hi; -- clock : on leading edge, the state is updated
    cs : in hi; -- chip select : when asserted at leading clock edge, input data is used
    oe : in hi; -- output enable : when asserted at leading clock edge, the output is updated

    -- input signals
    -- Inputs are used only when cs is asserted.
    x : in vc(channel_width - 1 downto 0); -- the muxed value
    x_latch : in hi ; -- when asserted, the channels that are not selected keep their value ; when negated, thoses channels are zeroed
    x_sel : in natural range 0 to channel_count - 1; -- The channel to select

    -- output signals
    -- Outputs are updated only when oe or rst are asserted.
    q : out vc(channel_count * channel_width - 1 downto 0); -- The concatenation of the k channels x(k-1) & ... & x(0)
    q_clk : out hi -- Pulse signaling an update from the output
  );
end k_channels_x_n_bits_demuxer_be;

architecture behavior of k_channels_x_n_bits_demuxer_be is
  constant index_msb_full : integer := channel_count * channel_width - 1;
  constant value_zero : vc(index_msb_full downto 0) := (others => '0');

  function update_value
  (
    reference_value : vc(index_msb_full downto 0);
    signal x : vc(channel_width - 1 downto 0);
    signal x_sel : natural range 0 to channel_count - 1
  )
  return vc
  is begin
    if 0 = x_sel then
      return reference_value(index_msb_full downto channel_width) & x;
    elsif channel_count - 1 = x_sel then
      return x & reference_value(index_msb_full - channel_width downto 0);
    else
      return reference_value(index_msb_full downto (x_sel + 1) * channel_width) & x & reference_value(x_sel * channel_width - 1 downto 0);
    end if;
  end update_value;

begin
  on_event : process (clk, rst)
    variable value : vc(index_msb_full downto 0) := value_zero;
    variable will_pulse : hi := hi_negated;
  begin
    if hi_asserted = rst then
      value := value_zero;
      q <= value;
      will_pulse := hi_negated;
      q_clk <= hi_negated;
    elsif hi_is_leading_edge(clk) then
      if hi_asserted = cs then
        will_pulse := hi_asserted;
        if hi_asserted = x_latch then
          value := update_value(value, x, x_sel);
        else
          value := update_value(value_zero, x, x_sel);
        end if;
      end if;
      if hi_asserted = oe then
        q <= value;
        if hi_asserted = will_pulse then
          q_clk <= hi_asserted ;
        end if;
        will_pulse := hi_negated;
      end if;
    elsif hi_is_trailing_edge(clk) then
      q_clk <= hi_negated;
    end if;
  end process on_event;
end behavior;
