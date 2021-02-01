library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IEEEtoBinary is
port(
	IEEE : in STD_LOGIC_VECTOR(31 downto 0);
	load, clk : in STD_LOGIC;
	   
	--same sizes as in BCDtoBinary
	binary_integer : out STD_LOGIC_VECTOR(13 downto 0);	
	binary_fractional : out STD_LOGIC_VECTOR(45 downto 0);
	done : out STD_LOGIC
	);
end IEEEtoBinary;

architecture Behavioral of IEEEtoBinary is

	signal exponent : STD_LOGIC_VECTOR(7 downto 0);
	signal mantissa : STD_LOGIC_VECTOR(22 downto 0);	  
															 
	
	signal binary_integer_signal : STD_LOGIC_VECTOR(13 downto 0);	
	signal binary_fractional_signal : STD_LOGIC_VECTOR(45 downto 0);
	
	signal step, shift_amount : STD_LOGIC_VECTOR(7 downto 0);
	signal sign_of_exp, done_signal : STD_LOGIC;

begin

	exponent <= IEEE(30 downto 23);
	mantissa <= IEEE(22 downto 0);
	
	process(exponent)
	begin		
		if(exponent >= 127) then
			shift_amount <= exponent - 127;
			sign_of_exp <= '0'; --plus
		else
			shift_amount <= 127 - exponent;
			sign_of_exp <= '1';--minus
		end if;
	end process;
	
	process(clk)
	begin
		if(rising_edge(clk)) then
			if(load = '1') then
				--the number is currently of the form 1.mantissa; we shift the dot according to the exponent
				binary_integer_signal(13 downto 1) <= (others => '0');
				binary_integer_signal(0) <= '1';  
				binary_fractional_signal(45 downto 23) <= mantissa;
				binary_fractional_signal(22 downto 0) <= (others => '0');
				step <= shift_amount; 
				done_signal <= '0';
			elsif(step > x"00") then
				step <= step - 1;
				if(sign_of_exp = '0') then
					binary_integer_signal <= binary_integer_signal(12 downto 0) & binary_fractional_signal(45);
					binary_fractional_signal <= binary_fractional_signal(44 downto 0) & '0';
				else
					binary_integer_signal <= (others => '0');
					binary_fractional_signal <= '0' & binary_fractional_signal(45 downto 1);
				end if;
			else
				done_signal <= '1';
			end if;
		end if;
	end process;
	
	binary_integer <= binary_integer_signal;
	binary_fractional <= binary_fractional_signal;
	done <= done_signal;

end Behavioral;
	
----------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IntegerBinaryToBCD is
port(
	binary_integer : in STD_LOGIC_VECTOR(13 downto 0);
	clk, load : in STD_LOGIC;
	
	BCDinteger : out STD_LOGIC_VECTOR(15 downto 0);
	done : out STD_LOGIC
	);
end IntegerBinaryToBCD;	

architecture Behavioral of IntegerBinaryToBCD is

	component BCDAdder is
		port(
		A, B : in STD_LOGIC_VECTOR(15 downto 0);
		Sum : out STD_LOGIC_VECTOR(15 downto 0);
		CarryOut : out STD_LOGIC
		);
	end component;
	
	signal step : STD_LOGIC_VECTOR(3 downto 0);
	signal BCDnumberToAdd, result, new_result, adder_output : STD_LOGIC_VECTOR(15 downto 0);
	signal almost_done, done_signal : STD_LOGIC;	 

