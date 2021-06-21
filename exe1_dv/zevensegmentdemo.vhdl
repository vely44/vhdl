 
-----------------------------------------------------------
--Circuit Design and Simulation with VHDL, 2nd edition
--V. A. Pedroni, MIT Press, 2010
--Playing with an SSD using a timed state machine
-----------------------------------------------------------
ENTITY little_game IS
 GENERIC (
  fclk: INTEGER := 50_000; --clk frequency (kHz)
  T1: INTEGER := 120;    --long delay (ms)
  T2: INTEGER := 40);    --short delay (ms)
 PORT (
  clk, stop, rst: IN BIT;
  ssd: OUT BIT_VECTOR(6 DOWNTO 0));
END little_game;
-----------------------------------------------------------
ARCHITECTURE fsm OF little_game IS 
 CONSTANT time1: INTEGER := fclk*T1; 
 CONSTANT time2: INTEGER := fclk*T2;
 SIGNAL delay: INTEGER RANGE 0 TO time1;
 TYPE state IS (a, ab, b, bc, c, cd, d, de, e, ef, f, fa); 
 SIGNAL pr_state, nx_state: state;
BEGIN
 -------Lower section of FSM:------------
 PROCESS (clk, stop, rst)
  VARIABLE count: INTEGER RANGE 0 TO time1;
 BEGIN
  IF (rst='1') THEN
   pr_state <= a;
  ELSIF (clk'EVENT AND clk='1') THEN
   IF (stop='0') THEN
    count := count + 1;
    IF (count=delay) THEN
     count := 0;
     pr_state <= nx_state;
    END IF;
   END IF;
  END IF;
 END PROCESS;
 -------Upper section of FSM:------------
 PROCESS (pr_state)
 BEGIN
  CASE pr_state IS
   WHEN a => 
    ssd <= "0111111"; --decimal 63
    delay <= time1;
    nx_state <= ab; 
   WHEN ab => 
    ssd <= "0011111"; --decimal 31
    delay <= time2;
    nx_state <= b; 
   WHEN b => 
    ssd <= "1011111";  --decimal 95
    delay <= time1;
    nx_state <= bc; 
   WHEN bc => 
    ssd <= "1001111";  --decimal 79
    delay <= time2;
    nx_state <= c; 
   WHEN c => 
    ssd <= "1101111";  --decimal 111
    delay <= time1; 
    nx_state <= cd;   
   WHEN cd => 
    ssd <= "1100111";  --decimal 103
    delay <= time2;
    nx_state <= d;  
	   WHEN d => 
    ssd <= "1110111";  --decimal 119
    delay <= time1;
    nx_state <= de; 
   WHEN de => 
    ssd <= "1110011";  --decimal 115
    delay <= time2; 
    nx_state <= e; 
   WHEN e => 
    ssd <= "1111011";  --decimal 123
    delay <= time1;
    nx_state <= ef; 
   WHEN ef => 
    ssd <= "1111001";  --decimal 121
    delay <= time2;
    nx_state <= f; 
   WHEN f => 
    ssd <= "1111101";  --decimal 125
    delay <= time1;
    nx_state <= fa;
   WHEN fa => 
    ssd <= "0111101";  --decimal 61
    delay <= time2;
    nx_state <= a;
  END CASE; 
 END PROCESS; 
END fsm;
----------------------------------------------------------- 
 