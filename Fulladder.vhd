library IEEE;
use IEEE.std_logic_1164.all;
entity FullAdder is
port (a, b, cin : in std_logic;
      sum, cout: out std_logic);

end entity;
architecture fulladder of fulladder is
    signal sum1, c1,c2:std_logic;
    
    component halfadder
        port (in1, in2: in std_logic;
              sum, cout: out std_logic);
    end component;
begin
    ha1:halfadder
        port map(in1=>a,in2=>b,sum=>sum1,cout=>c1);
    ha2:halfadder
        port map(in1=>cin,in2=>sum1,sum=>sum,cout=>c2);
    cout<= c1 or c2 ;
    
    
end architecture fulladder;