begin

	Addr : BCDAdder port map(result, BCDnumberToAdd, adder_output);

	process(clk)
	begin
		if(rising_edge(clk)) then
			if(load = '1') then
				done_signal <= '0';
				almost_done <= '0';
				result <= (others => '0');
				BCDnumberToAdd <= x"0000";
				new_result <= (others => '0');
				step <= "1101";
			else
				if(almost_done = '0') then
					result <= new_result;
					case step is
						when x"D" => --13
							if(binary_integer(13) = '1') then
								BCDnumberToAdd <= x"8192"; --2^13
							else
								BCDnumberToAdd <= x"0000";
							end if;
							result <= adder_output;
						when x"C" => --12
							if(binary_integer(12) = '1') then
								BCDnumberToAdd <= x"4096"; --2^12
							else
								BCDnumberToAdd <= x"0000";
							end if;
							result <= adder_output;
						when x"B" => --11
							if(binary_integer(11) = '1') then
								BCDnumberToAdd <= x"2048"; --2^11
							else
								BCDnumberToAdd <= x"0000";
							end if;
							result <= adder_output;
						when x"A" => --10
							if(binary_integer(10) = '1') then
								BCDnumberToAdd <= x"1024"; --2^10
							else
								BCDnumberToAdd <= x"0000";
							end if;
							result <= adder_output;
						when x"9" =>
							if(binary_integer(9) = '1') then
								BCDnumberToAdd <= x"0512"; --2^9
							else
								BCDnumberToAdd <= x"0000";
							end if;
							result <= adder_output;
						when x"8" =>
							if(binary_integer(8) = '1') then
								BCDnumberToAdd <= x"0256"; --2^8
							else
								BCDnumberToAdd <= x"0000";
							end if;
							result <= adder_output;
						when x"7" =>
							if(binary_integer(7) = '1') then
								BCDnumberToAdd <= x"0128"; --2^7
							else
								BCDnumberToAdd <= x"0000";
							end if;
							result <= adder_output;
						when x"6" =>
							if(binary_integer(6) = '1') then
								BCDnumberToAdd <= x"0064"; --2^6
							else
								BCDnumberToAdd <= x"0000";
							end if;
							result <= adder_output;
						when x"5" =>
							if(binary_integer(5) = '1') then
								BCDnumberToAdd <= x"0032"; --2^5
							else
								BCDnumberToAdd <= x"0000";
							end if;
							result <= adder_output;
						when x"4" =>
							if(binary_integer(4) = '1') then
								BCDnumberToAdd <= x"0016"; --2^4
							else
								BCDnumberToAdd <= x"0000";
							end if;
							result <= adder_output;
						when x"3" =>
							if(binary_integer(3) = '1') then
								BCDnumberToAdd <= x"0008"; --2^3
							else
								BCDnumberToAdd <= x"0000";
							end if;
							result <= adder_output;
						when x"2" =>
							if(binary_integer(2) = '1') then
								BCDnumberToAdd <= x"0004"; --2^2
							else
								BCDnumberToAdd <= x"0000";
							end if;
							result <= adder_output;
						when x"1" =>
							if(binary_integer(1) = '1') then
								BCDnumberToAdd <= x"0002"; --2^1
							else
								BCDnumberToAdd <= x"0000";
							end if;
							result <= adder_output;
						when others => --0
							if(binary_integer(0) = '1') then
								BCDnumberToAdd <= x"0001"; --2^0
							else
								BCDnumberToAdd <= x"0000";
							end if;
							result <= adder_output;
					end case;
					
					if(step = x"0") then
						almost_done <= '1';
					else
						step <= step - 1;
					end if;
				elsif(done_signal = '0') then
					result <= adder_output;
					done_signal <= '1';
				end if;
			end if;
		end if;
	end process;
	
	BCDinteger <= result; 
	done <= done_signal;

end Behavioral;
----------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity FractionalBinaryToBCD is
port(
	binary_fractional_46bits : in STD_LOGIC_VECTOR(45 downto 0);
	clk, load : in STD_LOGIC;
	
	BCDfractional : out STD_LOGIC_VECTOR(15 downto 0);
	done : out STD_LOGIC
	);
end FractionalBinaryToBCD;

architecture Behavioral of FractionalBinaryToBCD is

	component BCDAdder is
		port(
		A, B : in STD_LOGIC_VECTOR(15 downto 0);
		Sum : out STD_LOGIC_VECTOR(15 downto 0);
		CarryOut : out STD_LOGIC
		);
	end component;
	
	signal step : STD_LOGIC_VECTOR(3 downto 0);
	signal BCDnumberToAdd, result, new_result, adder_output : STD_LOGIC_VECTOR(15 downto 0);
	signal almost_done, done_signal : STD_LOGIC;
	signal binary_fractional : STD_LOGIC_VECTOR(13 downto 0);


