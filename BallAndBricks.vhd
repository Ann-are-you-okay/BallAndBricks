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
		rightBtn : IN STD_LOGIC;
		fireBtn : IN STD_LOGIC
	);
END BallAndBricks;
ARCHITECTURE Design OF BallAndBricks IS
	SIGNAL clk25 : STD_LOGIC;
	SIGNAL horizontal_counter : STD_LOGIC_VECTOR (9 DOWNTO 0) := "0000000000";
	SIGNAL vertical_counter : STD_LOGIC_VECTOR (9 DOWNTO 0) := "0000000000";
	SIGNAL x : STD_LOGIC_VECTOR (9 DOWNTO 0) := "0000000000";
	SIGNAL y : STD_LOGIC_VECTOR (9 DOWNTO 0) := "0000000000";
	SIGNAL writeEnable : STD_LOGIC;
	SIGNAL prescaler : STD_LOGIC_VECTOR (19 DOWNTO 0);
	SIGNAL gameClock : STD_LOGIC;

	SIGNAL paddlePos : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0100100000";
	SIGNAL ballPosX : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0101000000";
	SIGNAL ballPosY : STD_LOGIC_VECTOR(9 DOWNTO 0) := "0110011010";

	SIGNAL ballDx : STD_LOGIC_VECTOR(2 DOWNTO 0) := "001";
	SIGNAL ballDy : STD_LOGIC_VECTOR(2 DOWNTO 0) := "100";
	SIGNAL ballDirX : STD_LOGIC := '1';
	SIGNAL ballDirY : STD_LOGIC := '1';
	SIGNAL ballAttached : STD_LOGIC := '1';
	SIGNAL bricks1 : STD_LOGIC_VECTOR(0 TO 8) := "111111111";
	SIGNAL bricks2 : STD_LOGIC_VECTOR(0 TO 8) := "111111111";
	SIGNAL bricks3 : STD_LOGIC_VECTOR(0 TO 8) := "111111111";
	SIGNAL bricks4 : STD_LOGIC_VECTOR(0 TO 8) := "111111111";
	SIGNAL bricks5 : STD_LOGIC_VECTOR(0 TO 8) := "110011111";

	-- Constants for positions, sizes, etc
	CONSTANT leftBound : INTEGER := 50;
	CONSTANT rightBound : INTEGER := 600;
	CONSTANT topBound : INTEGER := 20;
	CONSTANT bottomBound : INTEGER := 460;
	CONSTANT paddleWidth : INTEGER := 75;
	CONSTANT paddleHeight : INTEGER := 10;
	CONSTANT paddlePosY : INTEGER := 420;
	CONSTANT ballSize : INTEGER := 10;
	CONSTANT brickHeight : INTEGER := 20;
	CONSTANT brickWidth : INTEGER := 50;

