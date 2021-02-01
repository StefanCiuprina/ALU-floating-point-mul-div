library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IEEE_Division is
port(
	input1, input2 : in STD_LOGIC_VECTOR(31 downto 0);
	load : in STD_LOGIC;
	clk : in STD_LOGIC;
	output : out STD_LOGIC_VECTOR(31 downto 0);
	done : out STD_LOGIC
	);
end IEEE_Division;

architecture Behavioral of IEEE_Division is

	component divider is
	port(
		input1 : in STD_LOGIC_VECTOR(23 downto 0);
		input2 : in STD_LOGIC_VECTOR(23 downto 0);
		load : in STD_LOGIC;
		clk : in STD_LOGIC;
		
		result : out STD_LOGIC_VECTOR(24 downto 0);
		done : out STD_LOGIC
		);
	end component;
	
	signal signInput1, signInput2, signOutput, normalization : STD_LOGIC;
	signal exponentInput1, exponentInput2, exponentOutput : STD_LOGIC_VECTOR(7 downto 0);
	signal mantissaInput1, mantissaInput2, mantissaOutput : STD_LOGIC_VECTOR(22 downto 0);
	
	signal mantissaInput1_WITHONE, mantissaInput2_WITHONE : STD_LOGIC_VECTOR(23 downto 0);
	
	signal divisionResult : STD_LOGIC_VECTOR(24 downto 0);

begin

	--parsing the ieee numbers
	signInput1 <= input1(31);
	exponentInput1 <= input1(30 downto 23);
	mantissaInput1 <= input1(22 downto 0);
	
	signInput2 <= input2(31);
	exponentInput2 <= input2(30 downto 23);
	mantissaInput2 <= input2(22 downto 0);
	
	--computing the sign
	signOutput <= signInput1 xor signInput2;
	
	--instantiating the division component 
	mantissaInput1_WITHONE <= '1' & mantissaInput1;		
	mantissaInput2_WITHONE <= '1' & mantissaInput2;
	DIV : divider port map (mantissaInput1_WITHONE, mantissaInput2_WITHONE, load, clk, divisionResult, done);
	
	--computing the exponent
	normalization <= not divisionResult(24);
	exponentOutput <= (exponentInput1 - exponentInput2) + 127 - normalization;
	
	--computing the mantissa
	mantissaOutput <= divisionResult(23 downto 1) when normalization = '0' else divisionResult(22 downto 0);
	
	output <= signOutput & exponentOutput & mantissaOutput;

end Behavioral;