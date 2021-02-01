library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IEEE_Multiplication is
port(
	input1, input2 : in STD_LOGIC_VECTOR(31 downto 0);
	load : in STD_LOGIC;
	clk : in STD_LOGIC;
	output : out STD_LOGIC_VECTOR(31 downto 0);
	done : out STD_LOGIC
	);
end IEEE_Multiplication;

architecture Behavioral of IEEE_Multiplication is

	component Multiplicator is
	generic(n : natural);	
	port(
		multiplicand : in STD_LOGIC_VECTOR(2*n-1 downto 0);
		multiplier : in STD_LOGIC_VECTOR(n-1 downto 0);
		load : in STD_LOGIC;
		clk : in STD_LOGIC;
		product : out STD_LOGIC_VECTOR(2*n-1 downto 0);
		done : out STD_LOGIC
		);
		
	end component;
	
	signal signInput1, signInput2, signOutput : STD_LOGIC;
	signal exponentInput1, exponentInput2, exponentOutput : STD_LOGIC_VECTOR(7 downto 0);
	signal mantissaInput1, mantissaInput2, mantissaOutput : STD_LOGIC_VECTOR(22 downto 0);
	
	signal mantissaInput1_WITHONE : STD_LOGIC_VECTOR(47 downto 0);
	signal mantissaInput2_WITHONE : STD_LOGIC_VECTOR(23 downto 0);
	
	signal multiplicationResult : STD_LOGIC_VECTOR(47 downto 0);

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
	
	--instantiating the Multiplication component
	mantissaInput1_WITHONE(47 downto 24) <= (others => '0');
	mantissaInput1_WITHONE(23 downto 0) <= '1' & mantissaInput1;
	mantissaInput2_WITHONE <= '1' & mantissaInput2;
	
	MUL : Multiplicator generic map (24) port map (mantissaInput1_WITHONE, mantissaInput2_WITHONE, load, clk, multiplicationResult, done);
	
	--computing the exponent
	exponentOutput <= (((exponentInput1 - 127) + (exponentInput2 - 127)) + multiplicationResult(47) + 127);
	
	--computing the mantissa
	with multiplicationResult(47) select mantissaOutput <=
		multiplicationResult(45 downto 23) when '0',
		multiplicationResult(46 downto 24) when OTHERS;
	
	output <= signOutput & exponentOutput & mantissaOutput;

end Behavioral;