BEGIN
	clk25_out <= clk25;
	sync <= '0';
	blank <= '1';
	-- Split the 50MHz clock into VGA clock and Game clock
	PROCESS (clk50_in)
	BEGIN
		IF clk50_in'EVENT AND clk50_in = '1' THEN
			prescaler <= prescaler + 1;

			IF (prescaler = "11000000000000000000") THEN
				gameClock <= '1';
				prescaler <= "00000000000000000000";
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
			IF (((x >= leftBound)
				AND (x < rightBound)
				AND (y >= topBound)
				AND (y < bottomBound))
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

			-- Brick Layer 1 
			FOR i IN 0 TO 8 LOOP
				IF (bricks1(i) = '1') THEN
					IF ((writeEnable = '1') AND (x >= (leftBound + 10) + i * (brickWidth + 10)) AND (x < (leftBound + 10 + brickWidth) + i * (brickWidth + 10))
						AND (Y >= 1 * (topBound + 10)) AND (Y < 1 * (topBound + 10) + brickHeight))
						THEN
						red_out <= "1001000111";
						green_out <= "0001100011";
						blue_out <= "0001100111";
					END IF;
				END IF;
			END LOOP;

			-- Brick Layer 2
			FOR i IN 0 TO 8 LOOP
				IF (bricks2(i) = '1') THEN
					IF ((writeEnable = '1') AND (x >= (leftBound + 10) + i * (brickWidth + 10)) AND (x < (leftBound + 10 + brickWidth) + i * (brickWidth + 10))
						AND (Y >= 2 * (topBound + 10)) AND (Y < 2 * (topBound + 10) + brickHeight))
						THEN
						red_out <= "1100011011";
						green_out <= "0100011011";
						blue_out <= "0000111011";
					END IF;
				END IF;
			END LOOP;

			-- Brick Layer 3 
			FOR i IN 0 TO 8 LOOP
				IF (bricks3(i) = '1') THEN
					IF ((writeEnable = '1') AND (x >= (leftBound + 10) + i * (brickWidth + 10)) AND (x < (leftBound + 10 + brickWidth) + i * (brickWidth + 10))
						AND (Y >= 3 * (topBound + 10)) AND (Y < 3 * (topBound + 10) + brickHeight))
						THEN
						red_out <= "1001110111";
						green_out <= "1000011011";
						blue_out <= "0010011011";
					END IF;
				END IF;
			END LOOP;

			-- Brick Layer 4
			FOR i IN 0 TO 8 LOOP
				IF (bricks4(i) = '1') THEN
					IF ((writeEnable = '1') AND (x >= (leftBound + 10) + i * (brickWidth + 10)) AND (x < (leftBound + 10 + brickWidth) + i * (brickWidth + 10))
						AND (Y >= 4 * (topBound + 10)) AND (Y < 4 * (topBound + 10) + brickHeight))
						THEN
						red_out <= "0000101011";
						green_out <= "0101010011";
						blue_out <= "0000111011";
					END IF;
				END IF;
			END LOOP;

			-- Brick Layer 5 
			FOR i IN 0 TO 8 LOOP
				IF (bricks5(i) = '1') THEN
					IF ((writeEnable = '1') AND (x >= (leftBound + 10) + i * (brickWidth + 10)) AND (x < (leftBound + 10 + brickWidth) + i * (brickWidth + 10))
						AND (Y >= 5 * (topBound + 10)) AND (Y < 5 * (topBound + 10) + brickHeight))
						THEN
						red_out <= "0110110011";
						green_out <= "1011110011";
						blue_out <= "1111011011";
					END IF;
				END IF;
			END LOOP;

			-- Draw the paddle
			IF ((writeEnable = '1') AND (x >= paddlePos) AND (x < paddlePos + paddleWidth) AND (Y >= paddlePosY) AND (Y < paddlePosY + paddleHeight))
				THEN
				red_out <= "1111111111";
				green_out <= "1111111111";
				blue_out <= "1111111111";
			END IF;

			-- Draw the ball
			IF ((writeEnable = '1') AND (x >= ballPosX) AND (x < ballPosX + ballSize) AND (Y >= ballPosY) AND (Y < ballPosY + ballSize))
				THEN
				red_out <= "0000000000";
				green_out <= "0000000000";
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

			-- If the fire button was pressed and the ball was attached
			IF (fireBtn = '0' AND ballAttached = '1') THEN
				-- De-attach the ball
				ballAttached <= '0';
			END IF;

			-- If the left button was pressed
			IF (leftBtn = '0') THEN
				-- and if the paddle can move more left
				IF ((paddlePos - 5) >= leftBound) THEN
					-- Move the paddle left
					paddlePos <= paddlePos - 5;
					-- Move the ball left w/ the paddle if it is attached
					IF (ballAttached = '1') THEN
						ballPosX <= ballPosX - 5;
					END IF;
				END IF;
				-- If the right button was pressed
			ELSIF (rightBtn = '0') THEN
				-- and if the paddle can move more right
				IF ((paddlePos + 5) < rightBound - paddleWidth) THEN
					-- Move the paddle right
					paddlePos <= paddlePos + 5;
					-- Move the ball right w/ the paddle if it is attached
					IF (ballAttached = '1') THEN
						ballPosX <= ballPosX + 5;
					END IF;
				END IF;
			END IF;

			-- Ball movement
			-- Only active when the ball isn't attached to the paddle
			IF (ballAttached = '0') THEN
				IF (ballDirX = '1') THEN
					-- Move right by Dx
					ballPosX <= ballPosX + ballDx;
				ELSE
					-- Move left by Dx
					ballPosX <= ballPosX - ballDx;
				END IF;

				IF (ballDirY = '1') THEN
					-- Move up by Dy
					ballPosY <= ballPosY - ballDy;
				ELSE
					-- Move down by Dy
					ballPosY <= ballPosY + ballDy;
				END IF;

				-- Bounce off left wall
				IF (ballPosX <= leftBound) THEN
					ballDirX <= NOT ballDirX;
					ballPosX <= ballPosX + ballDx;
				END IF;
				-- Bounch off right wall
				IF (ballPosX + ballSize >= rightBound) THEN
					ballDirX <= NOT ballDirX;
					ballPosX <= ballPosX - ballDx;
				END IF;
				-- Bounce off top wall
				IF (ballPosY <= topBound) THEN
					ballDirY <= NOT ballDirY;
					ballPosY <= ballPosY + ballDy;
				END IF;
				-- bounce off bottom wall
				IF (ballPosY + ballSize >= bottomBound) THEN
					ballDirY <= NOT ballDirY;
					ballPosY <= ballPosY - ballDy;
				END IF;
			END IF;
		END IF;
	END PROCESS;
END Design;