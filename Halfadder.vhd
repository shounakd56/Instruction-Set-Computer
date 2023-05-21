library IEEE;
use IEEE.std_logic_1164.all;

entity HalfAdder is
port (in1, in2: in std_logic;
      sum, cout: out std_logic);
end entity;

architecture halfadder of halfadder is
begin
    cout<=in1 and in2;
    sum<= in1 xor in2;    
end architecture halfadder;