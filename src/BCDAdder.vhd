library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity BCDOneDigitAdder is
port(
	A, B : in STD_LOGIC_VECTOR(3 downto 0);
	CarryIn : in STD_LOGIC;
	Sum : out STD_LOGIC_VECTOR(3 downto 0);
	CarryOut : out STD_LOGIC
	);
end BCDOneDigitAdder;

architecture Behavioral of BCDOneDigitAdder is

	signal sum_signal, sum_signal_MinusTen : STD_LOGIC_VECTOR(4 downto 0);

begin

	sum_signal <= ('0' & A) + ('0' & B) + ("0000" & CarryIn);
	sum_signal_MinusTen <= sum_signal - "01010";

	process(sum_signal, sum_signal_MinusTen)
	begin
		if(sum_signal >= 10) then
			Sum <= sum_signal_MinusTen(3 downto 0);
			CarryOut <= '1';
		else
			Sum <= sum_signal(3 downto 0);
			CarryOut <= '0';
		end if;
	end process;

end Behavioral;

-------------------------------------------------------	  

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity BCDAdder is
port(
	A, B : in STD_LOGIC_VECTOR(15 downto 0);
	Sum : out STD_LOGIC_VECTOR(15 downto 0);
	CarryOut : out STD_LOGIC
	);
end BCDAdder;

architecture Behavioral of BCDAdder is

	component BCDOneDigitAdder is
	port(
		A, B : in STD_LOGIC_VECTOR(3 downto 0);
		CarryIn : in STD_LOGIC;
		Sum : out STD_LOGIC_VECTOR(3 downto 0);
		CarryOut : out STD_LOGIC
		);
	end component;
	
	signal Carry1, Carry2, Carry3 : STD_LOGIC;

begin

	BCDDigitAdder0 : BCDOneDigitAdder port map(A(3 downto 0), B(3 downto 0), '0', Sum(3 downto 0), Carry1);
	BCDDigitAdder1 : BCDOneDigitAdder port map(A(7 downto 4), B(7 downto 4), Carry1, Sum(7 downto 4), Carry2);
	BCDDigitAdder2 : BCDOneDigitAdder port map(A(11 downto 8), B(11 downto 8), Carry2, Sum(11 downto 8), Carry3);
	BCDDigitAdder3 : BCDOneDigitAdder port map(A(15 downto 12), B(15 downto 12), Carry3, Sum(15 downto 12), CarryOut);

end Behavioral;