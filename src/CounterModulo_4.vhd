library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity CounterModulo_4 is
port(
	moveUp : in STD_LOGIC;
	reset : in STD_LOGIC;
	TC : out STD_LOGIC; --terminal count
	Q : out STD_LOGIC_VECTOR(1 downto 0)
	);
end CounterModulo_4;

architecture M of CounterModulo_4 is

signal tmp : STD_LOGIC_VECTOR(1 downto 0);

begin
	process(moveUp, reset)
		begin
			if(reset = '1') then
				tmp <= "00";
			elsif(rising_edge(moveUp)) then
				tmp <= tmp + 1;	
			end if;
		end process;
	Q <= tmp;
	TC <= '1' when tmp = "11" else
		  '0';
end M;