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
-- A set of K registers, each register can store a N-bits value.
-- When K = 1, this is a buffer.
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- See https://github.com/sporniket/seed-vhdl/wiki/k_x_n_bits_register_set_be
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
entity k_x_n_bits_register_set_be is
  generic
  (
    register_count : positive := 8;
    register_width : integer := 32
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
    x_select : in natural range 0 to register_count - 1; -- select the register to use
    x_strobe : in hi; -- data strobe, asserted to load x_value into the selected register
    x_value : in vc(register_width - 1 downto 0); -- the value to load into the selected register

    -- output signals
    -- Outputs are updated only when oe or rst are asserted.
    q : out vc(register_width - 1 downto 0); -- the value of the selected register
    q_clk : out hi -- Pulse signaling an update from the output

  );
end k_x_n_bits_register_set_be;

architecture behavior of k_x_n_bits_register_set_be is
  constant index_msb_full : integer := register_width - 1;
  constant value_zero : vc(index_msb_full downto 0) := (others => '0');
  signal int_clk: hi := hi_negated; -- the internal pulse to generete q_clk
begin
  -- q_clk generation
  delay: entity sporniket.single_bit_echo
    port map(
      x => int_clk,
      q => q_clk
    );

  -- main process
  on_event : process (clk, rst)
    type type_of_register_set is array (natural range 0 to register_count - 1) of vc(index_msb_full downto 0);
    constant set_of_value_zero : type_of_register_set := (others=>(value_zero));
    variable values : type_of_register_set := set_of_value_zero ;
    variable value_selected : vc(index_msb_full downto 0) := value_zero;
    variable will_pulse : hi := hi_negated;
  begin
    if hi_asserted = rst then
      values := set_of_value_zero;
      value_selected := value_zero;
      q <= value_selected;
      will_pulse := hi_negated;
      int_clk <= hi_negated;
    elsif hi_is_leading_edge(clk) then
      if hi_asserted = cs then
        will_pulse := hi_asserted;
        if hi_asserted = x_strobe then
          values(x_select) := x_value;
        end if;
        value_selected := values(x_select);
      end if;
      if hi_asserted = oe then
        q <= value_selected;
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
