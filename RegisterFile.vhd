library std;
library ieee;
use std.standard.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity registerfile is    
  port(
		state : in std_logic_vector(3 downto 0);
		din_m : in std_logic_vector(15 downto 0);  
	  	registera : in std_logic_vector(2 downto 0);
		registerb	: in std_logic_vector(2 downto 0);
		registerselector : in std_logic_vector(2 downto 0);
		registerwrite : in std_logic;
		douta : out std_logic_vector(15 downto 0);
		doutb : out std_logic_vector(15 downto 0) );
end entity;

architecture behave of registerfile is

type t_Memory is array (0 to 7) of std_logic_vector(15 downto 0);
signal data : t_Memory := (0=>(4=>'1',others=>'0'),1=>(2=>'1',others=>'0'),2=>(1=>'1',others=>'0'),6=>(2=>'1',1=>'1',others=>'0'),others => (others => '0'));

begin
	process(state,registera,registerb,registerwrite,registerselector,din_m)
	begin 
		for x in 0 to 7 loop
			end loop;
			if(registerwrite = '1') then
				--transfer the data from the register to
				if(registerselector = "111") then
					data(7) <= din_m;
				elsif(registerselector = "110") then
					data(6) <= din_m;
				elsif(registerselector = "101") then
					data(5) <= din_m;
				elsif(registerselector = "100") then
					data(4) <= din_m;
				elsif(registerselector = "011") then
					data(3) <= din_m;
				elsif(registerselector = "010") then
					data(2) <= din_m;
				elsif(registerselector = "001") then
					data(1) <= din_m;
				elsif(registerselector = "000") then
					data(0) <= din_m;
				end if;
			end if;
			
			if(registera = "111") then
					douta <= data(7);
			elsif(registera = "110") then
					douta <= data(6);
			elsif(registera = "101") then
					douta <= data(5);
			elsif(registera = "100") then
					douta <= data(4);
			elsif(registera = "011") then
					douta <= data(3);
			elsif(registera = "010") then
					douta <= data(2);
			elsif(registera = "001") then
					douta <= data(1);
			elsif(registera = "000") then
					douta <= data(0);
			end if;

			if(registerb = "111") then
					doutb <= data(7);
			elsif(registerb = "110") then
					doutb <= data(6);
			elsif(registerb = "101") then
					doutb <= data(5);
			elsif(registerb = "100") then
					doutb <= data(4);
			elsif(registerb = "011") then
					doutb <= data(3);
			elsif(registerb = "010") then
					doutb <= data(2);
			elsif(registerb = "001") then
					doutb <= data(1);
			elsif(registerb = "000") then
					doutb <= data(0);
			end if;	
	end process;
end behave;