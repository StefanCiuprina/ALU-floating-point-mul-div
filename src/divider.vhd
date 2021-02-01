--divider for dividing numbers of the form (1...)/(1...) (same number of bits). the result will be of the form (1.something) or (0.something),
--the integer part being the MSB, the rest of the 23 bits being part of the fractional part
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity divider is
port(
	input1 : in STD_LOGIC_VECTOR(23 downto 0);
	input2 : in STD_LOGIC_VECTOR(23 downto 0);
	load : in STD_LOGIC;
	clk : in STD_LOGIC;
	
	result : out STD_LOGIC_VECTOR(24 downto 0);
	done : out STD_LOGIC
	);
end divider;

architecture Behavioral of divider is

	signal step : STD_LOGIC_VECTOR(5 downto 0);
	signal input1_signal, input2_signal, current_divident, result_signal : STD_LOGIC_VECTOR(47 downto 0); --current_divident delete	 
	signal approximate, done_signal : STD_LOGIC;								 

begin

	process(clk)
	begin
		if(rising_edge(clk)) then
			if(load = '1') then
				--input1_signal <= input1(22 downto 0) & '0';  
				input2_signal(47 downto 24) <= (others => '0');
				input2_signal(23 downto 0) <= input2;
				result_signal <= (others => '0');
				step <= "101111"; --48 steps for 48 bits (from 0 to 47)
				done_signal <= '0';
				--current_divident(23 downto 1) <= (others => '0');
				--current_divident(0) <= input1(23); 	  
				current_divident(47 downto 24) <= (others => '0');
				current_divident(23 downto 0) <= input1;
			else
				if(done_signal = '0') then
					if(current_divident >= input2_signal) then
						result_signal(conv_integer(step)) <= '1';
						--current_divident <= (current_divident(22 downto 0) - input2_signal(22 downto 0)) & input1_signal(23);
						current_divident <= (current_divident(46 downto 0) - input2_signal(46 downto 0)) & '0';
					else
						result_signal(conv_integer(step)) <= '0';
						current_divident <= current_divident(46 downto 0) & '0'; --shift right and add new bit to current divident
					end if; 
					--input1_signal <= input1_signal(22 downto 0) & '0'; --shift right
					if(step = "00000") then
						done_signal <= '1';
					else
						step <= step - 1;
					end if;
				end if;
			end if;
		end if;
	end process;
	
	process(result_signal)
	begin
		approximate <= '0';
		for i in 22 downto 0 loop
			if (result_signal(i) = '1') then
				approximate <= '1';
			end if;
		end loop;
		
		if(approximate = '1') then
			result <= result_signal(47 downto 23) + 1;
		else
			result <= result_signal(47 downto 23);
		end if;
	end process; 
	
	done <= done_signal;

end Behavioral;