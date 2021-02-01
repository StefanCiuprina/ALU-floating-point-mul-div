--first we have some auxiliary components; to see the IntegerBCDToBinary and FractionalBCDToBinary, scroll to the end.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity BCDDividerByTwo is
port(
	input : in STD_LOGIC_VECTOR(15 downto 0);
	clk : in STD_LOGIC;
	load : in STD_LOGIC;
	output : out STD_LOGIC_VECTOR(15 downto 0);
	remainder : out STD_LOGIC;
	done : out STD_LOGIC
	);
end BCDDividerByTwo;

architecture Behavioral of BCDDividerByTwo is

	signal input_signal : STD_LOGIC_VECTOR(15 downto 0);
	signal current_divident, current_divident_PLUS10 : STD_LOGIC_VECTOR(4 downto 0);
	signal step : STD_LOGIC_VECTOR(1 downto 0);
	signal divider_remainder_signal, done_signal : STD_LOGIC;
	type array_type is array(3 downto 0) of STD_LOGIC_VECTOR(3 downto 0);
	signal output_digits : array_type;
	

begin

	current_divident_PLUS10 <= current_divident + "01010";

	process(clk)
	begin
		if(rising_edge(clk)) then  
			if(load = '1') then
				input_signal <= input(11 downto 0) & "0000";
				step <= "11";
				done_signal <= '0';
				current_divident <= '0' & input(15 downto 12);
				divider_remainder_signal <= '0';
			elsif(done_signal = '0') then
				if(divider_remainder_signal = '0') then --even number
					output_digits(conv_integer(step)) <= current_divident(4 downto 1);
				else
					output_digits(conv_integer(step)) <= current_divident_PLUS10(4 downto 1);
				end if;
				divider_remainder_signal <= current_divident(0);
				current_divident <= '0' & input_signal(15 downto 12);
				input_signal <= input_signal(11 downto 0) & "0000";
				if(step = "00") then
					done_signal <= '1';
				else
					step <= step - 1;
				end if;
	 		end if;
		end if;
	end process;
	
	output <= output_digits(3) & output_digits(2) & output_digits(1) & output_digits(0);
	remainder <= divider_remainder_signal;
	done <= done_signal;

end Behavioral;

-------------------------------------------------------		

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity BCDMultiplierByTwoForSmallNumbers is
port(
	fractionalPartInput : in STD_LOGIC_VECTOR(15 downto 0);
	fractionalPartOutput : out STD_LOGIC_VECTOR(15 downto 0);
	integerPartOutput : out STD_LOGIC --can only be 0 or 1 in our case, since we're multypling only numbers < 1
	);
end BCDMultiplierByTwoForSmallNumbers;				 

architecture Behavioral of BCDMultiplierByTwoForSmallNumbers is

	component BCDAdder is
	port(
		A, B : in STD_LOGIC_VECTOR(15 downto 0);
		Sum : out STD_LOGIC_VECTOR(15 downto 0);
		CarryOut : out STD_LOGIC
		);
	end component;

begin

	Adder : BCDAdder port map(fractionalPartInput, fractionalPartInput, fractionalPartOutput, integerPartOutput); --we simply add the number with itself

end;

--------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IntegerBCDtoBinary is
port(
	BCD : in STD_LOGIC_VECTOR(15 downto 0);
	clk : in STD_LOGIC;
	load : in STD_LOGIC;
	binary : out STD_LOGIC_VECTOR(13 downto 0); --9999 (biggest integer number on 4 bits) needs 14 bits to represent
	done : out STD_LOGIC
	);
end IntegerBCDtoBinary;

