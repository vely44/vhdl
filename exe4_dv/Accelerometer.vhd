 ------- Opdracht 4 / Assignment 4 DSDL practicum
 ------- Altera DE10-Lite
 ------- ir drs E.J Boks, HAN Embedded Systems Engineering. https://ese.han.nl

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_signed.all;
LIBRARY work;
use work.my_function.all;

-------------------------------------------------------------
ENTITY Accelerometer IS
	PORT (MAX10_CLK1_50 : IN  		STD_LOGIC;
			GSENSOR_SCLK  : BUFFER 	STD_LOGIC;
			GSENSOR_SDI   : BUFFER 	STD_LOGIC;
			GSENSOR_SDO   : IN  		STD_LOGIC;
			GSENSOR_CS_N  : BUFFER 	STD_LOGIC;
			GSENSOR_INT   : IN STD_LOGIC_VECTOR(2 DOWNTO 1);
			KEY 	: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			SW 	: in std_logic_vector(9 DOWNTO 0);
			LEDR  : OUT		STD_LOGIC_VECTOR (9 DOWNTO 0);
			GPIO : OUT STD_LOGIC_VECTOR(36 DOWNTO 0);
			HEX0 : out std_logic_vector(6 DOWNTO 0);  -- SSD0 (most right)
			HEX1 : out std_logic_vector(6 DOWNTO 0);  -- SSD1
			HEX2 : out std_logic_vector(6 DOWNTO 0);  -- SSD2
			HEX3 : out std_logic_vector(6 DOWNTO 0);  -- SSD3
			HEX4 : out std_logic_vector(6 DOWNTO 0);  -- SSD4
			HEX5 : out std_logic_vector(6 DOWNTO 0)); -- SSD5 (most left)
END Accelerometer;
-------------------------------------------------------------
ARCHITECTURE main OF Accelerometer IS

	TYPE state IS (idle,wr_setup,wr_addr,wr_data,wr_close,wait_rd,rd_setup,rd_addr,rd_data,rd_close,wait_int);
	signal prState	: state := idle;
	signal nxState	: state := idle;
	
	type Axis is (xaxis,yaxis,zaxis); 
	subtype Acceleration is integer range -4096 to 4095;
	type AccVektorType is array (Axis) of Acceleration;
	type AccDataValuesType is array(Axis) of std_logic_vector(12 downto 0);
	
	constant dataNumBits: integer := (6*8);
	signal accData : STD_LOGIC_VECTOR (dataNumBits-1 downto 0);
	
	signal accDataValues : AccDataValuesType;
	signal accVektor : AccVektorType;
	
	signal sclk : std_logic;
	signal sclk90 : std_logic; -- ask yourself : what is this signal opposed to sclk and why is it here?
	
	
	-- SPI : MS bit goes first = standard
	
	-- init data voor register 0x2c .. 0x3e
	-- last two bits are : write + multiple bytes
	constant adresNumBits : integer := 8;
	constant initAddress : std_logic_vector(adresNumBits-1 downto 0) := "01" & "101100"; --
	-- acc data come from registers 0x32 .. 0x37
	-- last two bits are : read + multiple bytes
	constant dataAdress  : std_logic_vector(adresNumBits-1 downto 0) := "11" & "110010";
	
	-- These are the init values for the ADXL345 from 0x2e onward. 
	constant initNumBits: integer := (6*8);
	signal initValues : STD_LOGIC_VECTOR (initNumBits-1 DOWNTO 0);
	
	shared variable i : natural range 0 to dataNumBits;
	signal timer : natural range 0 to dataNumBits;
	
	type DigitsType is array(1 to 6) of integer range -99 to 99;
	signal digits : DigitsType;
	
	COMPONENT Five_MHz_clock
		PORT (areset	: IN  STD_LOGIC  := '0';
				inclk0	: IN  STD_LOGIC  := '0';
				c0			: OUT STD_LOGIC  ;
				c1			: OUT STD_LOGIC  ;
				locked	: OUT STD_LOGIC );
	END COMPONENT;
	
BEGIN
					
	-- ADXL345 signalen naar GPIO voor Salaeae logic analyzer
	GPIO(0) <= GSENSOR_CS_N;
	GPIO(1) <= GSENSOR_SCLK;
	GPIO(2) <= GSENSOR_SDO;
	GPIO(3) <= GSENSOR_SDI;
	GPIO(4) <= GSENSOR_INT(1);
	GPIO(5) <= GSENSOR_INT(2);
	GPIO(36 downto 6) <= (others => '0');
	
	-- From the ADXL345 datasheet.
--	Table 7. Typical Current Consumption vs. Data Rate
--	Output Data Rate (Hz) Bandwidth (Hz) Rate Code IDD (μA) 
--	3200 1600 1111 140 
--	1600 800 1110 90
--	800 400 1101 140
--	400 200 1100 140
--	200 100 1011 140
--	100 50 1010 140
-----	50 25 1001 90
--	25 12.5 1000 60
--	12.5 6.25 0111 50
--	6.25 3.13 0110 45
--	3.13 1.56 0101 40
--	1.56 0.78 0100 34
--	0.78 0.39 0011 23
--	0.39 0.20 0010 23
--	0.20 0.10 0001 23 
--	0.10 0.05 0000 2

