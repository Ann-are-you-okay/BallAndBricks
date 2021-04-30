LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY BallAndBricks IS
	PORT (
		clk50_in : IN STD_LOGIC;
		red_out : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
		green_out : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
		blue_out : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
		hs_out : OUT STD_LOGIC;
		clk25_out : OUT STD_LOGIC;
		sync : OUT STD_LOGIC;
		blank : OUT STD_LOGIC;
		vs_out : OUT STD_LOGIC;
		leftBtn : IN STD_LOGIC;
		rightBtn : IN STD_LOGIC

	);
END BallAndBricks;
ARCHITECTURE Design OF BallAndBricks IS
	SIGNAL clk25 : STD_LOGIC;
	SIGNAL horizontal_counter : STD_LOGIC_VECTOR (9 DOWNTO 0) := "0000000000";
	SIGNAL vertical_counter : STD_LOGIC_VECTOR (9 DOWNTO 0) := "0000000000";
	SIGNAL x : STD_LOGIC_VECTOR (9 DOWNTO 0) := "0000000000";
	SIGNAL y : STD_LOGIC_VECTOR (9 DOWNTO 0) := "0000000000";
	SIGNAL writeEnable : STD_LOGIC;
	SIGNAL paddlePos : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0100100000";
	SIGNAL prescaler : STD_LOGIC_VECTOR (18 DOWNTO 0);
	SIGNAL gameClock : STD_LOGIC;

	SIGNAL bricks0 : STD_LOGIC_VECTOR(0 TO 8) := "000000000";
	SIGNAL bricks1 : STD_LOGIC_VECTOR(0 TO 8) := "000000000";
	SIGNAL bricks2 : STD_LOGIC_VECTOR(0 TO 8) := "000011100";
	SIGNAL bricks3 : STD_LOGIC_VECTOR(0 TO 8) := "000001100";
	SIGNAL bricks4 : STD_LOGIC_VECTOR(0 TO 8) := "000000000";

BEGIN
	clk25_out <= clk25;
	sync <= '0';
	blank <= '1';
	-- Split the 50MHz clock into VGA clock and Game clock
	PROCESS (clk50_in)
	BEGIN
		IF clk50_in'EVENT AND clk50_in = '1' THEN
			prescaler <= prescaler + 1;

			IF (prescaler = "1000000000000000000") THEN
				gameClock <= '1';
				prescaler <= "0000000000000000000";
			ELSE
				gameClock <= '0';
			END IF;

			IF (clk25 = '0') THEN
				clk25 <= '1';
			ELSE
				clk25 <= '0';
			END IF;
		END IF;
	END PROCESS;

	-- VGA clock/process
	PROCESS (clk25)
	BEGIN
		IF clk25'EVENT AND clk25 = '1' THEN

			-- Seperate x and y pixel counters
			IF ((horizontal_counter < 640)
				AND (vertical_counter < 480))
				THEN
				writeEnable <= '1';
				y <= vertical_counter;
				x <= (horizontal_counter);
			ELSE
				writeEnable <= '0';
			END IF;

			-- Draw play area
			IF (((x >= 50)
				AND (x < 600)
				AND (y >= 0)
				AND (y < 480))
				AND (writeEnable = '1'))
				THEN
				red_out <= "0110100111";
				green_out <= "0110011111";
				blue_out <= "0110000111";
			ELSE
				red_out <= "0000000000";
				green_out <= "0000000000";
				blue_out <= "0000000000";
			END IF;

			-- Brick Layer 0 
			FOR i IN 0 TO 8 LOOP
				IF (bricks0(i) = '1') THEN
					IF ((writeEnable = '1') AND(x >= 60 + 60 * i) AND (x < 110 + 60 * i) AND (Y >= 10) AND (Y < 30))
						THEN
						red_out <= "1001000111";
						green_out <= "0001100011";
						blue_out <= "0001100111";
					END IF;
				END IF;
			END LOOP;

			-- Brick Layer 1 
			FOR i IN 0 TO 8 LOOP
				IF (bricks1(i) = '1') THEN
					IF ((writeEnable = '1') AND(x >= 60 + 60 * i) AND (x < 110 + 60 * i) AND (Y >= 40) AND (Y < 60))
						THEN
						red_out <= "1100011011";
						green_out <= "0100011011";
						blue_out <= "0000111011";
					END IF;
				END IF;
			END LOOP;

			-- Brick Layer 2 
			FOR i IN 0 TO 8 LOOP
				IF (bricks2(i) = '1') THEN
					IF ((writeEnable = '1') AND(x >= 60 + 60 * i) AND (x < 110 + 60 * i) AND (Y >= 70) AND (Y < 90))
						THEN
						red_out <= "1001110111";
						green_out <= "1000011011";
						blue_out <= "0010011011";
					END IF;
				END IF;
			END LOOP;

			-- Brick Layer 3 
			FOR i IN 0 TO 8 LOOP
				IF (bricks3(i) = '1') THEN
					IF ((writeEnable = '1') AND(x >= 60 + 60 * i) AND (x < 110 + 60 * i) AND (Y >= 100) AND (Y < 120))
						THEN
						red_out <= "0000101011";
						green_out <= "0101010011";
						blue_out <= "0000111011";
					END IF;
				END IF;
			END LOOP;

			-- Brick Layer 4 
			FOR i IN 0 TO 8 LOOP
				IF (bricks4(i) = '1') THEN
					IF ((writeEnable = '1') AND(x >= 60 + 60 * i) AND (x < 110 + 60 * i) AND (Y >= 130) AND (Y < 150))
						THEN
						red_out <= "0110110011";
						green_out <= "1011110011";
						blue_out <= "1111011011";
					END IF;
				END IF;
			END LOOP;

			-- Draw the paddle
			IF ((writeEnable = '1') AND(x >= paddlePos) AND (x < paddlePos + 75) AND (Y >= 440) AND (Y < 450))
				THEN
				red_out <= "1111111111";
				green_out <= "1111111111";
				blue_out <= "1111111111";
			END IF;

			-- Horizontal Sync
			IF ((horizontal_counter >= 656)
				AND (horizontal_counter < 752))
				THEN
				hs_out <= '0';
			ELSE
				hs_out <= '1';
			END IF;
			-- Vertical Sync
			IF ((vertical_counter >= 490)
				AND (vertical_counter < 492))
				THEN
				vs_out <= '0';
			ELSE
				vs_out <= '1';
			END IF;
			horizontal_counter <= horizontal_counter + 1;
			IF (horizontal_counter = 800) THEN
				vertical_counter <= vertical_counter + 1;
				horizontal_counter <= "0000000000";
			END IF;
			IF (vertical_counter = 525) THEN
				vertical_counter <= "0000000000";
			END IF;
		END IF;
	END PROCESS;

	-- Game clock/process
	PROCESS (gameClock)
	BEGIN
		IF gameClock'EVENT AND gameClock = '1' THEN
			-- If the left button was pressed
			IF (leftBtn = '0') THEN
				-- and if the paddle can move more left
				IF ((paddlePos - 1) >= 50) THEN
					-- Move the paddle left
					paddlePos <= paddlePos - 1;
				END IF;
			-- If the right button was pressed
			ELSIF (rightBtn = '0') THEN
				-- and if the paddle can move more right
				IF ((paddlePos + 1) < 600 - 75) THEN
					-- Move the paddle right
					paddlePos <= paddlePos + 1;
				END IF;
			END IF;
		END IF;
	END PROCESS;
END Design;