architecture Behavioral of IntegerBCDtoBinary is

	component BCDDividerByTwo is
	port(
		input : in STD_LOGIC_VECTOR(15 downto 0);
		clk : in STD_LOGIC;
		load : in STD_LOGIC;
		output : out STD_LOGIC_VECTOR(15 downto 0);
		remainder : out STD_LOGIC;
		done : out STD_LOGIC
		);
	end component;
	
	signal input_signal, output_signal : STD_LOGIC_VECTOR(15 downto 0);
	signal divider_load_signal, divider_remainder_signal, divider_done_signal, done_signal : STD_LOGIC;
	
	signal binary_signal : STD_LOGIC_VECTOR(13 downto 0);
	signal step : STD_LOGIC_VECTOR(3 downto 0); --for each digit of the result; max is 14, which is represented on 4 bits

begin

	BCDDivByTwo : BCDDividerByTwo port map(input_signal, clk, divider_load_signal, output_signal, divider_remainder_signal, divider_done_signal);
	
	process(clk)
	begin
		if(rising_edge(clk)) then
			if(load = '1') then
				input_signal <= BCD;
				divider_load_signal <= '1';
				done_signal <= '0';
				binary_signal <= (others => '0');
				step <= "0000";
			elsif(divider_load_signal = '1') then
				divider_load_signal <= '0';
			elsif(done_signal = '0') then
				if(divider_done_signal = '1') then
					binary_signal(conv_integer(step)) <= divider_remainder_signal;
					if(output_signal = x"0000") then
						done_signal <= '1';
					end if;
					input_signal <= output_signal; 
					divider_load_signal <= '1';
					step <= step + 1;
				end if;
			end if;
		end if;
	end process;
	
	done <= done_signal;
	binary <= binary_signal;

end Behavioral;

--------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity FractionalBCDtoBinary is
port(
	BCD : in STD_LOGIC_VECTOR(15 downto 0);
	clk : in STD_LOGIC;
	load : in STD_LOGIC;
	binary : out STD_LOGIC_VECTOR(45 downto 0); --46 (23+23) bit precision for the fractional part
	done : out STD_LOGIC
	);
end FractionalBCDtoBinary;

architecture Behavioral of FractionalBCDtoBinary is

	component BCDMultiplierByTwoForSmallNumbers is
	port(
		fractionalPartInput : in STD_LOGIC_VECTOR(15 downto 0);
		fractionalPartOutput : out STD_LOGIC_VECTOR(15 downto 0);
		integerPartOutput : out STD_LOGIC --can only be 0 or 1 in our case, since we're multypling only numbers < 1
		);
	end component;
	
	signal input_signal, output_signal : STD_LOGIC_VECTOR(15 downto 0);
	signal integer_part, done_signal : STD_LOGIC;
	signal binary_signal : STD_LOGIC_VECTOR(51 downto 0); --we compute 52 bits (for approximation), but keep only 46
	signal approximate : STD_LOGIC;
	signal step : STD_LOGIC_VECTOR(5 downto 0);

begin
	
	MulByTwo : BCDMultiplierByTwoForSmallNumbers port map(input_signal, output_signal, integer_part);
	
	approximate <= binary_signal(5) or binary_signal(4) or binary_signal(3) or binary_signal(2) or binary_signal(1) or binary_signal(0);
	process(clk)
	begin
		if(rising_edge(clk)) then
			if(load = '1') then
				input_signal <= BCD;
				binary_signal <= (others => '0'); 
				done_signal <= '0';
				step <= "110011"; 
			elsif(done_signal = '0') then
				if(input_signal = x"0000") then
					binary_signal <= (others => '0');
					done_signal <= '1';
				else
					binary_signal(conv_integer(step)) <= integer_part;
					if((output_signal = x"0000") or (step = "000000")) then --maximum  bits
						if(approximate = '1') then
							binary_signal <= binary_signal + 1;
						end if;
						done_signal <= '1';
					else
						step <= step - 1;	   
					end if;
					input_signal <= output_signal;
				end if;
			end if;
		end if;
	end process;
	
	done <= done_signal;
	binary <= binary_signal(51 downto 6);

end Behavioral;