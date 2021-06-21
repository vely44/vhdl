 ------- Opdracht 3/ Assignment 3 DSDL practicum
 ------- Altera DE10-Lite
 ------- ir drs E.J Boks, HAN Embedded Systems Engineering. https://ese.han.nl
 
 ------- Complete all code below
 
library ieee;
use ieee.std_logic_1164.all;
use work.all;

entity clockDelay is

	generic(inClockFreq    : natural := 100;
	        desiredClockFreq : natural := 10);  
			
	port 
	(
		clk,rst  : in  std_logic;
		outClock  : buffer std_logic
	);
	
end entity;

architecture gedrag of clockDelay is
	
begin

	process(clk,rst)
		variable counter1: natural range 0 to inClockFreq:=0;
	begin
		
		if (rst='1') then
			counter1:=0;
			outClock <= '0';
		elsif (rising_edge(clk)) then
			counter1:=counter1+desiredClockFreq;
			if (counter1=inClockFreq) then
				counter1 := 0;
				outClock <= not outClock;
			end if;
		end if;	
	end process;
	
end architecture;


