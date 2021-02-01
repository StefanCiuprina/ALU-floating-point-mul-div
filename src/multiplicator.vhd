--first we have some auxiliary components; to see the Multiplicator, scroll to the end.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MultiplicandRegister is
generic(n : natural);
port(
	input : in STD_LOGIC_VECTOR(2*n-1 downto 0);
	write : in STD_LOGIC;
	shift_left : in STD_LOGIC;
	clk : in STD_LOGIC;
	output : out STD_LOGIC_VECTOR(2*n-1 downto 0)
	);
end MultiplicandRegister;

architecture Behavioral of MultiplicandRegister is

signal content : STD_LOGIC_VECTOR(2*n-1 downto 0);

begin
	
	process (clk)
		begin
			if(rising_edge(clk)) then
				if (write = '1') then
					content <= input;
				elsif (shift_left = '1') then
					content <= content(2*n-2 downto 0) & '0';
				end if;
			end if;
		end process;
	
	output <= content;

end Behavioral;

--------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MultiplierRegister is 
generic(n : natural);
port(
	input : in STD_LOGIC_VECTOR(n-1 downto 0);
	write : in STD_LOGIC;
	shift_right : in STD_LOGIC;
	clk : in STD_LOGIC;
	output : out STD_LOGIC_VECTOR(n-1 downto 0)
	);
end MultiplierRegister;

architecture Behavioral of MultiplierRegister is

signal content : STD_LOGIC_VECTOR(n-1 downto 0);

begin
	
	process (clk)
		begin
			if(rising_edge(clk)) then
				if (write = '1') then
					content <= input;
				elsif (shift_right = '1') then
					content <= '0' & content(n-1 downto 1);
				end if;
			end if;
		end process;
	
	output <= content;

end Behavioral;

--------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ProductRegister is
generic(n : natural);
port(
	input : in STD_LOGIC_VECTOR(2*n-1 downto 0);
	write : in STD_LOGIC;	 
	reset : in STD_LOGIC;
	clk : in STD_LOGIC;
	output : out STD_LOGIC_VECTOR(2*n-1 downto 0)
	);
end ProductRegister;

architecture Behavioral of ProductRegister is

signal content : STD_LOGIC_VECTOR(2*n-1 downto 0);

begin
	
	process (clk, reset)
		begin		   
			if(reset = '1') then
				content <= (others => '0');
			elsif(rising_edge(clk)) then
				if (write = '1') then
					content <= input;
				end if;
			end if;
		end process;
	
	output <= content;

end Behavioral;

--------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Adder is
generic(n : natural);
port(
	input1 : in STD_LOGIC_VECTOR(2*n-1 downto 0);
	input2: in STD_LOGIC_VECTOR(2*n-1 downto 0);
	add : in STD_LOGIC;
	output : out STD_LOGIC_VECTOR(2*n-1 downto 0)
	);
end Adder;

architecture Behavioral of Adder is

begin
	 
	output <= (input1 + input2) when add = '1' else input2;

end Behavioral;

----------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Multiplicator is
generic(n : natural);	
port(
	multiplicand : in STD_LOGIC_VECTOR(2*n-1 downto 0);
	multiplier : in STD_LOGIC_VECTOR(n-1 downto 0);
	load : in STD_LOGIC;
	clk : in STD_LOGIC;
	product : out STD_LOGIC_VECTOR(2*n-1 downto 0);
	done : out STD_LOGIC
	);
	
end Multiplicator;

architecture Structural of Multiplicator is

component MultiplicandRegister is
generic(n : natural);
port(
	input : in STD_LOGIC_VECTOR(2*n-1 downto 0);
	write : in STD_LOGIC;
	shift_left : in STD_LOGIC;
	clk : in STD_LOGIC;
	output : out STD_LOGIC_VECTOR(2*n-1 downto 0)
	);
end component;

component MultiplierRegister is
generic(n : natural);
port(
	input : in STD_LOGIC_VECTOR(n-1 downto 0);
	write : in STD_LOGIC;
	shift_right : in STD_LOGIC;
	clk : in STD_LOGIC;
	output : out STD_LOGIC_VECTOR(n-1 downto 0)
	);
end component;

component ProductRegister is
generic(n : natural);
port(
	input : in STD_LOGIC_VECTOR(2*n-1 downto 0);
	write : in STD_LOGIC;
	reset : in STD_LOGIC;
	clk : in STD_LOGIC;
	output : out STD_LOGIC_VECTOR(2*n-1 downto 0)
	);
end component;

component Adder is 
generic(n : natural);
port(
	input1 : in STD_LOGIC_VECTOR(2*n-1 downto 0);
	input2: in STD_LOGIC_VECTOR(2*n-1 downto 0);
	add : in STD_LOGIC;
	output : out STD_LOGIC_VECTOR(2*n-1 downto 0)
	);
end component;

signal multiplicand_reg, adder_output, product_output : STD_LOGIC_VECTOR(2*n-1 downto 0);
signal multiplier_reg : STD_LOGIC_VECTOR(n-1 downto 0);
signal multiplicand_write_signal, shift_left_signal, multiplier_write_signal, shift_right_signal, product_write_signal, add_signal, reset : STD_LOGIC;

begin

	MultiplicandReg : MultiplicandRegister generic map (n) port map (multiplicand, multiplicand_write_signal, shift_left_signal, clk, multiplicand_reg);
	MultiplierReg : MultiplierRegister generic map (n) port map (multiplier, multiplier_write_signal, shift_right_signal, clk, multiplier_reg);
	ProductReg : ProductRegister generic map (n) port map (adder_output, product_write_signal, reset, clk, product_output);
	Addr : Adder generic map (n) port map (multiplicand_reg, product_output, add_signal, adder_output);
	
	product <= product_output; 
	
	add_signal <= multiplier_reg(0);
	
	process (load, multiplier_reg)
		begin
				if(load = '1') then
					multiplicand_write_signal <= '1';
					shift_left_signal <= '0';
					multiplier_write_signal <= '1';
					shift_right_signal <= '0';
					product_write_signal <= '0';
					done <= '0';
					reset <= '1';
				else 
					reset <= '0';
					multiplicand_write_signal <= '0';
					shift_left_signal <= '1';
					multiplier_write_signal <= '0';
					shift_right_signal <= '1';
					if (multiplier_reg = 0) then
						product_write_signal <= '0';
						done <= '1';
					else
						product_write_signal <= '1';
						done <= '0';
					end if;
				end if;
		end process;
	
end Structural;	