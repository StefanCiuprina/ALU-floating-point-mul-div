library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Control is
port(
	load : in STD_LOGIC; --'1' will let the user load the numbers, '0' will output the result of the entered numbers
	reset, clr : in STD_LOGIC;
	sign1, sign2 : in STD_LOGIC;
	number1 : in STD_LOGIC; --'1' will load number1, '0' will load number 2				   
	updown : in STD_LOGIC; --'1' will go up, '0' will go down, for selecting the value of a digit
	moveUpDown : in STD_LOGIC; --will switch the number up or down, based on updown signal (on rising edge)
	nextDigit : in STD_LOGIC; --will go to the next digit (on rising edge)
	decimalPointMover : in STD_LOGIC; --move the decimal point to the left (on rising edge)
	op_type : in STD_LOGIC; --'1' for multiplication, '0' for division
	
	clk : in STD_LOGIC; --internal clock of the board
	
	done : out STD_LOGIC; --'1' when the operation is done
	
	currentDigit : out STD_LOGIC_VECTOR(3 downto 0);
							   					   
	sign : out STD_LOGIC;
	--7 segment display:		
	a_to_g : out STD_LOGIC_VECTOR(6 downto 0);
	dp : out STD_LOGIC;
	an : out STD_LOGIC_VECTOR(3 downto 0)
	);
end Control;

architecture Behavioral of Control is

	component ALU is
	port(
		input1, input2 : in STD_LOGIC_VECTOR(31 downto 0);
		clk, load, op_type : in STD_LOGIC; --op_type -> 0 = multiplication, 1 = division
		output : out STD_LOGIC_VECTOR(31 downto 0);
		done : out STD_LOGIC
		);
	end component;
	
	component BCDtoIEEE is
	port(
		BCD : in STD_LOGIC_VECTOR(15 downto 0);
		FractionalPointLocation : in STD_LOGIC_VECTOR(2 downto 0);
		load : in STD_LOGIC;
		sign : in STD_LOGIC; --'0' for +, '1' for -
		clk : in STD_LOGIC;
		IEEE : out STD_LOGIC_VECTOR(31 downto 0);
		done : out STD_LOGIC
		);
	end component;
	
	component IEEEtoBCD is
	port(
		IEEE : in STD_LOGIC_VECTOR(31 downto 0);
		load : in STD_LOGIC;
		clk : in STD_LOGIC;
		
		sign : out STD_LOGIC; --'0' for +, '1' for -
		BCD : out STD_LOGIC_VECTOR(15 downto 0);
		FractionalPointLocation : out STD_LOGIC_VECTOR(2 downto 0);														  										   							  				   
		done : out STD_LOGIC
		);
	end component;
	
	component NumberRegister is
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
	end component;
	
	component Debouncer is
	port(
		D : in std_logic; 
		CLK : in std_logic;
		Y : out std_logic
		);
	end component;
	
	component x7seg is
	port(
		CLK: in STD_LOGIC;
		clr: in STD_LOGIC;						  
		a_to_g: out STD_LOGIC_VECTOR(6 downto 0);
		dp : out STD_LOGIC;
		an: out STD_LOGIC_VECTOR(3 downto 0);
		x:  in STD_LOGIC_VECTOR(15 downto 0);
		dp_location : in STD_LOGIC_VECTOR(2 downto 0));
	end component;
	
	signal moveUpDown_signal, moveUpDown1_signal, moveUpDown2_signal : STD_LOGIC;
	signal nextDigit_signal, nextDigit1_signal, nextDigit2_signal : STD_LOGIC;
	signal decimalPointMover_signal, decimalPointMover1_signal, decimalPointMover2_signal : STD_LOGIC;
	signal decimalPointLocation1, decimalPointLocation2, decimalPointLocationOutput, dp_location : STD_LOGIC_VECTOR(2 downto 0);
	signal input1_BCD, input2_BCD, output_BCD, to_display : STD_LOGIC_VECTOR(15 downto 0);
	signal input1_IEEE, input2_IEEE, output_IEEE : STD_LOGIC_VECTOR(31 downto 0);
	signal load_bcd1, load_bcd2, load_alu, load_finalConv : STD_LOGIC;
	signal done_ieee1, done_ieee2, done_alu : STD_LOGIC;
	signal alu_loaded, finalConv_loaded : STD_LOGIC;
	signal currentDigit1, currentDigit2 : STD_LOGIC_VECTOR(1 downto 0);	
	signal sign_signal, signsignal : STD_LOGIC;