-- Fill the initValues vector with initialisation values for registers 0x2c and onwards through to 0x31;
initValues <= "00001001" & "00001000" & "10000000" & "00000000" & "00000000" & "00001000" ;
-- Remove this assert when inserting your code.
--
--Complete here!!!!
																							
	
	-----------------------PPL--------------------------------
	PPL : Five_MHz_clock PORT MAP (not KEY(0), MAX10_CLK1_50, sclk90, sclk, OPEN);

	
	-----------------Lower section of PSM---------------------
	PROCESS (sclk90, KEY)

	BEGIN 
			IF(KEY(0) = '0') THEN 
				prState <= idle;
				i := 0;
		--send data to spi
			ELSIF (sclk90'EVENT AND sclk90='1' ) THEN
				IF (i=timer-1) THEN
					prState <= nxState;
					i := 0;
				ELSE
					i := i+1;
				END IF;
		--Read data from spi
		ELSIF (sclk90'EVENT AND sclk90='0') THEN
			IF ( prState <= rd_data) THEN
				accData(dataNumBits-1-i) <= GSENSOR_SDO;
			END IF;
		END IF;	

	END PROCESS;
	
	-----------------Upper section of PSM---------------------
	PROCESS (prState, sclk90, KEY, GSENSOR_INT)
		variable ledstand: boolean := false;
	BEGIN
	
		CASE prState IS
			WHEN idle =>
				GSENSOR_CS_N <= '1';
				GSENSOR_SCLK <= '1';
				GSENSOR_SDI <= 'X';
				timer <= 1;
				nxState <= wr_setup;
			WHEN wr_setup => 
				GSENSOR_CS_N <= '0';
				timer <= 5;
				nxState <= wr_addr;
			WHEN wr_addr  =>
				GSENSOR_CS_N <= '0';
				GSENSOR_SCLK <= sclk;
				GSENSOR_SDI <= initAddress((adresNumBits - 1) - i);
				timer <= adresNumBits;
				nxState <= wr_data;
			WHEN wr_data  => 
				GSENSOR_CS_N <= '0';
				GSENSOR_SCLK <= sclk;
				GSENSOR_SDI <= initValues((initNumBits - 1) - i);
				timer <= initNumBits;
				nxState <= wr_close;	
			WHEN wr_close =>
				GSENSOR_CS_N <= '1';
				GSENSOR_SCLK <= '1';
				timer <= 1;
				nxState <= wait_rd;
			WHEN wait_rd  => 
			-- wait for interrupts here
				GSENSOR_CS_N <= '1';
				GSENSOR_SCLK <= '1';
				GSENSOR_SDI  <= '0';
				IF (GSENSOR_INT(1) = '1') THEN
					timer <= 1;	
					ledstand := true;
					nxState <= rd_setup;				 	
				END IF;
			WHEN rd_setup =>
				GSENSOR_CS_N <= '0';
				timer <= 5;		
				nxState <= rd_addr;	
			WHEN rd_addr  =>
				GSENSOR_CS_N <= '0';
				GSENSOR_SCLK <= sclk;
				GSENSOR_SDI  <= dataAdress((adresNumBits - 1) - i);
				timer <= adresNumBits;
				nxState <= rd_data;
			WHEN rd_data  =>
				GSENSOR_CS_N <= '0';
				GSENSOR_SCLK <= sclk;
				GSENSOR_SDI  <= 'X';
				timer <= dataNumBits;
				nxState <= rd_close;
			WHEN rd_close =>
				GSENSOR_CS_N <= '1';
				GSENSOR_SCLK <= '1';
				GSENSOR_SDI  <= 'X';
				timer <= 1;
				ledstand:= false;
				nxState <= wait_rd;
			WHEN OTHERS =>
				nxState <= wait_rd;
				timer <= 1;	
-- make the SWITCH CASE complete.

		END CASE;
				
		case ledstand is
			when false => LEDR(0) <= '0';
			when true  => LEDR(0) <= '1';
		end case;
						
						
				
	END PROCESS;
	
		-- incoming accData has MSbyte and LSByte swapped in order.
		-- swap them back here.
		accDataValues(xAxis) <= ( accData(dataNumBits-9 downto dataNumBits-13) & accData(dataNumBits-1 downto dataNumBits-8) );
		accDataValues(yAxis) <= ( accData(dataNumBits-25 downto dataNumBits-29) & accData(dataNumBits-17 downto dataNumBits-24) );
		accDataValues(zAxis) <= ( accData(dataNumBits-41 downto dataNumBits-45) & accData(dataNumBits-33 downto dataNumBits-40) );
		--  Fill accDataValues also for y and z axes.
		accVektor <= ( conv_integer(accDataValues(xAxis)),
							conv_integer(accDataValues(yAxis)), 
							conv_integer(accDataValues(zAxis)) );
							
	----------------------------------------------------------
	
	-- full res mode ==> 4 mg / LSB ==> 1g = 250 
	-- divide by 250/10 = 265 to show 0..9 for 0 .. 1g
							
	digits(1) <= abs ((2*accVektor(xaxis))/5) rem 10;
	digits(2) <= (2*accVektor(xaxis))/50;
	digits(3) <= abs ((2*accVektor(yaxis))/5) rem 10;
	digits(4) <= (2*accVektor(yaxis))/50;
	digits(5) <= abs ((2*accVektor(zaxis))/5) rem 10;
	digits(6) <= (2*accVektor(zaxis))/50;
	

	--  Do the same for y and z axes.

	HEX0 <= integer_to_ssd(digits(1),true);
	HEX1 <= integer_to_ssd(digits(2),true);
	HEX2 <= integer_to_ssd(digits(3),true);
	HEX3 <= integer_to_ssd(digits(4),true);
	HEX4 <= integer_to_ssd(digits(5),true);
	HEX5 <= integer_to_ssd(digits(6),true);
	
	
-- / Do the same for the y and z 7Seg.
-- / show the x axis on the individuaL LEDS.

	
END ARCHITECTURE;