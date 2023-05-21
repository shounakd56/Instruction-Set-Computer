library ieee;
use ieee.std_logic_1164.all;

entity sixteenbitadder is
	port(xin,yin: in std_logic_vector(15 downto 0);
		  cin: in std_logic;
		  sum: out std_logic_vector(15 downto 0);
		  cout: out std_logic);
end entity;


architecture sixteenbitadder of sixteenbitadder is
	component fulladder is
		port(a,b,cin: in std_logic;
		     cout,sum: out std_logic);
end component;
signal temp_c: std_logic_vector(15 downto 0);
	
begin
	FA1: fulladder port map(xin(0), yin(0),cin,temp_c(1), sum(0));
	FA2: fulladder port map(xin(1), yin(1),temp_c(1),temp_c(2), sum(1));
	FA3: fulladder port map(xin(2), yin(2),temp_c(2),temp_c(3), sum(2));
	FA4: fulladder port map(xin(3), yin(3),temp_c(3),temp_c(4), sum(3));
	FA5: fulladder port map(xin(4), yin(4),temp_c(4),temp_c(5), sum(4));
	FA6: fulladder port map(xin(5), yin(5),temp_c(5),temp_c(6), sum(5));
	FA7: fulladder port map(xin(6), yin(6),temp_c(6),temp_c(7), sum(6));
	FA8: fulladder port map(xin(7), yin(7),temp_c(7),temp_c(8), sum(7));
	FA9: fulladder port map(xin(8), yin(8),temp_c(8),temp_c(9), sum(8));
	FA10: fulladder port map(xin(9), yin(9),temp_c(9),temp_c(10), sum(9));
	FA11: fulladder port map(xin(10), yin(10),temp_c(10),temp_c(11), sum(10));
	FA12: fulladder port map(xin(11), yin(11),temp_c(11),temp_c(12), sum(11));
	FA13: fulladder port map(xin(12), yin(12),temp_c(12),temp_c(13), sum(12));
	FA14: fulladder port map(xin(13), yin(13),temp_c(13),temp_c(14), sum(13));
	FA15: fulladder port map(xin(14), yin(14),temp_c(14),temp_c(15), sum(14));
	FA16: fulladder port map(xin(15), yin(15),temp_c(15),cout, sum(15));
end sixteenbitadder;