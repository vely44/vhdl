-- VHDL hulpspulletjes
 
LIBRARY ieee; 
use ieee.std_logic_1164.all; 

package HulpFunkties is
	-- Deze funktie draait een LSB .. MSB vector om naar MSB .. LSB 
	function draaiOmVector(a: in std_logic_vector) return std_logic_vector;
end HulpFunkties;
 
package body HulpFunkties is

function draaiOmVector(a: in std_logic_vector)
return std_logic_vector is
  variable result: std_logic_vector(a'RANGE);
  alias aa: std_logic_vector(a'REVERSE_RANGE) is a;
begin
  for i in aa'RANGE loop
    result(i) := aa(i);
  end loop;
  return result;
end; -- function reverse_any_vector

end HulpFunkties;

-----------------------------------------

 
  