begin

	Debouncer1 : Debouncer port map(moveUpDown, clk, moveUpDown_signal);
	Debouncer2 : Debouncer port map(nextDigit, clk, nextDigit_signal);
	Debouncer3 : Debouncer port map(decimalPointMover, clk, decimalPointMover_signal);													 													  						 	  
	
	Number1_comp : NumberRegister port map(moveUpDown1_signal, updown, reset, nextDigit1_signal, input1_BCD, decimalPointMover1_signal, decimalPointLocation1, currentDigit1);
	Number2_comp : NumberRegister port map(moveUpDown2_signal, updown, reset, nextDigit2_signal, input2_BCD, decimalPointMover2_signal, decimalPointLocation2, currentDigit2);
	
	BCDtoIEEE1 : BCDtoIEEE port map(input1_BCD, decimalPointLocation1, load_bcd1, sign1, clk, input1_IEEE, done_ieee1);
	BCDtoIEEE2 : BCDtoIEEE port map(input2_BCD, decimalPointLocation2, load_bcd2, sign2, clk, input2_IEEE, done_ieee2);
	
	ALU_component : ALU port map(input1_IEEE, input2_IEEE, clk, load_alu, op_type, output_IEEE, done_alu);
	
	IEEEtoBCD_component : IEEEtoBCD port map(output_IEEE, load_finalConv, clk, sign_signal, output_BCD, decimalPointLocationOutput, done);
	
	Segment7 : x7seg port map(clk, clr, a_to_g, dp, an, to_display, dp_location);
	
	process(clk)
	begin
		if(rising_edge(clk)) then
			if(load = '1') then
				load_alu <= '0';
				alu_loaded <= '0';
				load_finalConv <= '0';
				finalConv_loaded <= '0';
				signsignal <= '0';
				if(number1 = '1') then
					load_bcd1 <= '1';
					load_bcd2 <= '0';
					moveUpDown1_signal <= moveUpDown_signal;
					moveUpDown2_signal <= '0';
					nextDigit1_signal <= nextDigit_signal;
					nextDigit2_signal <= '0';
					decimalPointMover1_signal <= decimalPointMover_signal;
					decimalPointMover2_signal <= '0';
					to_display <= input1_bcd;
					dp_location <= decimalPointLocation1;
					case currentDigit1 is
						when "00" => currentDigit <= "1000";
						when "01" => currentDigit <= "0100";
						when "10" => currentDigit <= "0010";
						when others => currentDigit <= "0001";
					end case;
				else
					load_bcd2 <= '1';
					load_bcd1 <= '0';
					moveUpDown2_signal <= moveUpDown_signal;
					moveUpDown1_signal <= '0';
					nextDigit2_signal <= nextDigit_signal;
					nextDigit1_signal <= '0';
					decimalPointMover2_signal <= decimalPointMover_signal;
					decimalPointMover1_signal <= '0';
					to_display <= input2_bcd;
					dp_location <= decimalPointLocation2;
					case currentDigit2 is
						when "00" => currentDigit <= "1000";
						when "01" => currentDigit <= "0100";
						when "10" => currentDigit <= "0010";
						when others => currentDigit <= "0001";
					end case;
				end if;
			else
				load_bcd2 <= '0';
				load_bcd1 <= '0';
				to_display <= output_bcd;
				dp_location <= decimalPointLocationOutput;
				currentDigit <= "0000";	
				signsignal <= sign1 xor sign2;
				if(done_ieee1 = '1' and done_ieee2 = '1') then
					if(alu_loaded = '0') then
						load_alu <= '1';	 
						alu_loaded <= '1';
					else
						load_alu <= '0';
						if(done_alu = '1') then
							if(finalConv_loaded = '0') then
								load_finalConv <= '1';
								finalConv_loaded <= '1';
							else
								load_finalConv <= '0';
							end if;
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;
	sign <= signsignal;

end Behavioral;