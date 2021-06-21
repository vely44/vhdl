LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
USE work.my_function.all;

-------------------------------------------------------

ENTITY Assignment1 IS

      PORT( SW : IN STD_LOGIC_VECTOR (9 DOWNTO 0);
				LEDR: OUT STD_LOGIC_VECTOR(9 DOWNTO 0); 
		      HEX0: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
				HEX1: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
				HEX2: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
				HEX3: OUT STD_LOGIC_VECTOR (6 DOWNTO 0));
			
END Assignment1; 

--------------------------------------------------------

ARCHITECTURE Assignment1 OF Assignment1 IS
signal number : integer;
signal digit000X : integer;
signal digit00X0 : integer;
signal digit0X00 : integer;
signal digitX000 : integer;

BEGIN
  LEDR<=SW;
  number<=conv_integer(SW);
  digit000X<=number rem 10;
  HEX0<= integer_to_ssd(digit000X);
  digit00X0<=(number/10) rem 10;
  HEX1<= integer_to_ssd(digit00X0);
  digit0X00<=(number/100) rem 10;
  HEX2<= integer_to_ssd(digit0X00);
  digitX000<=(number/1000) rem 10;
  HEX3<= integer_to_ssd(digitX000);
  

  
END ARCHITECTURE Assignment1;
--------------------------------------------------------