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
-- See https://github.com/sporniket/seed-vhdl/wiki/n_bits_deserializer_be_msb
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
entity n_bits_deserializer_be_msb is
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
    x : in hi ; -- data to serialize

    -- output signals
    q : out vc(width - 1 downto 0) ; -- the next bit, starting from the MSB
    q_bar : out vc(width - 1 downto 0) ; -- the negated value of `q`
    q_clk : out hi ; -- Pulse signaling an update from the output
    q_strobe : out hi -- output strobe, asserted when `q` is the LSB (Least Significant Bit)

  );
end n_bits_deserializer_be_msb;

architecture structural of n_bits_deserializer_be_msb is
begin
  single_bit_slicer: entity sporniket.n_x_m_bits_joiner_be_msb
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

      x(0) => x,

      -- outputs
      q => q,
      q_bar => q_bar,
      q_clk => q_clk,
      q_strobe => q_strobe
    )
  ;
end structural ;
