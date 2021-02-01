library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity BCDtoIEEE is
port(
	BCD : in STD_LOGIC_VECTOR(15 downto 0);
	FractionalPointLocation : in STD_LOGIC_VECTOR(2 downto 0);
	load : in STD_LOGIC;
	sign : in STD_LOGIC; --'0' for +, '1' for -
	clk : in STD_LOGIC;
	IEEE : out STD_LOGIC_VECTOR(31 downto 0);
	done : out STD_LOGIC
	);
end BCDtoIEEE;

architecture Behavioral of BCDtoIEEE is

	component IntegerBCDtoBinary is
	port(
		BCD : in STD_LOGIC_VECTOR(15 downto 0);
		clk : in STD_LOGIC;
		load : in STD_LOGIC;
		binary : out STD_LOGIC_VECTOR(13 downto 0);
		done : out STD_LOGIC
		);
	end component;
	
	component FractionalBCDtoBinary is
	port(
		BCD : in STD_LOGIC_VECTOR(15 downto 0);
		clk : in STD_LOGIC;
		load : in STD_LOGIC;
		binary : out STD_LOGIC_VECTOR(45 downto 0);
		done : out STD_LOGIC
		);
	end component;
	
	signal BCDinteger, BCDfractional : STD_LOGIC_VECTOR(15 downto 0);
	signal load_integer, load_fractional, done_integer, done_fractional : STD_LOGIC;
	signal binaryIntegerNumber : STD_LOGIC_VECTOR(13 downto 0); --max integer number is 9999
	signal binaryIntegerNumberCopy : STD_LOGIC_VECTOR(13 downto 0);
	signal binaryFractionalNumber : STD_LOGIC_VECTOR(45 downto 0); --46 bits precision for Fractional part, we'll keep only 23 in the mantissa
	signal binaryFractionalNumberCopy : STD_LOGIC_VECTOR(45 downto 0);
	signal binaryCombinedNumber : STD_LOGIC_VECTOR(59 downto 0);
											   
	signal sign_signal : STD_LOGIC;
	signal exponent : STD_LOGIC_VECTOR(7 downto 0);
	signal mantissa : STD_LOGIC_VECTOR(22 downto 0);  
	
	type bcd_digit_type is array(3 downto 0) of STD_LOGIC_VECTOR(3 downto 0);
	signal BCD_digit : bcd_digit_type; 
	
	signal done_signal : STD_LOGIC;
	signal firstOne_found, firstOne_inInteger : STD_LOGIC;
	
	signal posInInt : STD_LOGIC_VECTOR(3 downto 0);
	signal shiftAmountInt : STD_LOGIC_VECTOR(3 downto 0);
	signal posInFractional : STD_LOGIC_VECTOR(5 downto 0);
	signal shiftAmountFrac : STD_LOGIC_VECTOR(5 downto 0);
	
	signal approximate : STD_LOGIC;
	
	signal iterator : STD_LOGIC_VECTOR(5 downto 0);
	
	signal copied, combined : STD_LOGIC;

