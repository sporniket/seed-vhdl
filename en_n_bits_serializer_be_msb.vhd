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
--- A.k.a shift register, transform a given value into it's sequence of bits, starting from the Most Significant Bit (MSB).
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- See https://github.com/sporniket/seed-vhdl/wiki/n_bits_serializer_be_msb
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
entity n_bits_serializer_be_msb is
  generic
  (
    width : integer := 32
  ) ;
  port(
    -- control signals
    rst : in hi ; -- asynchronous reset : value is reset to «zero»
    clk : in hi ; -- on leading edge, the state is updated
    cs : in hi ; -- chip select : when asserted at leading clock edge, input data is used
    oe : in hi ; -- output enable : when asserted at leading clock edge, the output is updated

    -- input signals
    x : in vc(width - 1 downto 0) ; -- data to serialize
    x_strobe : in hi ; -- data strobe : when asserted at leading clock edge, the register loads its value from `x`, and outputs the MSB is to `q`

    -- output signals
    q : out hi ; -- the next bit, starting from the MSB
    q_bar : out lo ; -- the negated value of `q`
    q_strobe : out hi -- output strobe, asserted when `q` is the LSB (Least Significant Bit)

  );
end n_bits_serializer_be_msb;

architecture structural of n_bits_serializer_be_msb is
begin
  single_bit_slicer: entity sporniket.n_x_m_bits_slicer_be_msb
    generic map (
      slice_count => width,
      slice_width => 1
    )
    port map (
      -- inputs
      cs => cs,
      oe => oe,
      clk => clk,
      rst => rst,

      x_strobe => x_strobe,
      x => x,

      -- outputs
      q(0) => q,
      q_bar(0) => q_bar,
      q_strobe => q_strobe
    )
  ;
end structural ;
