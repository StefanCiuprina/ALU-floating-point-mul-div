library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity CounterModulo_10 is
port(
	moveUpDown : in STD_LOGIC;
	updown : in STD_LOGIC;
	reset : in STD_LOGIC;
	Q : out STD_LOGIC_VECTOR(3 downto 0)
	);
end CounterModulo_10;

architecture M of CounterModulo_10 is				 

signal tmp : STD_LOGIC_VECTOR(3 downto 0);

begin
	process(moveUpDown, reset)
		begin
			if(reset = '1') then
				tmp <= x"0";
			else
				if(rising_edge(moveUpDown)) then
					if(updown = '1') then
						if(tmp = x"9") then
							tmp <= x"0";
						else
							tmp <= tmp + 1;
						end if;
					else
						if(tmp = x"0") then
							tmp <= x"9";
						else
							tmp <= tmp - 1;
						end if;
					end if;
				end if;
			end if;
		end process;
	Q <= tmp;
end M;