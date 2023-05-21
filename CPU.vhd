--EE224-Project-CPU

--Team
--Vinay Sutar(21d070078) 
--Shounak Das(21d070068) 
--Aditya Anand(21d070007) 
--Parth Arora(21d070047)
--Daksh Pakal(210070023)


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity CPU is
	 port (
		  clk:in std_logic;
		  outstates:out std_logic_vector(7 downto 0)
	 );
end entity CPU;
architecture rtl of CPU is
---constants state initialisation
	constant ST0_INIT:std_logic_vector(3 downto 0)	:="0000"; ---Initialize
	constant ST1_HK:std_logic_vector(3 downto 0)	:="0001"; ---Read
	constant ST2_IF:std_logic_vector(3 downto 0)	:="1001"; ---instruction fetch
	constant ST3_UPD:std_logic_vector(3 downto 0)	:="0010"; ---Update
	constant ST4_WBTR:std_logic_vector(3 downto 0)  :="1010"; ---Jump and link to register
	constant ST5_LMSM:std_logic_vector(3 downto 0)	:="0100"; ---Load multiple and store multiple
	constant ST6_RDLM:std_logic_vector(3 downto 0)	:="0101"; ---Read state of load multiple
	constant ST7_SM1:std_logic_vector(3 downto 0)	:="0110"; ---store multiple
	constant ST8_LMWB:std_logic_vector(3 downto 0)	:="0111"; ---Write back state of load multiple
	constant ST9_SMW:std_logic_vector(3 downto 0)	:="1000"; ---Write state of store multiple
	constant ST10_JLR2:std_logic_vector(3 downto 0)  :="0011"; ---General state for write back
	constant ST11_EXE:std_logic_vector(3 downto 0)  :="1011"; ---Execute
	constant ST12_MEMA:std_logic_vector(3 downto 0) :="1100"; ---Memory Access
	constant ST13_CPC:std_logic_vector(3 downto 0)  :="1101"; ---Change program counter

---components
 component registerfile is 
 port(
	state : in std_logic_vector(3 downto 0);
	din_m : in std_logic_vector(15 downto 0);  
	registera : in std_logic_vector(2 downto 0);
	registerb	: in std_logic_vector(2 downto 0);
	registerselector : in std_logic_vector(2 downto 0);
	registerwrite : in std_logic;
	douta : out std_logic_vector(15 downto 0);
	doutb : out std_logic_vector(15 downto 0) );
 end component;
 
 component alu is
	  port(state:in std_logic_vector(3 downto 0);
			 inp1,inp2: in std_logic_vector(15 downto 0);
			 cin: in std_logic;
			 selector: in std_logic_vector(1 downto 0);
			 outp: out std_logic_vector(15 downto 0);
			 cout: out std_logic;
			 flag: out std_logic);
 end component;
 
 component memory is 
	  port (state : in std_logic_vector(3 downto 0);
			  init: in std_logic;  
			  mread  : in std_logic;   
			  mwrite  : in std_logic;
			  dataPointer   : in std_logic_vector(7 downto 0);   
			  din  : in std_logic_vector(15 downto 0);   
			  dout  : out std_logic_vector(15 downto 0));  
	end component;
	
 component InstrReg is 
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
 end component;
 
 component sequencer is
	  port(innum : in std_logic_vector (3 downto 0);
			 outnum: out std_logic_vector(3 downto 0)
	  );
 end component;
 
--- initialization of opcodes
constant OC_ADDR:std_logic_vector(3 downto 0)	:="0000"; ---Includes the first 3 instructions
constant OC_ADDI:std_logic_vector(3 downto 0)	:="0001";
constant OC_NND:std_logic_vector(3 downto 0)	   :="0010";
constant OC_LHI:std_logic_vector(3 downto 0)	   :="0011";
constant OC_LW:std_logic_vector(3 downto 0)	   :="0100";
constant OC_SW:std_logic_vector(3 downto 0)     :="0101";
constant OC_LM:std_logic_vector(3 downto 0)     :="0110";
constant OC_SM:std_logic_vector(3 downto 0)     :="0111"; 
constant OC_JAL:std_logic_vector(3 downto 0)	   :="1000";
constant OC_JLR:std_logic_vector(3 downto 0)	   :="1001";
constant OC_BEQ:std_logic_vector(3 downto 0)	   :="1100";
constant OC_TER:std_logic_vector(3 downto 0)    :="0100";

