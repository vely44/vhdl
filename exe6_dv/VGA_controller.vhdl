 ------- Opdracht 6 / Assignment 6 DSDL practicum
 ------- Altera DE10-Lite
 ------- ir drs E.J Boks, HAN Embedded Systems Engineering. https://ese.han.nl
 
-------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
-------------------------------------------------

ENTITY VGA_controller IS
	GENERIC (
		--control signal parameters
		Ha: INTEGER := 96; --Hpulse
		Hb: INTEGER := 144; --Hpulse+HBP
		Hc: INTEGER := 784; --Hpulse+HBP+Hactive
		Hd: INTEGER := 800; --Hpulse+HBP+Hactive+HFP
		Va: INTEGER := 2; --Vpulse
		Vb: INTEGER := 35; --Vpulse+VBP
		Vc: INTEGER := 515; --Vpulse+VBP+Vactive
		Vd: INTEGER := 525 --Vpulse+VBP+Vactive+VFP
	);
		
	PORT (
		--signal names
		MAX10_CLK1_50 : IN STD_LOGIC;
	   SW: IN std_logic_vector(4 downto 0);
		LEDR : out std_logic_vector(9 downto 0);
		VGA_HS, VGA_VS: out STD_LOGIC;
		VGA_R, VGA_G, VGA_B			: OUT STD_LOGIC_VECTOR(3 DOWNTO 0));
END VGA_controller;

-------------------------------------------------

ARCHITECTURE VGA_controller OF VGA_controller IS

	COMPONENT RectanglesOnScreen IS		
	PORT(	X_Input		:	in  integer;
			Y_Input		:	in  integer;
			Refresh		:	in  std_logic;
			Red_Out		:	out std_logic;
			Green_Out	:	out std_logic;
			Blue_Out		:	out std_logic);
	END COMPONENT;
	
	COMPONENT klok IS
	PORT
	(
		areset		: IN STD_LOGIC  := '0';
		inclk0		: IN STD_LOGIC  := '0';
		c0				: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC 
	);
	END COMPONENT;


	
	signal pixel_clk : STD_LOGIC;
	
	SIGNAL X_Input	 	:  integer;
	SIGNAL Y_Input	  	:  integer;
	SIGNAL Refresh 	:  std_logic := '0';
	SIGNAL Red_Out		:	std_logic;
	SIGNAL Green_Out	:	std_logic;
	SIGNAL Blue_Out 	:	std_logic;
	
	signal onOff,red_switch, green_switch, blue_switch: std_logic;
	SIGNAL Hactive, Vactive: STD_LOGIC;
BEGIN

	-- koppeling van de schakelaars
	red_switch <= SW(4);
	green_switch <= SW(3);
	blue_switch <= SW(2);
	onOff <= SW(0);
	
	LEDR(8 downto 5) <= (others => '0');
	LEDR(4) <= red_switch;
	LEDR(3) <= green_switch;
	LEDR(2) <= blue_switch;
	LEDR(1) <= '0';
	LEDR(0) <= onOff;
	
	
	---------------------------------------------
	---- Part 0 : The clock : pixel clock (50MHz->25MHz)
	---------------------------------------------
	clock_25M : klok port map(areset=>not onOff, inclk0=> MAX10_CLK1_50, c0=>pixel_clk, locked=>LEDR(9));
		
	---------------------------------------
	--Part 1: CONTROL GENERATOR
	---------------------------------------------
	
	--Horizontal signals generation
	PROCESS (onOff,pixel_clk)
		VARIABLE Hsigcount: INTEGER RANGE 0 TO Hd;
	BEGIN
		
		IF (pixel_clk'EVENT AND pixel_clk = '1') THEN
		
			Hsigcount := Hsigcount + 1;
			
			IF (Hsigcount = Ha) THEN
				VGA_HS <= '1';
				
			ELSIF (Hsigcount = Hb) THEN
				Hactive <= '1';
				
			ELSIF(Hsigcount = Hc) THEN
					Hactive <= '0';
					
			ELSIF(Hsigcount = Hd) THEN
					VGA_HS <= '0';
					Hsigcount := 0;
				
			END IF;
		
		END IF;
		
	END PROCESS;
	
	--Vertical signals generation
	PROCESS(onOff,VGA_HS)
		VARIABLE Vsigcount: INTEGER RANGE 0 to Vd;
	BEGIN
	
		IF (VGA_HS'EVENT AND VGA_HS = '0') THEN
			Vsigcount := Vsigcount + 1;
				
			IF(Vsigcount = Va)THEN
				VGA_VS <= '1';
				
			ELSIF(Vsigcount = Vb) THEN
				Vactive <= '1';
			
			ELSIF(Vsigcount = Vc) THEN
				Vactive <= '0';
					
			ELSIF(Vsigcount = Vd) THEN
				VGA_VS <= '0';
				Vsigcount := 0;
					
			END IF;
			
		END IF;	
		
	END PROCESS;
	
	--Display enable generation
	-- dena <= Hactive AND Vactive;
	
	---------------------------------------------
	--Part 2: IMAGE GENERATOR
	---------------------------------------------
	PROCESS (Hactive, Vactive,  VGA_HS, VGA_VS, pixel_clk, 
			   blue_switch, red_switch, green_switch,
				Green_Out,Red_Out,Blue_Out)
		VARIABLE xCord: INTEGER RANGE 0 TO Hd; -- Counter for the x coördinate
		VARIABLE yCord: INTEGER RANGE 0 TO Vd; -- Counter for the y coördinate
	BEGIN
		IF (pixel_clk'EVENT AND pixel_clk='1') THEN
			IF (Hactive='1') THEN -- Horizontal line isn't done yet
				xCord := xCord + 1;
			ELSE -- The horizontal line is filled
				xCord := 0; -- Make the xCord 0 again
			END IF;
		END IF;
		IF (VGA_HS'EVENT AND VGA_HS='1') THEN
				IF (Vactive='1') THEN -- There is one horizontal line
					Refresh <= '0';
					yCord := yCord + 1;
				ELSE
					Refresh <= '1';
					yCord := 0;
				END IF;
		END IF;
		
		X_Input <= xCord;
		Y_Input <= yCord;
		
		--green
		IF (green_switch = '1') THEN
			VGA_G <= (others => Green_Out);
		ELSE
			VGA_G <= (others => '0');
		END IF;
		
		--red
		IF (red_switch = '1') THEN
			VGA_R <= (others=>Red_Out);
		ELSE
			VGA_R <= (others => '0');
		END IF;
		
		--blue
		IF (blue_switch = '1') THEN
			VGA_B <= (others=>Blue_Out);
		ELSE
			VGA_B <= (others => '0');
		END IF;

	END PROCESS;
	
DrawRectangles : RectanglesOnScreen port map(X_Input, Y_Input, Refresh, Red_Out, Green_Out, Blue_Out);
	
END VGA_controller;
-------------------------------------------------

