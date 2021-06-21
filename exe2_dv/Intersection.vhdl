 ------- Opdracht 2 / Assignment 2 DSDL practicum
 ------- Altera DE10-Lite
 ------- ir drs E.J Boks, HAN Embedded Systems Engineering. https://ese.han.nl
 
-- Pedroni voorbeeld 6.6 op bladzijde 166
-- Enigzins aangepast om te koppelen aan HW pinnen van de MAX10 op het DE10-Lite bord.


library ieee;
use ieee.std_logic_1164.all;

entity Intersection is

	port(ADC_CLK_10 : in std_logic;
		KEY : in std_logic_vector(1 downto 0);
		SW : in STD_LOGIC_VECTOR(9 DOWNTO 0);
		HEX2 : out std_logic_vector(7 downto 0); -- left light
		HEX3 : out std_logic_vector(7 downto 0); -- right light
		LEDR : out std_logic_vector(9 downto 0));
	
end entity Intersection;

architecture behaviour of Intersection is

	signal rst : std_logic;
	signal trafficClock,topclock : std_logic;
	signal seconds, fivehz : std_logic;
	
	constant green : natural  := 0;
	constant orange : natural := green+1;
	constant red : natural   := orange+1;
	
	signal vk1,vk2 : std_logic_vector(2 downto 0);
	
	component clockDelay is

	generic(desiredFreq: integer := 60;       -- 60 Hz
			  inClockFreq: natural := 12000);  -- 12000 Hz
			
	port 
	(
		clk,rst  : in  std_logic;
		uitKlok  : buffer std_logic
	);
	
   end component;

	component pllClockDelay is

	generic(desiredFreq: integer := 60);  -- 12 kHz
			
	port 
	(
		clk,rst : in std_logic;
		trafficClock : out std_logic
	);

	end component;
	
	component tlc IS
		GENERIC ( 
				timeRG: POSITIVE := 1800;  --30s with 60Hz clock  
				timeRY: POSITIVE := 300;  --5s with 60Hz clock
				timeGR: POSITIVE := 2700;  --45s with 60Hz clock
				timeYR: POSITIVE := 300;  --5s with 60Hz clock
				timeTEST: POSITIVE := 60;  --1s with 60Hz clock
				timeMAX: POSITIVE := 2700); --max of all above
		
		PORT (
			clk, stby, test: IN STD_LOGIC;
			r1, r2, y1, y2, g1, g2: OUT STD_LOGIC );
	END component;

	

begin

	totalDelay : pllClockDelay generic map(60) port map(ADC_CLK_10,rst,topClock);
	secondsclock : clockDelay generic map(1,60) port map(trafficclock,rst,seconds);
	fivehzclock : clockDelay generic map(5,60) port map(trafficclock,rst,fivehz);
	traffic : tlc port map(trafficClock, rst, SW(1),vk1(red),vk2(red),vk1(orange),vk2(orange),vk1(green),vk2(green));

	-- link own names to board SSD pins, clock and reset pins.
	rst<=SW(0);
	trafficClock <= topClock when KEY(0)='1' else '0';
	
	
	HEX2(0) <= not vk1(red);
	HEX2(6) <= not vk1(orange);
	HEX2(3) <= not vk1(green);
	HEX2(2 downto 1) <= (others => '1');
	HEX2(5 downto 4) <= (others => '1');
	HEX2(7) <= '1';
	
	HEX3(0) <= not vk2(red);
	HEX3(6) <= not vk2(orange);
	HEX3(3) <= not vk2(green);
	HEX3(2 downto 1) <= (others => '1');
	HEX3(5 downto 4) <= (others => '1');
	HEX3(7) <= '1';
	
	LEDR(0) <= '1' when SW(0) = '1' else '0';
	LEDR(1) <= '1' when SW(1) = '1' else '0';
	LEDR(2) <= '1' when trafficClock = '0' else '0';
	LEDR(9) <= seconds when SW(1) = '0' else fivehz;
	
	
	
end architecture;

