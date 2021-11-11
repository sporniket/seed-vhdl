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
-- A data buffer.
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- See https://github.com/sporniket/seed-vhdl/wiki/n_bits_buffer_be
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
entity n_bits_buffer_be is
  generic
  (
    width : integer := 32
  ) ;
  port(
    -- control signals
    rst : in hi ; -- asynchronous reset : value is reset to «zero»
    clk : in hi ; -- clock : on leading edge, the state is updated
    cs : in hi ; -- chip select : when asserted at leading clock edge, input data is loaded
    oe : in hi ; -- output enable : when asserted at leading clock edge, the output is updated

    -- input signals
    -- Input are used only when cs is asserted.
    x : in vc(width - 1 downto 0) ; -- data to buffer

    -- -- output signals
    -- q : the next bit, starting from the most significant byte
    q : out vc(width - 1 downto 0) -- the buffered data
  );
end n_bits_buffer_be;

architecture structural of n_bits_buffer_be is
  signal in_x_select : natural range 0 to 0 := 0;
  signal in_x_strobe : hi := '1';
begin
  single_n_bit_register_set: entity sporniket.k_x_n_bits_register_set_be
    generic map
    (
      register_count => 1,
      register_width => width
    )
    port map
    (
      -- inputs
      cs => cs,
      oe => oe,
      clk => clk,
      rst => rst,

      x_select => in_x_select,
      x_strobe => in_x_strobe,
      x_value => x,

      -- outputs
      q => q
    )
  ;
end structural ;