---
	 signal state:std_logic_vector(3 downto 0):= ST0_INIT; --start from the initial state
	 signal nextState:std_logic_vector(3 downto 0):= ST1_HK; --1st state
---memory signals 
	 signal memInit,memRead,memWrite:std_logic;
	 signal memAddr:std_logic_vector(7 downto 0);
	 signal memDataIn,memDataOut:std_logic_vector(15 downto 0);
	 signal memInMux:std_logic;
	 signal memOutDemux:std_logic;
	 signal tempMemData:std_logic_vector(15 downto 0);
---
---instr reg signals
	 signal tempInstr:std_logic_vector(15 downto 0);
	 signal irW:std_logic;
	 signal opCode:std_logic_vector(3 downto 0);
	 signal imm6:std_logic_vector(5 downto 0);
	 signal regsela:std_logic_vector(2 downto 0);
	 signal regselb:std_logic_vector(2 downto 0); 
	 signal regselc:std_logic_vector(2 downto 0); 
	 signal czVal:std_logic_vector(1 downto 0);
	 signal imm9:std_logic_vector(8 downto 0);
	 signal imm8:std_logic_vector(7 downto 0);
	 signal imm6_16,imm9_16low,imm9_16high,imm8_16:std_logic_vector(15 downto 0);
---
---register file signals
	 signal rfDataIn,rfDataOut1,rfDataOut2:std_logic_vector(15 downto 0);
	 signal rfWrite:std_logic:='0';
	 signal rfSel1,rfSel2,rfSelW:std_logic_vector(2 downto 0);
---misc signals	
	 signal Data1_temp:std_logic_vector(15 downto 0);
	 signal Data2_temp:std_logic_vector(15 downto 0);
	 signal prevPC:std_logic_vector(15 downto 0);
	 signal index:std_logic_vector(15 downto 0):=(others=>'0');
	 signal current_load:std_logic:='0';
	 signal lmsmAddr:std_logic_vector(15 downto 0);
---
---aLU signals
	 signal aluZeroFlag,aluCarryFlag:std_logic;
	 signal zeroFlagMux:std_logic:='0';
	 signal zeroFlag:std_logic;
	 signal lwZeroFlag:std_logic;
	 signal aluIn1,aluIn2,aluOut:std_logic_vector(15 downto 0);
	 signal aluCin:std_logic:='0'; --initialize
	 signal aluSel:std_logic_vector(1 downto 0);
	 signal aluMux1:std_logic_vector(1 downto 0):= "00";
	 signal aluMux2:std_logic_vector(2 downto 0);
---
---sequencer signals
	 signal inRegNum,outRegNum:std_logic_vector(3 downto 0);
