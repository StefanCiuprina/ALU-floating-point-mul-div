library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity NumberRegister is
port(
	moveUpDown : in STD_LOGIC;
	updown : in STD_LOGIC;
	reset : in STD_LOGIC;
	nextDigit : in STD_LOGIC;
	number : out STD_LOGIC_VECTOR(15 downto 0);
	
	decimalPointMover : in STD_LOGIC;
	decimalPointLocation : out STD_LOGIC_VECTOR(2 downto 0);
	currentDigit : out STD_LOGIC_VECTOR(1 downto 0)
	);
end NumberRegister;

architecture D of NumberRegister is

	signal sel, updown_signal, o0, o1, o2, o3 : STD_LOGIC_VECTOR(1 downto 0);
	
	component CounterModulo_4 is
	port(
		moveUp : in STD_LOGIC;
		reset : in STD_LOGIC;
		TC : out STD_LOGIC; --terminal count
		Q : out STD_LOGIC_VECTOR(1 downto 0)
		);
	end component;
	
	component CounterModulo_10 is
	port(
		moveUpDown : in STD_LOGIC;
		updown : in STD_LOGIC;
		reset : in STD_LOGIC;
		Q : out STD_LOGIC_VECTOR(3 downto 0)
		);
	end component;
	
	component dmux_2to1_2bits is
	port(
		input : in STD_LOGIC_VECTOR(1 downto 0);
		sel : in STD_LOGIC_VECTOR(1 downto 0);
		o0 : out STD_LOGIC_VECTOR(1 downto 0);
		o1 : out STD_LOGIC_VECTOR(1 downto 0);
		o2 : out STD_LOGIC_VECTOR(1 downto 0);
		o3 : out STD_LOGIC_VECTOR(1 downto 0)
		);
	end component;
	
	component CounterModulo_5 is
	port(
		moveUp : in STD_LOGIC;
		reset : in STD_LOGIC;
		Q : out STD_LOGIC_VECTOR(2 downto 0)
		);
	end component;

begin
	updown_signal(0) <= updown;
	updown_signal(1) <= moveUpDown;
	
	C4_1 : CounterModulo_4
	port map(
			moveUp => nextDigit,
			reset => reset,
			Q => sel
			);		 
			
	DMUX_1 : dmux_2to1_2bits
	port map(
			input => updown_signal,
			sel => sel,
			o0 => o0,
			o1 => o1,
			o2 => o2,
			o3 => o3
			);
	
	C10_1 : CounterModulo_10
	port map(
			moveUpDown => o0(1),
			updown => o0(0),
			reset => reset,
			Q => number(15 downto 12)
			); 
			
	C10_2 : CounterModulo_10
	port map(
			moveUpDown => o1(1),
			updown => o1(0),
			reset => reset,
			Q => number(11 downto 8)
			);
			
	C10_3 : CounterModulo_10
	port map(
			moveUpDown => o2(1),
			updown => o2(0),
			reset => reset,
			Q => number(7 downto 4)
			);
			
	C10_4 : CounterModulo_10
	port map(
			moveUpDown => o3(1),
			updown => o3(0),
			reset => reset,
			Q => number(3 downto 0)
			);
			
	C5_1 : CounterModulo_5
	port map(
			moveUp => decimalPointMover,
			reset => reset,
			Q => decimalPointLocation
			);
	
	currentDigit <= sel;
	
end D;