begin
	
	binary_fractional <= binary_fractional_46bits(45 downto 32);
	Addr : BCDAdder port map(result, BCDnumberToAdd, adder_output);

	process(clk)
	begin
		if(rising_edge(clk)) then
			if(load = '1') then
				done_signal <= '0';
				almost_done <= '0';
				result <= (others => '0');
				BCDnumberToAdd <= x"0000";
				new_result <= (others => '0');
				step <= "1101";
			else
				if(almost_done = '0') then
					result <= new_result;
					case step is
						when x"D" => --13
							if(binary_fractional(13) = '1') then
								BCDnumberToAdd <= x"5000"; --2^(-1) = 0.5
							else
								BCDnumberToAdd <= x"0000";
							end if;
							result <= adder_output;
						when x"C" => --12
							if(binary_fractional(12) = '1') then
								BCDnumberToAdd <= x"2500"; --2^(-2) = 0.25
							else
								BCDnumberToAdd <= x"0000";
							end if;
							result <= adder_output;
						when x"B" => --11
							if(binary_fractional(11) = '1') then
								BCDnumberToAdd <= x"1250"; --2^(-3) = 0.125
							else
								BCDnumberToAdd <= x"0000";
							end if;
							result <= adder_output;
						when x"A" => --10
							if(binary_fractional(10) = '1') then
								BCDnumberToAdd <= x"0625"; --2^(-4) = 0.0625
							else
								BCDnumberToAdd <= x"0000";
							end if;
							result <= adder_output;
						when x"9" =>
							if(binary_fractional(9) = '1') then
								BCDnumberToAdd <= x"0313"; --2^(-5) = 0.03125 =~ 0.0313
							else
								BCDnumberToAdd <= x"0000";
							end if;
							result <= adder_output;
						when x"8" =>
							if(binary_fractional(8) = '1') then
								BCDnumberToAdd <= x"0157"; --2^(-6) = 0.015625 =~ 0.0157
							else
								BCDnumberToAdd <= x"0000";
							end if;
							result <= adder_output;
						when x"7" =>
							if(binary_fractional(7) = '1') then
								BCDnumberToAdd <= x"0079"; --2^(-7) = 0.0078125 =~ 0.0079
							else
								BCDnumberToAdd <= x"0000";
							end if;
							result <= adder_output;
						when x"6" =>
							if(binary_fractional(6) = '1') then
								BCDnumberToAdd <= x"0040"; --2^(-8) = 0.00390625 =~ 0.0040
							else
								BCDnumberToAdd <= x"0000";
							end if;
							result <= adder_output;
						when x"5" =>
							if(binary_fractional(5) = '1') then
								BCDnumberToAdd <= x"0020"; --2^(-9) = 0.001953125 =~ 0.0020
							else
								BCDnumberToAdd <= x"0000";
							end if;
							result <= adder_output;
						when x"4" =>
							if(binary_fractional(4) = '1') then
								BCDnumberToAdd <= x"0010"; --2^(-10) = 0.0009765625 =~ 0.0010
							else
								BCDnumberToAdd <= x"0000";
							end if;
							result <= adder_output;
						when x"3" =>
							if(binary_fractional(3) = '1') then
								BCDnumberToAdd <= x"0005"; --2^(-11) = 0.00048828125 =~ 0.0005
							else
								BCDnumberToAdd <= x"0000";
							end if;
							result <= adder_output;
						when x"2" =>
							if(binary_fractional(2) = '1') then
								BCDnumberToAdd <= x"0003"; --2^(-12) = 0.000244140625 =~ 0.0003
 							else
								BCDnumberToAdd <= x"0000";
							end if;
							result <= adder_output;
						when x"1" =>
							if(binary_fractional(1) = '1') then
								BCDnumberToAdd <= x"0002"; --2^(-13) = 0.0001220703125 =~ 0.0002
							else
								BCDnumberToAdd <= x"0000";
							end if;
							result <= adder_output;
						when others => --0
							if(binary_fractional(0) = '1') then
								BCDnumberToAdd <= x"0001"; --2^(-14) = 0.00006103515625 =~ 0.0001
							else
								BCDnumberToAdd <= x"0000";
							end if;
							result <= adder_output;
					end case;
					
					if(step = x"0") then
						almost_done <= '1';
					else
						step <= step - 1;
					end if;
				elsif(done_signal = '0') then
					result <= adder_output;
					done_signal <= '1';
				end if;
			end if;
		end if;
	end process;
	
	BCDfractional <= result; 
	done <= done_signal;

