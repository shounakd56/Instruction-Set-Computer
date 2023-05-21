library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all; 
library ieee;
use ieee.numeric_std.all; 
entity Memory is 
  port (state : in std_logic_vector(3 downto 0);
		  init: in std_logic;  
		  mwrite: in std_logic;
		  mread: in std_logic;      
        din: in std_logic_vector(15 downto 0);
	     dataPointer: in std_logic_vector(7 downto 0);	  
        dout: out std_logic_vector(15 downto 0));  
end entity; 

architecture membehave of memory is 
	type RAM is array(0 to ((256)-1)) of std_logic_vector(15 downto 0);
	signal store_ram: RAM;
	begin
	process(init,mread,mwrite,dataPointer,store_ram)
		begin 
			report "dataPointer:"&integer'image(to_integer(unsigned(dataPointer)));
			if (init = '1') then
				store_ram(0) <= "0000000101100000"; -- ADD
				store_ram(1) <= "0000000101100010"; -- ADC
				store_ram(2) <= "0000000101100001"; -- ADZ
				store_ram(3) <= "0001000101100110"; -- ADDI
				store_ram(4) <= "0010000101100000"; -- NDU
				store_ram(5) <= "0010000101100010"; -- NDC
				store_ram(6) <= "0010000101100001"; -- NDZ
				store_ram(7) <= "0011000101100110"; -- LHI
				store_ram(8) <= "0100000101100110"; -- LW
				store_ram(9) <= "0101000101100110"; -- SW
				store_ram(10) <= "0110000001100000"; -- LM
				store_ram(11) <= "0111000001100010"; -- SM
				store_ram(12) <= "1100000101100001"; -- BEQ
				store_ram(13) <= "1000000101100110"; -- JAL
				store_ram(14) <= "1001000101000000"; -- JLR
				

			elsif (mread = '1') then
				dout <= store_ram(to_integer(unsigned(dataPointer)));
			end if;
			if (mwrite = '1') then
				store_ram(to_integer(unsigned(dataPointer))) <= din;
			end if;
	end process; 
	end membehave;