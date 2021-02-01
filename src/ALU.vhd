library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ALU is
port(
	input1, input2 : in STD_LOGIC_VECTOR(31 downto 0);
	clk, load, op_type : in STD_LOGIC; --op_type -> 0 = multiplication, 1 = division
	output : out STD_LOGIC_VECTOR(31 downto 0);
	done : out STD_LOGIC
	);
end ALU; 

architecture Behavioral of ALU is

	component IEEE_Multiplication is
	port(
		input1, input2 : in STD_LOGIC_VECTOR(31 downto 0);
		load : in STD_LOGIC;
		clk : in STD_LOGIC;
		output : out STD_LOGIC_VECTOR(31 downto 0);
		done : out STD_LOGIC
		);
	end component;
	
	component IEEE_Division is
	port(
		input1, input2 : in STD_LOGIC_VECTOR(31 downto 0);
		load : in STD_LOGIC;
		clk : in STD_LOGIC;
		output : out STD_LOGIC_VECTOR(31 downto 0);
		done : out STD_LOGIC
		);
	end component;
	
	signal load_mul, load_div, done_mul, done_div : STD_LOGIC;
	signal output_mul, output_div : STD_LOGIC_VECTOR(31 downto 0);

begin

	IEEE_Mul : IEEE_Multiplication port map(input1, input2, load_mul, clk, output_mul, done_mul);
	IEEE_Div : IEEE_Division port map(input1, input2, load_div, clk, output_div, done_div);
	
	load_mul <= not op_type and load;
	load_div <= op_type and load;
	
	output <= output_mul when op_type = '0' else output_div;
	done <= done_mul when op_type = '0' else done_div;

end Behavioral;