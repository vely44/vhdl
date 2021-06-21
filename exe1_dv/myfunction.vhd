LIBRARY ieee;
USE ieee.std_logic_1164.all;

PACKAGE my_function IS
      FUNCTION integer_to_ssd (SIGNAL input: integer)
		RETURN STD_LOGIC_VECTOR;
END my_function;

--------------------------------------------------------------------------

PACKAGE BODY my_function IS
      FUNCTION integer_to_ssd (SIGNAL input: integer)
		RETURN STD_LOGIC_VECTOR
		  IS VARIABLE output: STD_LOGIC_VECTOR (6 DOWNTO 0);
		  
		BEGIN
		  CASE input IS
		      WHEN 0 => output := "1000000";   --"0" on SSD
				WHEN 1 => output := "1111001";   --"1" on SSD
				WHEN 2 => output := "0100100";   --"2" on SSD
				WHEN 3 => output := "0110000";   --"3" on SSD
				WHEN 4 => output := "0011001";   --"4" on SSD
				WHEN 5 => output := "0010010";   --"5" on SSD
				WHEN 6 => output := "0000010";   --"6" on SSD
				WHEN 7 => output := "1111000";   --"7" on SSD
				WHEN 8 => output := "0000000";   --"8" on SSD
				WHEN 9 => output := "0011000";   --"9" on SSD
				WHEN 10 => output := "0001000";   --"A" on SSD
				WHEN 11 => output := "0000011";   --"B" on SSD
				WHEN 12 => output := "1000110";   --"C" on SSD
				WHEN 13 => output := "0100001";   --"D" on SSD
				WHEN 14 => output := "0000110";   --"E" on SSD
				WHEN OTHERS => output := "0001110";   --"F" on SSD
			END CASE;
			
			RETURN output;
			
		END integer_to_ssd;
		
END PACKAGE BODY my_function;
------------------------------------------------------------------