-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- Copyright (C) 2021 David SPORN.
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- This file is part of @TERM{Project}.
--
-- @TERM{Project} is free hardware design : you can redistribute it and/or modify it under the terms of the Lesser GNU General Public License as
-- published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
--
-- @TERM{Project} is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the Lesser GNU General Public License for more details.
--
-- You should have received a copy of the Lesser GNU General Public License along with Foobar.  If not, see <https://www.gnu.org/licenses/>.
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
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
