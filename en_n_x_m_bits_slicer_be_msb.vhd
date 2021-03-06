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
-- Serialize a N×M bits value into a sequence of N values of M bits, starting
-- from the Most Significant Slice (MSS). When M = 1, this is a serializer.
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- See https://github.com/sporniket/seed-vhdl/wiki/n_x_m_bits_slicer_be_msb
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
entity n_x_m_bits_slicer_be_msb is
  generic
  (
    slice_count : integer := 32;
    slice_width : integer := 1
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
    x : in vc(slice_count * slice_width - 1 downto 0); -- data to slice
    x_strobe : in hi; -- data strobe : when asserted at leading clock edge, the register loads its value from x; when oe is asserted, the MSS is available at q

    -- output signals
    -- Outputs are updated only when oe or rst are asserted.
    q : out vc(slice_width - 1 downto 0); -- the next slice, starting from the MSS
    q_bar : out vc(slice_width - 1 downto 0); -- the negated value of q
    q_clk : out hi ; -- Pulse signaling an update from the output
    q_strobe : out hi -- output strobe, asserted when q is the LSS (Least Significant Slice)

  );
end n_x_m_bits_slicer_be_msb;

architecture behavior of n_x_m_bits_slicer_be_msb is
  constant index_msb_full : integer := slice_count * slice_width - 1;
  constant index_msb_shift : integer := index_msb_full - slice_width;
  constant index_msb_strober : integer := slice_count - 1;
  constant index_msb_slice : integer := slice_width - 1;
  constant value_zero : vc(index_msb_full downto 0) := (others => '0');
  constant suffix_shift : vc(index_msb_slice downto 0) := (others => '0');
  constant init_value_of_bit_strober : vc(index_msb_strober downto 0) := std_logic_vector(to_unsigned(1, slice_count));
  signal int_clk: hi := hi_negated; -- the internal pulse to generete q_clk

  procedure send_to_output(
    variable source_value : in vc(index_msb_full downto 0);
    variable source_strober : in vc(index_msb_strober downto 0);
    signal recipient_q : out vc(index_msb_slice downto 0);
    signal recipient_q_bar : out vc(index_msb_slice downto 0);
    signal recipient_strober : out hi
  ) is
  begin
    recipient_q <= source_value(index_msb_full downto index_msb_shift + 1);
    recipient_q_bar <= not source_value(index_msb_full downto index_msb_shift + 1);
    recipient_strober <= source_strober(index_msb_strober);
  end procedure;

begin
  -- q_clk generation
  delay: entity sporniket.single_bit_echo
    port map(
      x => int_clk,
      q => q_clk
    );

  -- main process
  on_event : process (clk, rst)
    variable value : vc(index_msb_full downto 0) := value_zero;
    variable bit_strober : vc(index_msb_strober downto 0) := init_value_of_bit_strober;
    variable will_pulse : hi := hi_negated;
  begin
    if hi_asserted = rst then
      value := value_zero;
      bit_strober := init_value_of_bit_strober;
      send_to_output(value, bit_strober, q, q_bar, q_strobe);
      will_pulse := hi_negated;
      int_clk <= hi_negated;
    elsif hi_is_leading_edge(clk) then
      if hi_asserted = cs then
        will_pulse := hi_asserted;
        if hi_asserted = x_strobe then
          value := x;
          bit_strober := init_value_of_bit_strober;
        else
          value := value(index_msb_shift downto 0) & suffix_shift;
          bit_strober := bit_strober(index_msb_strober - 1 downto 0) & '0';
        end if;
      end if;
      if hi_asserted = oe then
        send_to_output(value, bit_strober, q, q_bar, q_strobe);
        if hi_asserted = will_pulse then
          int_clk <= hi_asserted ;
        end if;
        will_pulse := hi_negated;
      end if;
    elsif hi_is_trailing_edge(clk) then
      int_clk <= hi_negated;
    end if;
  end process on_event;
end behavior;
