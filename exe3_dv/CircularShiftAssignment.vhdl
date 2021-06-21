 ------- Opdracht 3/ Assignment 3 DSDL practicum
 ------- Altera DE10-Lite
 ------- ir drs E.J Boks, HAN Embedded Systems Engineering. https://ese.han.nl
 
 ------- Complete all code below

library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all; 
use work.my_function.all;
use work.Assignment3Package.all;

entity CircularShiftAssignment is

	generic(NumberOfSSDs : positive :=6);

		port(ADC_CLK_10 : in std_logic;
			  KEY : in std_logic_vector(1 downto 0);
			  SW  : in std_logic_vector(9 downto 0);
			  LEDR : out std_logic_vector(9 downto 0);
			  HEX0 : out std_logic_vector(0 to 7);  -- SSD0 (most right)
			  HEX1 : out std_logic_vector(0 to 7);
			  HEX2 : out std_logic_vector(0 to 7);
			  HEX3 : out std_logic_vector(0 to 7);
			  HEX4 : out std_logic_vector(0 to 7);
			  HEX5 : out std_logic_vector(0 to 7)); -- SSD6
end entity;


architecture CircularShiftAssignmentArch of CircularShiftAssignment is
	constant LoadButton : natural := 0;
	constant RotationDirectionButton : natural := 1;
	
	subtype rotor is std_logic_vector(0 to 5);
	constant loadPattern : rotor := (0=>'0', others => '1');
	
	signal rst,load : std_logic;
	signal active : boolean;
	
	signal startButton,pauseButton : std_logic;
	signal rotationClock : std_logic;
	
	type RotationType is (AntiClockWise,ClockWise);
	
	signal rotationDirection : RotationType;
	signal ssdSegments : std_logic_vector(0 to ((NumberOfSSDs*6)-1));
	signal ssdkoppeling : std_logic_vector(0 to ((NumberOfSSDs*6)-1));
	
begin
	
	
		delay:clockDelay generic map (10_000_000,5) port map(ADC_CLK_10,rst, rotationClock);
		rotationDirection <=ClockWise when SW(9)='0' else AntiClockWise;
		gen: for i in 0 to 5 generate
			shift : circshift port map (rotationClock, load,loadPattern, ssdkoppeling((i*6) to (i*6)+5));
			with rotationDirection select 
			ssdSegments (i*6 to (i*6)+5) <= ssdkoppeling(i*6 to (i*6)+5) when ClockWise,
								reverseVector(ssdkoppeling(i*6 to (i*6)+5)) when AntiClockWise;
		end generate gen;
-- Remove this assert when inserting your code.

	rst <= SW(0);
	load <= SW(1);
	LEDR(0) <= rotationClock;
	LEDR(1) <= SW(1);
	LEDR(2) <= SW(2);	
	HEX0(6 to 7) <= (others => '1');
	HEX1(6 to 7) <= (others => '1');
	HEX2(6 to 7) <= (others => '1');
	HEX3(6 to 7) <= (others => '1');
	HEX4(6 to 7) <= (others => '1');
	HEX5(6 to 7) <= (others => '1');
	HEX0(0 to 5) <= (ssdSegments(0 to 5));
	HEX1(0 to 5) <= ssdSegments(6 to 11);
	HEX2(0 to 5) <= ssdSegments(12 to 17);
	HEX3(0 to 5) <= ssdSegments(18 to 23);
	HEX4(0 to 5) <= ssdSegments(24 to 29);
	HEX5(0 to 5) <= ssdSegments(30 to 35);

end architecture;


