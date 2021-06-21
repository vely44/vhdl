library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RectanglesOnScreen is		
Port(	X_Input						:	in integer;
		Y_Input						:	in integer;
		Refresh						:	in std_logic;
		Red_Out						:	out std_logic;
		Green_Out					:	out std_logic;
		Blue_Out						:	out std_logic);
end;


architecture DefineRectangles of RectanglesOnScreen is

constant	X_LeftRect 				:	integer := 20;	--random value 
constant	Y_LeftRect  			:	integer := 190;	--random value
constant	X_LeftRect_Width 		:	integer := 50;	--about 1/4 of paddle height
constant	Y_LeftRect_Width 		:	integer := 100;--about 1/5 of screen height

constant	X_MiddleRect						:	integer := 300;--random value
constant	Y_MiddleRect 						:	integer := 190;--random value
constant	X_MiddleRect_Width 				:	integer := 50;	--about 1/4 of paddle height
constant	Y_MiddleRect_Width 				:	integer := 100;	--about 1/4 of paddle height	

constant	X_RightRect 				:	integer := 570;--random value
constant	Y_RightRect 				:	integer := 190;	--random value
constant	X_RightRect_Width 		:	integer := 50;	--about 1/4 of paddle height
constant	Y_RightRect_Width 		:	integer := 100;--about 1/4 of screen height

signal	ColourLeftRect				: std_logic;
signal	ColourMiddleRect			: std_logic;
signal	ColourRightRect			: std_logic;


component Visualisation is									
Port(	X_Object			:	in integer;	
		Y_Object			:	in integer;	
		X_Object_Width :	in integer;	
		Y_Object_Width	:	in integer;	
		
		X_In	:	in integer;
		Y_In	:	in integer;
		
		Colour	:	out std_logic);
end component;
		
		
begin
													
DrawLeftRect		: Visualisation port map (X_LeftRect, Y_LeftRect, X_LeftRect_Width, Y_LeftRect_Width, X_Input, Y_Input, ColourLeftRect);
DrawMiddleRect		: Visualisation port map (X_MiddleRect, Y_MiddleRect, X_MiddleRect_Width, Y_MiddleRect_Width, X_Input, Y_Input, ColourMiddleRect);
DrawRightRect	   : Visualisation port map (X_RightRect, Y_RightRect, X_RightRect_Width, Y_RightRect_Width, X_Input, Y_Input, ColourRightRect);

Red_Out <= ColourLeftRect;
Green_Out <= ColourMiddleRect;
Blue_Out <= ColourRightRect;
end;
