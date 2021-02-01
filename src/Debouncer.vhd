library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity freq_divider is
port(
	 CLK : in std_logic;
     CLK0 : out std_logic
	 );
end freq_divider;

architecture freq_divider_behavioral of freq_divider is
	signal count : INTEGER range 0 to 499999 := 0;
begin
	Divide : process (CLK)
	begin
		if (CLK' event and CLK = '1') then
			if ( count = 499999 ) then
				CLK0 <= '1';
				count <= 0;		  
			else
				count <= count + 1;
				CLK0 <= '0';		  
			end if;
		end if;
	end process Divide;
end freq_divider_behavioral;



----------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Debouncer is
port(
	D : in std_logic; 
	CLK : in std_logic;
	Y : out std_logic
	);
end Debouncer;

architecture D of Debouncer is

	signal Q : std_logic_vector(2 downto 0);
	signal clk0_signal : std_logic;
	
	component freq_divider is
    port(
		 CLK : in std_logic;
         CLK0 : out std_logic
		 );
	end component;

begin
	FREQ : freq_divider
	port map(
			CLK => CLK,
			CLK0 => clk0_signal
			);
	process(clk0_signal)
		begin
			if(clk0_signal' event and clk0_signal = '1') then
				Q(2) <= Q(1);
				Q(1) <= Q(0);
				Q(0) <= D;
			end if;
		end process;
	Y <= Q(2) and Q(1) and Q(0);
end D;