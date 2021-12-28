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
use sporniket.single_bit_echo; -- seems required with ISE when there are multiple architectures

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- See https://github.com/sporniket/seed-vhdl/wiki/single_bit_echo
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
entity single_bit_echo_behavior_test_suite is
end single_bit_echo_behavior_test_suite;

architecture test_suite of single_bit_echo_behavior_test_suite is
  -- declare record type
  type test_vector is record
    x : hi ;
    q1 : hi ; -- q at the same time of x change
    q2 : hi ; -- q after 1ns has elapsed
  end record;

  type test_vector_array is array (natural range <>) of test_vector;
  constant test_vectors : test_vector_array := (
    -- No clock pulse
    -- | x | q1 | q2 |
    ('1', '0', '1'),
    ('1', '1', '1'),
    ('0', '1', '0'),
    ('0', '0', '0')
  );

  -- test signals
  -- control

  -- inputs
  signal in_x : hi ;

  -- outputs
  signal out_q : hi ;

begin
  -- explicit selection of the simulation entity
  dut : entity sporniket.single_bit_echo(simulation)
    port map
    (
      -- inputs
      x => in_x,

      -- outputs
      q => out_q
    );

  execute:process
  begin
    wait for 1 ns;
    report "Testing operation state...";

    for i in test_vectors'range loop
      -- prepare
      in_x <= test_vectors(i).x ;

      -- verify immediate state
      assert out_q = test_vectors(i).q1
      report "test_vector " & integer'image(i) & " failed " & "got no delay !"
      severity failure;

      -- propagation delay
      wait for 1 ns;

      -- verify delayed state
      assert out_q = test_vectors(i).q1
      report "test_vector " & integer'image(i) & " failed " & "got no delay !"
      severity failure;

      -- wait a bit
      wait for 1 ns;

    end loop;
    report "Done." ;
    finish ;
  end process execute ;
end test_suite ;
