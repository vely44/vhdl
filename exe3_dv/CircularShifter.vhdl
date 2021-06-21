------- Opdracht 3/ Assignment 3 DSDL practicum
------- Altera DE10-Lite
------- ir drs E.J Boks, HAN Embedded Systems Engineering. https://ese.han.nl
------- Voorbeeld 8.2 uit het boek van Pedroni
------- Example 8.2 from Pedroni's book


----------- The multiplexer ----------------
library ieee; 
use ieee.std_logic_1164.all; 
entity mux is
	port(a,b,sel : in std_logic;
	     x: out std_logic);
end entity;

architecture muxarch of mux is
begin
	x <= a when sel='0' else b;
end architecture;



------------- The flip flop ----------------
library ieee; 
use ieee.std_logic_1164.all; 
entity flipflop is
	port(d,clk: in std_logic;
		  q: out std_logic);
end entity;

architecture flipfloparch of flipflop is
begin
	
	process(clk)
	begin
		if (clk'event and clk='1') then
				q <= d;
		end if;
	end process;
end architecture;


--------- The main code -----------
library ieee; 
use ieee.std_logic_1164.all; 
entity circshift is

	generic(NumberOfElements : natural := 6);
		
	port(clk,load : in std_logic;
	     d: in std_logic_vector(0 to NumberOfElements-1);
		  q: buffer std_logic_vector(0 to NumberOfElements-1));
		  
end entity;

architecture circshiftarch of circshift is
	
	constant AEgrens : natural := NumberOfElements-1;
	
	subtype roteerder is std_logic_vector(0 to AEGrens);
	
	signal rot: roteerder;

	component mux is
	port(a,b,sel : in std_logic;
	     x: out std_logic);
	end component;
	
	component flipflop is
	port(d,clk: in std_logic;
		  q: out std_logic);
	end component;
	
begin

	assert NumberOfElements > 1 
		report "NumberOfElements moet minimaal 2 zijn" 
		severity failure; -- minimum 2 elements !
		
	-- the first mux has a different pattern
	startmux : mux port map(a=>q(AEgrens),b=>d(0),sel=>load,x=>rot(0));
	
	-- use generate to create the rest of the muxes and dffs
	maakMuxen : for i in 1 to AEgrens generate
		muxen : mux port map (a=>q(i-1),b=>d(i),sel=>load,x=>rot(i));
	end generate maakMuxen;
	
	maakDffs : for i in 0 to AEgrens generate
		dff : flipflop port map (d=>rot(i),clk=>clk,q => q(i));
	end generate maakDffs;
	
end architecture;