---
begin
	 mem:memory port map(state=>state,init=>memInit,mread=>memRead,mwrite=>memWrite,dataPointer=>memAddr,din=>memDataIn,dout=>memDataOut);
	 rf:registerfile port map(state=>state,din_m=>rfDataIn,registera=>rfSel1,registerb=>rfSel2, registerselector=>rfSelW,registerwrite=>rfWrite,douta=>rfDataOut1,doutb=>rfDataOut2);
	 aluInst:ALU port map(state=>state,inp1=>aluIn1,inp2=>aluIn2,cin=>aluCin,selector=>aluSel,outp=>aluOut,cout=>aluCarryFlag,flag=>aluZeroFlag);
	 irInst:InstrReg port map(irw=>irw,input=>tempInstr,opcode=>opCode,immed6=>imm6,immed8=>imm8,immed9=>imm9,rega=>regsela,regb=>regselb,regc=>regselc,cz=>czVal);
	 seq:sequencer port map(innum=>inRegNum,outnum=>outRegNum);
	 process(clk)
		  begin
				if(rising_edge(clk)) then -- at every rising edge of clock state changes
					 state<=nextState;
				end if;
	 end process;
	 process(state)
		  begin
				if(state = ST0_INIT) then --1st state
					 --initialize memory contents
					 memInit<='1'; 
					 memRead<='0';  --no memory read
					 memWrite<='0'; --no memory write
					 ---initialize pc to 0:
					 rfSelW<="111";
					 rfDataIn<=(others=>'0');
					 rfWrite<='1';  --register is edited
					 nextState<=ST1_HK;
				elsif (state = ST1_HK) then --2nd state
					 memInit<='0'; 
					 aluMux1<="00";
					 memRead<='1';  --memory is read
					 memWrite<='0'; --no memory write
					 rfWrite<='0';
					 rfSel1<="111";
					 memInMux<='0';
					 nextState<=ST2_IF;
				elsif (state = ST2_IF) then --3rd state
					 prevPC<=rfDataOut1;
					 aluMux2<="001";
					 aluSel<="00";
					 irw<='1';
					 tempInstr<=memDataOut;
					 nextState<=ST3_UPD;
				elsif (state=ST3_UPD) then --4th state
					 rfSelW<="111";
					 rfDataIn<=aluOut;
					 rfWrite<='1';
					 nextState<=ST11_EXE;
				elsif(state = ST11_EXE) then --12th state
					 if(opCode = OC_ADDR) then --depends on the opcode of the instruction
						  rfWrite<='0';
						  rfSel1<=regsela;
						  rfSel2<=regselb;
						  rfSelW<=regselc;
						  aluSel<="00";--addition selected
						  if(czVal = "00") then
								nextState<=ST4_WBTR;--last state
								aluMux2<="000";--rfDataOut2 goes into alu
						  elsif (czVal = "01" and aluZeroFlag = '1') then
								nextState<=ST4_WBTR;--last state
								aluMux2<="000";--rfDataOut2 goes into alu
						  elsif (czVal = "10" and aluCarryFlag = '1') then
								nextState<=ST4_WBTR;
								aluMux2<="000";--rfDataOut2 goes into alu
						  else
								nextState<=ST1_HK; --if cz value is as desired then the state changes to 5th or goes back to 2nd state
						  end if;
					 elsif (opCode = OC_ADDI) then 
						  rfWrite<='0';
						  rfSel1<=regsela;
						  rfSelW<=regselb;
						  aluMux2<="011";
						  aluSel<="00";
						  nextState<=ST4_WBTR; --5th state
					 elsif (opCode = OC_NND) then
						  rfWrite<='0';
						  rfSel1<=regsela;
						  rfSel2<=regselb;
						  rfSelW<=regselc;
						  aluSel<="01";--nand selected
						  aluMux2<="000";
						  if(czVal = "00") then
								nextState<=ST4_WBTR;--last state
						  elsif (czVal = "01" and aluZeroFlag = '1') then
								nextState<=ST4_WBTR;--last state
						  elsif (czVal = "10" and aluCarryFlag = '1') then
								nextState<=ST4_WBTR;
						  else
								nextState<=ST1_HK;
						  end if;
						  nextState<=ST4_WBTR;
					 elsif (opCode = OC_LHI) then
						  rfSelW<=regsela;
						  rfDataIn<=imm9_16high;
						  rfWrite<='1';
						  nextState<=ST1_HK;
					 elsif (opCode = OC_LW) then
						  rfSelW<=regsela;
						  rfSel1<=regselb;
						  aluMux2<="011";--imm6
						  aluSel<="00";
						  memInMux<='1';
						  nextState<=ST12_MEMA; --13th state
					 elsif (opCode = OC_SW) then
						  rfSel1<=regselb;--send to alu;
						  rfSel2<=regsela;
						  aluMux2<="011";--imm6;
						  aluSel<="00";
						  memInMux<='1';
						  nextState<=ST12_MEMA;
					 elsif (opCode = OC_LM) then
						  aluMux1<="00";
						  rfSel1<=regsela;
						  inRegNum<="1000";---initialize outnum to 0;
						  current_load<='0';
						  nextState<=ST5_LMSM;
					 elsif (opCode = OC_SM) then
						  aluMux1<="00";
						  rfSel1<=regsela;
						  inRegNum<="1000";---initialize outnum to 0;
						  current_load<='0';
						  nextState<=ST5_LMSM;
					 elsif (opCode = OC_BEQ) then
						  aluMux1<="10";
						  aluMux2<="011";
						  aluSel<="00";
						  rfSel1<=regsela;
						  rfSel2<=regselb;
						  nextState<=ST13_CPC; --14th state
					 elsif (opCode = OC_JAL) then
						  aluMux1<="10";
						  aluMux2<="100";--alu gets prevpc and 9imm_16low
						  aluSel<="00";
						  rfSel1<="111";
						  nextState<=ST10_JLR2; --11th state
					 elsif (opCode = OC_JLR) then
						  rfSel1<="111";
						  rfSel2<=regselb;
						  nextState<=ST10_JLR2; --11th state
					 end if;
				elsif (state = ST5_LMSM) then
					 aluMux2<="111";
					 aluSel<="00";
					 if(opcode = OC_LM) then
						  nextState<=ST6_RDLM; --7th state
					 elsif(opcode = OC_SM) then
						  nextState<=ST7_SM1;  --8th state
					 end if;
				elsif (state = ST6_RDLM) then
					 if(to_integer(unsigned(outRegNum)) = 8) then
						  nextState<=ST1_HK;
					 else
						  if (imm8_16(7-to_integer(unsigned(outRegNum))) = '1') then
								memInMux<='1';--aluout
								current_load<='1';
								nextState<=ST8_LMWB;  --9th state
						  elsif (imm8_16(7-to_integer(unsigned(outRegNum))) = '0') then
								current_load<='0';
								nextState<=ST8_LMWB;  --9th state
						  end if;
					 end if;
				elsif(state = ST8_LMWB) then
					 if(current_load = '1') then
						  rfSelW<=outRegNum(2 downto 0);
						  rfDataIn<=memDataOut;
						  rfWrite<='1';
						  aluMux1<="11";---pass lmsm addr to ALu
						  aluMux2<="001";---pass +1 to ALU to move to next address
						  lmsmAddr<=aluOut;
						  aluSel<="00";
					 end if;
					 inRegNum<=outRegNum;
					 nextState<=ST6_RDLM;  --7th state
				elsif (state = ST7_SM1) then  --8th state
					 memWrite<='0';
					 if(to_integer(unsigned(outRegNum)) /= 0 and current_load = '1') then
						  aluMux1<="11";---pass lmsmaddr to ALu
						  aluMux2<="001";---pass +1 to ALU
						  aluSel<="00";
						  lmsmAddr<=aluOut;
					 end if;
					 if(to_integer(unsigned(outRegNum)) = 8) then
						  inRegNum<="1000";
						  nextState<=ST1_HK;  --2nd state
					 else
						  if (imm8_16(7-to_integer(unsigned(outRegNum))) = '1') then
								rfSel2<=outRegNum(2 downto 0);
								current_load<='1';
								nextState<=ST9_SMW;
						  elsif (imm8_16(7-to_integer(unsigned(outRegNum))) = '0') then
								current_load<='0';
								nextState<=ST9_SMW;
						  end if;
					 end if;
				elsif (state = ST9_SMW) then
					 if(current_load = '1') then
						  memDataIn<=rfDataOut2;
						  memInMux<='1';--aluout
						  memWrite<='1';
					 end if;
					 inRegNum<=outRegNum;
					 nextState<=ST7_SM1;  -- 8th state
				elsif (state = ST10_JLR2) then  --11th state
					 rfDataIn<=rfDataOut1;
					 rfSelW<=regsela;
					 rfWrite<='1';
					 nextState<=ST13_CPC;  --14th state
				elsif (state = ST13_CPC) then  --14th state
					 if(opcode = OC_BEQ) then
						  if (rfDataOut1 = rfDataOut2) then
								rfSelW<="111";
								rfWrite<='1';
								rfDataIn<=aluOut;
						  end if;
					 elsif (opcode = OC_JLR) then
						  rfSelW<="111";
						  rfDataIn<=rfDataOut2;
						  rfWrite<='1';
					 elsif (opcode = OC_JAL) then
						  rfSelW<="111";
						  rfDataIn<=aluOut;
						  rfWrite<='1';
					 end if;
					 nextState<=ST1_HK;
				elsif (state = ST12_MEMA) then  --13th state
					 if(opcode = OC_LW) then
						  rfDataIn<=memDataOut;
						  zeroFlagMux<='1';
						  if(memDataOut = "0000000000000000") then
								lwZeroFlag<='1';
						  else
								lwZeroFlag<='0';
						  end if;
						  rfWrite<='1';
					 elsif (opcode = OC_SW) then
						  memWrite<='1';
						  memDataIn<=rfDataOut2;   
					 end if;
					 nextState<=ST1_HK;
				elsif (state = ST4_WBTR) then  --5th state
					 rfDataIn<=aluOut;
					 rfWrite<='1';
					 nextState<=ST1_HK;
				end if;
	 end process;
	 process(zeroFlagMux,aluZeroFlag,lwZeroFlag)
		  begin
				if(zeroFlagMux = '0') then
					 zeroFlag<=aluZeroFlag;
				elsif (zeroFlagMux = '1') then
					 zeroFlag<=lwZeroFlag;
				end if;
	 end process;
	 process(memInMux,rfDataOut1,aluOut)
		  begin
				if(memInMux = '0') then
					 memAddr<=rfDataOut1(7 downto 0);
				elsif (memInMux = '1') then
					 memAddr<=aluOut(7 downto 0);
				end if;
	 end process;
	 process(aluMux1,aluMux2,rfDataOut1,rfDataOut2,imm6_16,imm8_16,imm9_16high,imm9_16low,prevPC,lmsmAddr)
		  begin
				if(aluMux1 = "00") then
					 aluIn1<=rfDataOut1;
				elsif(aluMux1 = "10") then
					 aluin1<=prevPC;
				elsif (aluMux1 = "11") then
					 aluIn1<=lmsmAddr;
				end if;
				if(aluMux2 = "000") then
					 aluIn2<=rfDataOut2;
				elsif (aluMux2 = "001") then
					 aluIn2<=(0=>'1',others=>'0');
				elsif (aluMux2 = "010") then --left shift rfDataOut2 before sending to ALU
					 aluIn2<=std_logic_vector(shift_left(unsigned(rfDataOut2),1)) ;
				elsif (aluMux2 = "011") then
					 aluIn2<=imm6_16;
				elsif (aluMux2 = "100") then
					 aluIn2<=imm9_16low;
				elsif (aluMux2 = "101") then
					 aluIn2<=index;
				elsif (aluMux2 = "111") then
					 aluIn2<=(others=>'0');
				end if;
	 end process;
	 process(state,nextState)
		  begin
				outstates(7 downto 4) <= nextState;
				outstates(3 downto 0) <= state;
	 end process;
	 process(imm9)
		  begin  --assigning immed6, immed8, immed9 
				imm9_16high(15 downto 7)<=imm9;    
				imm9_16high(6 downto 0)<=(others=>'0');
				imm9_16low(8 downto 0)<=imm9;
				imm9_16low(15 downto 9)<=(others=>'0');
	 end process;
	 process(imm8)
		  begin
				imm8_16(7 downto 0)<=imm8;
				imm8_16(15 downto 8)<=(others=>'0');
	 end process;
	 process(imm6)
		  begin
				imm6_16(5 downto 0)<=imm6;
				imm6_16(15 downto 6)<=(others=>'0');
	 end process;

end architecture rtl;