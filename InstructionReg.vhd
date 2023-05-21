library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity InstrReg is
	port(
        opcode: out std_logic_vector(3 downto 0);
        input: in std_logic_vector(15 downto 0);
		  irw: in std_logic;
		  rega: out std_logic_vector(2 downto 0);
        regb: out std_logic_vector(2 downto 0);
        regc: out std_logic_vector(2 downto 0);
        cz: out std_logic_vector(1 downto 0);   --- carry flag 
        immed6: out std_logic_vector(5 downto 0);
        immed9: out std_logic_vector(8 downto 0);
        immed8: out std_logic_vector(7 downto 0) 
        );
		  
end entity;


architecture behave of InstrReg is
    signal instruction:std_logic_vector(15 downto 0):="0000000000000000"; ---initialize

begin
    process(irw,input)
        begin
            if(irw = '1') then
                instruction<=input;
            else
            end if;
    end process;
    process(instruction)
        begin
            opcode <= instruction(15 downto 12);
            rega <= instruction(11 downto 9);
            regb <= instruction(8 downto 6);
            regc <= instruction(5 downto 3);
            immed6 <= instruction(5 downto 0);
				immed9 <= instruction(8 downto 0);
            immed8 <= instruction(7 downto 0);
            cz <= instruction(1 downto 0);
            
    end process;
end behave;