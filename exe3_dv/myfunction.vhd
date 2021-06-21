LIBRARY ieee;
USE ieee.std_logic_1164.all;

PACKAGE my_function IS
      FUNCTION integer_to_ssd (input: integer;
											reverseNecessary : boolean)
		RETURN STD_LOGIC_VECTOR;								
		
		FUNCTION reverseVector(a: in STD_LOGIC_VECTOR) 
		RETURN STD_LOGIC_VECTOR;									
END my_function;

--------------------------------------------------------------------------

PACKAGE BODY my_function IS
      FUNCTION integer_to_ssd (input: integer; 
		reverseNecessary: boolean)
		RETURN STD_LOGIC_VECTOR
		  IS VARIABLE output: STD_LOGIC_VECTOR (7 DOWNTO 0);
		  
		BEGIN
		  CASE input IS
		      WHEN 0 => output := "10000001";   --"0" on SSD
				WHEN 1 => output := "11110011";   --"1" on SSD
				WHEN 2 => output := "01001001";   --"2" on SSD
				WHEN 3 => output := "01100001";   --"3" on SSD
				WHEN 4 => output := "00110011";   --"4" on SSD
				WHEN 5 => output := "00100101";   --"5" on SSD
				WHEN 6 => output := "00000101";   --"6" on SSD
				WHEN 7 => output := "11110001";   --"7" on SSD
				WHEN 8 => output := "00000001";   --"8" on SSD
				WHEN 9 => output := "00110001";   --"9" on SSD
				WHEN 10 => output := "00010001";   --"A" on SSD
				WHEN 11 => output := "00000111";   --"B" on SSD
				WHEN 12 => output := "10001101";   --"C" on SSD
				WHEN 13 => output := "01000011";   --"D" on SSD
				WHEN 14 => output := "00001101";   --"E" on SSD
				WHEN OTHERS => output := "00011101";   --"F" on SSD
			END CASE;
			
			RETURN output;
			
		END integer_to_ssd;
		
		FUNCTION reverseVector(a: in std_logic_vector)
			return std_logic_vector is
	variable result: std_logic_vector(a'RANGE);
	alias aa: std_logic_vector(a'REVERSE_RANGE) is a;
begin
  for i in aa'RANGE loop
    result(i) := aa(i);
  end loop;
  return result;
end; -- function reverse_any_vector
		
END PACKAGE BODY my_function;
------------------------------------------------------------------