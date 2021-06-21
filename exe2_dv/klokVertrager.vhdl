 ------- Opdracht 2 / Assignment 2 DSDL practicum
 ------- Altera DE10-Lite
 ------- ir drs E.J Boks, HAN Embedded Systems Engineering. https://ese.han.nl
library ieee;
use ieee.std_logic_1164.all;
use work.all;

-- This entity is used below. It transforms 12 KHz ==> desired frequency
entity clockDelay is

	generic(desiredFreq: integer := 60;       -- 60 Hz
			 inClockFreq: natural := 12000);  -- 12kHz Hz
			
	port 
	(
		clk,rst  : in  std_logic;
		uitKlok  : buffer std_logic
	);
	
end entity;

architecture behaviour of clockDelay is
	constant maxCount : natural := inClockFreq/desiredFreq;
begin
	
	process(clk)
		variable temp: integer range 0 to maxCount;

		begin
			if (rst= '1') then
				temp:=0;
			elsif(clk'event and clk = '1') then
				temp := temp + 1;
				if (temp = maxCount) then
					temp := 0;
					uitKlok <= not uitKlok;
				end if;
			end if;
		
	 end process;
	
end architecture;


library ieee;
use ieee.std_logic_1164.all;
use work.all;

-- This is the clock that transforms 10 MHz to 60 Hz.
-- Internally two clock dividers are present :  10M --> 12k and 12k --> 60
-- This entity is used as component in Intersection (Top Level file).
entity pllClockDelay is

	generic(desiredFreq: integer := 60);  -- 60 Hz
			
	port 
	(
		clk,rst      : in  std_logic;
		trafficClock : buffer std_logic
	);
	
end entity;

architecture gedrag of pllClockDelay is
	constant pllKlokFreq   : natural := 12000;
	constant klokTopWaarde : natural := pllKlokFreq/desiredFreq;
	signal pllLocked : std_logic;
	signal pllclockDelayKlok : std_logic;
	
	-- 10 MHz ==> 12 KHz componenten (IP CATALOG PLL Wizard)
	component pllKlok is
	port
	(
		areset		: in std_logic  := '0';
		inclk0		: in std_logic  := '0';
		c0		: out std_logic ;
		locked		: out std_logic 
	);
	end component;
	
	-- 12 KHz ==> desired frequency (defined above)
	component clockDelay is

	generic(desiredFreq: integer := 60;       -- 60 Hz
			  inClockFreq: natural := 12000);  -- 12000 Hz
			
	port 
	(
		clk,rst  : in  std_logic;
		uitKlok  : buffer std_logic
	);
	
  end component;

begin

-- Link your componentens and signals here.
first_delay : clockDelay generic map (desiredFreq, pllKlokFreq) port map (clk=>pllclockDelayKlok,rst=>rst,uitKlok=>trafficClock); 
second_delay : pllklok port map(areset=>rst,inclk0=>clk,c0=>pllclockDelayKlok,locked=>pllLocked); 

end architecture;

