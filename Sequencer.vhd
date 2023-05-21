library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all; 
library ieee;
use ieee.numeric_std.all; 

entity sequencer is
	port(innum : in std_logic_vector (3 downto 0);
		  outnum: out std_logic_vector(3 downto 0)
		);
end entity;

architecture behave of sequencer is

begin
    process(innum)
    begin
    case innum is
	     when "0101" => outnum<="0110";
        when "0110" => outnum<="0111";
        when "0111" => outnum<="1000";
        when "1000" => outnum<="0000";
        when "0000" => outnum<="0001";
        when "0001" => outnum<="0010";
        when "0010" => outnum<="0011";
        when "0011" => outnum<="0100";
        when "0100" => outnum<="0101";
        
		  when others => report "udb in seq";
		 end case;
    end process;
end architecture behave;