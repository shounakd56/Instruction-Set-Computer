library IEEE;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity alu is
    --TODO add input signal to prevent zeroflag,carryflag if pc update from modification.
	port(state:in std_logic_vector(3 downto 0);
        inp1,inp2: in std_logic_vector(15 downto 0);
		  cin: in std_logic;
		  selector: in std_logic_vector(1 downto 0);
		  outp: out std_logic_vector(15 downto 0);
		  cout: out std_logic;
		  flag: out std_logic);
end entity;

architecture behave of alu is
    component sixteenbitadder is
		port(xin,yin: in std_logic_vector(15 downto 0);
		  cin: in std_logic;
		  sum: out std_logic_vector(15 downto 0);
		  cout: out std_logic);
	end component;
	
    signal sum1out:std_logic_vector(15 downto 0);
    signal sumout:std_logic_vector(15 downto 0);
	 
begin
    adder: sixteenbitadder port map(xin=>inp1,yin=>inp2,cin=>cin,sum=>sumout,cout=>cout);
	 
    process(inp1,inp2,cin,selector,sumout)
    begin
        if(selector = "00") then
            sum1out<=sumout;
        elsif(selector = "01") then
            sum1out<=(inp1 nand inp2);
        elsif(selector = "10") then
            sum1out<= (inp1 xor inp2);
        end if;
	end process;
	
process(sum1out)
    begin
        outp<=sum1out;
        if(sum1out = "0000000000000000") then
            flag<='1';
        else
            flag<='0';
        end if;
    end process;
end behave;