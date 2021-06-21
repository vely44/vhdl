library ieee;
use ieee.std_logic_1164.all;

entity Visualisation is									
Port(	X_Object			:	in integer;	
		Y_Object			:	in integer;	
		X_Object_Width :	in integer;	
		Y_Object_Width	:	in integer;	
		
		X_In	:	in integer;
		Y_In	:	in integer;
		
		Colour	:	out std_logic);
end;

architecture ShowPixels of Visualisation is
begin

PROCESS(X_In, Y_In)
	
	BEGIN	
	
		IF (X_In >= X_Object) AND
			(X_in <= X_Object+X_Object_Width) AND
			(Y_In >= Y_Object) AND
			(Y_in <= Y_Object+Y_Object_Width) THEN	
				
				Colour <= '1';
		ELSE
				Colour <= '0';
		END IF;
		
END PROCESS;
end;
