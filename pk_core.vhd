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
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the Creative Commons CC0 License
-- for more details.
--
-- You should have received a copy of the Creative Commons CC0 License along
-- with this project. If not, see 
-- <http://creativecommons.org/publicdomain/zero/1.0/>.
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package core is
  -- normal (active HIgh) logic
  subtype hi is std_logic ;
  constant hi_asserted : hi := '1' ;
  constant hi_negated : hi := '0' ;
  function hi_is_leading_edge (signal s : std_ulogic) return boolean ;
  function hi_is_trailing_edge (signal s : std_ulogic) return boolean ;
  -- active LOw logic
  subtype lo is std_logic ;
  constant lo_asserted : lo := '0' ;
  constant lo_negated : lo := '1' ;
  function lo_is_leading_edge (signal s : std_ulogic) return boolean ;
  function lo_is_trailing_edge (signal s : std_ulogic) return boolean ;

  -- std_logic_vector short hand
  subtype vc is std_logic_vector ;
end core;

package body core is
  function hi_is_leading_edge (signal s : std_ulogic) return boolean is
  begin
    return rising_edge(s) ;
  end hi_is_leading_edge;

  function hi_is_trailing_edge (signal s : std_ulogic) return boolean is
  begin
    return falling_edge(s) ;
  end hi_is_trailing_edge;

  function lo_is_leading_edge (signal s : std_ulogic) return boolean is
  begin
    return falling_edge(s) ;
  end lo_is_leading_edge;

  function lo_is_trailing_edge (signal s : std_ulogic) return boolean is
  begin
    return rising_edge(s) ;
  end lo_is_trailing_edge;
end core ;
