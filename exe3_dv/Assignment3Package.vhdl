------- Opdracht 3/ Assignment 3 DSDL practicum
------- Altera DE10-Lite
------- ir drs E.J Boks, HAN Embedded Systems Engineering. https://ese.han.nl
------- Bibliotheek met alle components die in dit projekt worden gebruikt
------- Library with all components that are used in this project.

library ieee; 
use ieee.std_logic_1164.all; 

package Assignment3Package is

	component circshift is

	generic(NumberOfElements : natural := 6);
		
	port(clk,load : in std_logic;
	     d: in std_logic_vector(0 to NumberOfElements-1);
		  q: buffer std_logic_vector(0 to NumberOfElements-1));
		  
	end component;

	component clockDelay is

	generic(inClockFreq    : natural := 100;
	        desiredClockFreq : natural := 10);  
			
	port 
	(
		clk,rst  : in  std_logic;
		outClock  : buffer std_logic
	);
	
	end component;
	
end Assignment3Package;
	

package body Assignment3Package is	

end Assignment3Package;


