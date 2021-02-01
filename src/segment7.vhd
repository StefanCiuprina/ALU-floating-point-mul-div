library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity x7seg is
port(
	CLK: in STD_LOGIC;
	clr: in STD_LOGIC;						  
	a_to_g: out STD_LOGIC_VECTOR(6 downto 0);
	dp : out STD_LOGIC;
	an: out STD_LOGIC_VECTOR(3 downto 0);
	x:  in STD_LOGIC_VECTOR(15 downto 0);
	dp_location : in STD_LOGIC_VECTOR(2 downto 0));
end x7seg;

architecture arh_x7seg of x7seg is
signal s: STD_LOGIC_VECTOR(1 downto 0);
signal digit: STD_LOGIC_VECTOR(3 downto 0);
signal clkdiv: STD_LOGIC_VECTOR(18 downto 0);


begin

	s <= clkdiv(18 downto 17);
	process(s, x)
	begin
		case s is
			when "00" => digit <= x(15 downto 12);
			when "01" => digit <= x(11 downto 8);
			when "10" => digit <= x(7 downto 4);
			when others => digit <= x(3 downto 0);
		end case;
	end process;
	
	process(digit)
	begin
		case digit is
			when "0000"=> a_to_g <="0000001";  -- '0'
			when "0001"=> a_to_g <="1001111";  -- '1'
			when "0010"=> a_to_g  <="0010010";  -- '2'
			when "0011"=> a_to_g  <="0000110";  -- '3'
			when "0100"=> a_to_g  <="1001100";  -- '4' 
			when "0101"=> a_to_g  <="0100100";  -- '5'
			when "0110"=> a_to_g  <="0100000";  -- '6'
			when "0111"=> a_to_g  <="0001111";  -- '7'
			when "1000"=> a_to_g  <="0000000";  -- '8'
			when "1001"=> a_to_g  <="0000100";  -- '9'
			when others=> a_to_g  <="1111111"; 
		end case;
	end process;
	
	process(s, clr)
	begin
		an <= "1111";
		dp <= '1';
		if clr = '0' then
			an(conv_integer(s)) <= '0';
			if(conv_integer(3-s) = dp_location) then
				dp <= '0';
			end if;
		end if;
	end process;


	process(clk, clr)
	begin
		if clr = '1' then
			clkdiv <= (others => '0');

		elsif clk'event and clk = '1' then
			clkdiv <= clkdiv + 1;
		end if;
	end process;
	
end arh_x7seg;