end Behavioral;

----------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IEEEtoBCD is
port(
	IEEE : in STD_LOGIC_VECTOR(31 downto 0);
	load : in STD_LOGIC;
	clk : in STD_LOGIC;
	
	sign : out STD_LOGIC; --'0' for +, '1' for -
	BCD : out STD_LOGIC_VECTOR(15 downto 0);
	FractionalPointLocation : out STD_LOGIC_VECTOR(2 downto 0);														  										   							  				   
	done : out STD_LOGIC
	);
end IEEEtoBCD;

architecture Behavioral of IEEEtoBCD is

	component IEEEtoBinary is
	port(
		IEEE : in STD_LOGIC_VECTOR(31 downto 0);
		load, clk : in STD_LOGIC;
		
		binary_integer : out STD_LOGIC_VECTOR(13 downto 0);	
		binary_fractional : out STD_LOGIC_VECTOR(45 downto 0);
		done : out STD_LOGIC
		);
	end component;
	
	component IntegerBinaryToBCD is
	port(
		binary_integer : in STD_LOGIC_VECTOR(13 downto 0);
		clk, load : in STD_LOGIC;
		
		BCDinteger : out STD_LOGIC_VECTOR(15 downto 0);
		done : out STD_LOGIC
		);
	end component;
	
	component FractionalBinaryToBCD is
	port(
		binary_fractional_46bits : in STD_LOGIC_VECTOR(45 downto 0);
		clk, load : in STD_LOGIC;
		
		BCDfractional : out STD_LOGIC_VECTOR(15 downto 0);
		done : out STD_LOGIC
		);
	end component;
	
	signal binary_integer : STD_LOGIC_VECTOR(13 downto 0);	
	signal binary_fractional : STD_LOGIC_VECTOR(45 downto 0);
	
	signal binary_conversion_done, enable, bcd_int_done, bcd_frac_done : STD_LOGIC;
	
	signal BCD_signal, BCDinteger, BCDfractional : STD_LOGIC_VECTOR(15 downto 0);
	
	signal FractionalPointLocation_signal : STD_LOGIC_VECTOR(2 downto 0);

begin 

	enable <= not binary_conversion_done;

	IEEEtoBin : IEEEtoBinary port map(IEEE, load, clk, binary_integer, binary_fractional, binary_conversion_done);
	BinaryIntToBCD : IntegerBinaryToBCD port map(binary_integer, clk, enable, BCDinteger, bcd_int_done);
	BinaryFracToBCD : FractionalBinaryToBCD port map(binary_fractional, clk, enable, BCDfractional, bcd_frac_done);
	
	process(bcd_int_done, bcd_frac_done)
	begin		
		if (bcd_int_done = '1' and bcd_frac_done = '1') then
			if(BCDinteger(15 downto 12) = x"0") then
				if(BCDinteger(11 downto 8) = x"0") then
					if(BCDinteger(7 downto 4) = x"0") then
						if(BCDinteger(3 downto 0) = x"0") then
							BCD_signal <= BCDfractional;
							FractionalPointLocation_signal <= "100";
						else
							BCD_signal(15 downto 12) <= BCDinteger(3 downto 0);
							BCD_signal(11 downto 0) <= BCDfractional(15 downto 4);
							FractionalPointLocation_signal <= "011";
						end if;
					else
						BCD_signal(15 downto 8) <= BCDinteger(7 downto 0);
						BCD_signal(7 downto 0) <= BCDfractional(15 downto 8);
						FractionalPointLocation_signal <= "010";
					end if;
				else   
					BCD_signal(15 downto 4) <= BCDinteger(11 downto 0);
					BCD_signal(3 downto 0) <= BCDfractional(15 downto 12);
					FractionalPointLocation_signal <= "001";
				end if;
			else
				BCD_signal <= BCDinteger;
				FractionalPointLocation_signal <= "000";
			end if;
		end if;
	end process;
	
	BCD <= BCD_signal;
	FractionalPointLocation <= FractionalPointLocation_signal;
	done <= bcd_int_done and bcd_frac_done;
	

end Behavioral;