begin
   
   BCD_digit(3) <= BCD(15 downto 12);
   BCD_digit(2) <= BCD(11 downto 8);
   BCD_digit(1) <= BCD(7 downto 4);
   BCD_digit(0) <= BCD(3 downto 0);
   
   IntegerBCDtoBIN : IntegerBCDtoBinary port map(BCDinteger, clk, load, binaryIntegerNumber, done_integer);
   FractionalBCDtoBIN : FractionalBCDtoBinary port map(BCDfractional, clk, load, binaryFractionalNumber, done_fractional);
   shiftAmountInt <= 14 - posInInt; --13 - posInInt + 1
   shiftAmountFrac <= 46 - posInFractional; --45 - posInFractional + 1 
   
	process(clk)
	begin
		if(rising_edge(clk)) then
			if(load = '1') then
				case FractionalPointLocation is
					when "000" =>
						BCDinteger <= BCD;
						BCDfractional <= x"0000";
					when "001" =>  
						BCDinteger <= x"0" & BCD_digit(3) & BCD_digit(2) & BCD_digit(1);
						BCDfractional <= BCD_digit(0) & x"000";
					when "010" =>
						BCDinteger <= x"00" & BCD_digit(3) & BCD_digit(2);
						BCDfractional <= BCD_digit(1) & BCD_digit(0) & x"00";
					when "011" =>
						BCDinteger <= x"000" & BCD_digit(3);
						BCDfractional <= BCD_digit(2) & BCD_digit(1) & BCD_digit(0) & x"0";
					when OTHERS => --when "100"
						BCDinteger <= x"0000";
						BCDfractional <= BCD;
				end case;
				done_signal <= '0';
				firstOne_found <= '0';
				posInInt <= "1101"; --13
				posInFractional <= "101101"; --45
				approximate <= '0';
				iterator <= (others => '0');
				copied <= '0';
				combined <= '0';
			elsif(done_signal = '0') then  
				if((done_integer and done_fractional) = '1') then
					if(copied = '0') then
						binaryIntegerNumberCopy <= binaryIntegerNumber;
						binaryFractionalNumberCopy <= binaryFractionalNumber;
						copied <= '1';
					elsif(combined = '0') then
						binaryCombinedNumber <= binaryIntegerNumberCopy & binaryFractionalNumberCopy;
						combined <= '1';
					else
						if((binaryIntegerNumber = x"0000") and (binaryFractionalNumber = x"0000")) then
							sign_signal <= '0';
							exponent <= (others => '0');
							mantissa <= (others => '0');
							done_signal <= '1';
						elsif(firstOne_found = '0') then --the number != 0 => we need to find the position of the first '1'
							sign_signal <= sign;
							if(binaryIntegerNumber > 0) then --searching in the integer part for the first '1'
								if(binaryIntegerNumber(conv_integer(posInInt)) = '1') then
									firstOne_found <= '1';
									firstOne_inInteger <= '1';
								else
									posInInt <= posInInt - 1;
								end if;
							else --'1' is not the integer part (integer part is 0), searching in the fractional part for the first '1' (searching only in the first 23 bits)
								if(binaryFractionalNumber(conv_integer(posInFractional)) = '1') then
									firstOne_found <= '1';
									firstOne_inInteger <= '0';
								else
									posInFractional <= posInFractional - 1;
								end if;
							end if;
						elsif(firstOne_inInteger = '1') then --first '1' was found => we can compute the exponent and the mantissa
							exponent <= "01111111" + ("0000" & posInInt); --127 + power of two (posInInt)
							if(posInInt = "0000") then --computing the mantissa by taking all the bits to the left of the first one found
								mantissa <= binaryFractionalNumber(45 downto 23);
								done_signal <= '1';
							else
								if(iterator = shiftAmountInt) then
									mantissa <= binaryCombinedNumber(59 downto 37);
									done_signal <= '1';
								else
									binaryCombinedNumber <= binaryCombinedNumber(58 downto 0) & '0';
									iterator <= iterator + 1;
								end if;
								--mantissa <= binaryIntegerNumber(conv_integer(posInInt-1) downto 0) & binaryFractionalNumber(45 downto (23+conv_integer(posInInt)));
							end if;
							for i in 22 downto 0 loop --approximation
								if (binaryFractionalNumber(i) = '1') then
									approximate <= '1';
								end if;
							end loop;
						else
							exponent <= "01111111" - ("00" & (46-posInFractional)); --127 + power of two (-(23-posInFractional))
							if(posInFractional = "10110") then --22
								mantissa <= binaryFractionalNumber(45 downto 23);
								done_signal <= '1';
							else
								if(iterator = shiftAmountFrac) then
									mantissa <= binaryFractionalNumberCopy(45 downto 23);
									done_signal <= '1';
								else
									binaryFractionalNumberCopy <= binaryFractionalNumberCopy(44 downto 0) & '0';
									iterator <= iterator + 1;
								end if;
								--mantissa <= binaryFractionalNumber(conv_integer(posInFractional-1) downto (conv_integer(posInFractional-1)-22));
							end if;
							for i in 22 downto 0 loop --approximation
								if (binaryFractionalNumber(i) = '1') then
									approximate <= '1';
								end if;
							end loop;
						end if;
					
					end if;
				end if;
			elsif(approximate = '1') then --approximate the mantissa if needed
				mantissa <= mantissa + 1;
				approximate <= '0';
			end if;
		end if;
	end process;
	
	IEEE <= sign_signal & exponent & mantissa;
	done <= done_signal and (not approximate);
	
end Behavioral;