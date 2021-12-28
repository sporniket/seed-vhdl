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
--- A counter with a given width.
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- See https://github.com/sporniket/seed-vhdl/wiki/n_bits_counter_be
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
entity n_bits_counter_be is
  generic
  (
    width : integer := 32
  ) ;
  port
  (
    -- control signals
    rst : in hi ; -- asynchronous reset : value is reset to «zero»
    clk : in hi ; -- clock : on leading edge, the state is updated
    cs : in hi ; -- chip select : when asserted at leading clock edge, internal counter is running
    oe : in hi ; -- output enable : when asserted at leading clock edge, the output is updated

    -- input signals
    -- Inputs are used only when cs is asserted.
    -- None

    -- output signals
    -- Outputs are updated only when oe or rst are asserted.
    q : out vc(width - 1 downto 0); -- the value of the counter
    q_clk : out hi -- Pulse signaling an update from the output
  );
end n_bits_counter_be;

architecture behavior of n_bits_counter_be is
  constant max_value : integer := (2**width) ;
  signal int_clk: hi := hi_negated; -- the internal pulse to generete q_clk
begin
  -- q_clk generation
  delay: entity sporniket.single_bit_echo
    port map(
      x => int_clk,
      q => q_clk
    );

  -- main process
  on_event:process(clk,rst)
    variable value : integer := 0;
    variable will_pulse : hi := hi_negated;
  begin
    if hi_asserted = rst then
      value := 0;
      q <= std_logic_vector(to_unsigned(value, q'length));
      will_pulse := hi_negated;
      int_clk <= hi_negated;
    elsif hi_is_leading_edge(clk) then
      if hi_asserted = cs then
        will_pulse := hi_asserted;
        value := value + 1 ;
        if (value >= max_value) then
          value := 0 ;
        end if;
      end if;
      if hi_asserted = oe then
        q <= std_logic_vector(to_unsigned(value, q'length));
        if hi_asserted = will_pulse then
          int_clk <= hi_asserted ;
        end if;
        will_pulse := hi_negated;
      end if;
    elsif hi_is_trailing_edge(clk) then
      int_clk <= hi_negated;
    end if;
  end process on_event;
end behavior ;
