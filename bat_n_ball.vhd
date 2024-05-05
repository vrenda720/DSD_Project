LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY ship_n_laser IS
    PORT (
        v_sync : IN STD_LOGIC; -- vga "clock"
        pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        ship_x : IN STD_LOGIC_VECTOR (10 DOWNTO 0); -- Ship x position
        start : IN STD_LOGIC; -- Starts Game
        shoot : IN STD_LOGIC; -- Shoots Laser
        quit : IN STD_LOGIC; -- Quits Game
        score : OUT STD_LOGIC_VECTOR (15 DOWNTO 0); -- Sends score to leddec
        red : OUT STD_LOGIC; -- VGA Red
        green : OUT STD_LOGIC; -- VGA Green
        blue : OUT STD_LOGIC -- VGA Blue
    );
END ship_n_laser;

ARCHITECTURE Behavioral OF ship_n_laser IS
    TYPE INT_ARRAY IS ARRAY (0 TO 22) OF INTEGER; -- Type definition
    SIGNAL alien0_x : INTEGER := 50; -- Original alien's starting horizontal position
    SIGNAL alien0_y : INTEGER := 50; -- Original alien's starting horizontal position
    SIGNAL alien_x : INT_ARRAY; -- Array of alien x positions
    SIGNAL alien_y : INT_ARRAY; -- Array of alien y positions
    SIGNAL alien_on_screen: STD_LOGIC_VECTOR (22 DOWNTO 0) := (OTHERS => '0'); -- Shut off referencing bit when alien is hit
    SIGNAL aliensize1 : INTEGER := 12; -- Radius of Upper UFO
    SIGNAL aliensize2 : INTEGER := 24; -- Radius of Lower UFO
    SIGNAL alien_on: STD_LOGIC_VECTOR (22 DOWNTO 0) := (OTHERS => '0'); -- Only turn on alien if referencing bit is '1'
    SIGNAL aliens_move : STD_LOGIC_VECTOR (5 DOWNTO 0):= "000000"; -- Alien movement clock
    CONSTANT laser_w : INTEGER := 2; -- laser width in pixels
    CONSTANT laser_h : INTEGER := 10; -- laser height in pixels
    CONSTANT ship_size : INTEGER := 6; -- ship height in pixels
    CONSTANT laser_speed : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR (10, 11); -- distance laser moves each frame
    SIGNAL laser_on : STD_LOGIC; -- indicates whether laser is at current pixel position
    SIGNAL ship_on : STD_LOGIC; -- indicates whether ship is over current pixel position
    SIGNAL game_on : STD_LOGIC := '0'; -- indicates whether laser is in play
    SIGNAL laser_x : STD_LOGIC_VECTOR (10 DOWNTO 0); -- current laser position (Horizontal)
    SIGNAL laser_y : STD_LOGIC_VECTOR (10 DOWNTO 0); -- current laser position (Vertical)
    CONSTANT ship_y : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(500, 11); -- ship vertical position
    SIGNAL laser_y_motion : STD_LOGIC_VECTOR (10 DOWNTO 0) := NOT (laser_speed) + 1; -- Do we need this?
    SIGNAL laser_shot : STD_LOGIC := '0'; -- Controls when laser is triggered
    SIGNAL dir : STD_LOGIC := '0'; -- Alien movement direction (0 for Right/1 for Left)
    SIGNAL win, lose : STD_LOGIC := '0'; -- Set to 1 when game is won or lost
    SIGNAL win_on, lose_on : STD_LOGIC;
    SIGNAL score_num : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0'); -- Keep score
    SIGNAL movespeed : INTEGER := 4; -- Clock speed of alien movement
BEGIN
    -- Set Score
    score <= score_num;
    -- Set Alien x Values (Row 1)
    alien_x(0) <= alien0_x; alien_x(1) <= alien0_x + 100; alien_x(2) <= alien0_x + 200; alien_x(3) <= alien0_x + 300; alien_x(4) <= alien0_x + 400; alien_x(5) <= alien0_x + 500; alien_x(6) <= alien0_x + 600; alien_x(7) <= alien0_x + 700;
    -- Set Alien x Values (Row 3)
    alien_x(8) <= alien0_x; alien_x(9) <= alien0_x + 100; alien_x(10) <= alien0_x + 200; alien_x(11) <= alien0_x + 300; alien_x(12) <= alien0_x + 400; alien_x(13) <= alien0_x + 500; alien_x(14) <= alien0_x + 600; alien_x(15) <= alien0_x + 700;
    -- Set Alien x Values (Row 2)
    alien_x(16) <= alien0_x + 50; alien_x(17) <= alien0_x + 150; alien_x(18) <= alien0_x + 250; alien_x(19) <= alien0_x + 350; alien_x(20) <= alien0_x + 450; alien_x(21) <= alien0_x + 550; alien_x(22) <= alien0_x + 650;
    
    -- Set Alien y Values
    alien_y(0 TO 7) <= (OTHERS => alien0_y); -- Row 1
    alien_y(8 TO 15) <= (OTHERS => alien0_y + 100); -- Row 3
    alien_y(16 TO 22) <= (OTHERS => alien0_y + 50); -- Row 2

    -- Set Colors
    red <= laser_on OR lose_on;
    green <= win_on OR alien_on(0) OR alien_on(1) OR alien_on(2) OR alien_on(3) OR alien_on(4) OR alien_on(5) OR alien_on(6) OR alien_on(7) OR alien_on(8) OR alien_on(9) OR alien_on(10) OR alien_on(11) OR alien_on(12) OR alien_on(13) OR alien_on(14) OR alien_on(15) OR alien_on(16) OR alien_on(17) OR alien_on(18) OR alien_on(19) OR alien_on(20) OR alien_on(21) OR alien_on(22) OR ship_on;
    blue <= ship_on;
    
    draw_ship : PROCESS (ship_x, pixel_row, pixel_col) IS
    BEGIN
        IF (pixel_col >= ship_x AND pixel_row <= ship_y - 35 AND pixel_row + 35 >= ship_y + (pixel_col - ship_x) - ship_size) THEN
            ship_on <= '1';
        ELSIF (pixel_col <= ship_x AND pixel_row <= ship_y - 35 AND pixel_row + 35 >= ship_y + (ship_x - pixel_col) - ship_size) THEN
            ship_on <= '1';
        ELSIF ((pixel_col >= ship_x - 6) OR (ship_x <= 6)) AND
             pixel_col <= ship_x + 6 AND
             pixel_row >= ship_y - 35 AND
             pixel_row <= ship_y + 35 THEN
             ship_on <= '1';
        ELSIF (pixel_col + 6 <= ship_x AND pixel_row - 35 <= ship_y AND pixel_row - 25 >= ship_y + (ship_x - pixel_col - 6) - ship_size) AND pixel_row >= 6 THEN
            ship_on <= '1';
        ELSIF (pixel_col - 6 >= ship_x AND pixel_row - 35 <= ship_y AND pixel_row - 25 >= ship_y + (pixel_col - ship_x - 6) - ship_size) AND pixel_col >= ship_x THEN
            ship_on <= '1';
        ELSE
            ship_on <= '0';
        END IF;
    END PROCESS;

    draw_laser : PROCESS (laser_x, laser_y, pixel_row, pixel_col, game_on, laser_shot) IS
    BEGIN
        IF ((pixel_col >= laser_x - laser_w) OR (laser_x <= laser_w)) AND
             pixel_col <= laser_x + laser_w AND
             pixel_row >= laser_y - laser_h AND
             pixel_row <= laser_y + laser_h AND game_on = '1' THEN
                laser_on <= laser_shot;
        ELSE
            laser_on <= '0';
        END IF;
    END PROCESS;

    move_laser : PROCESS
        VARIABLE temp : STD_LOGIC_VECTOR (11 DOWNTO 0);
    BEGIN
        WAIT UNTIL rising_edge(v_sync);
        IF start = '1' AND game_on = '0' THEN
            game_on <= '1';
            lose <= '0';
        END IF;
        IF (win = '1' OR lose = '1' OR quit = '1') AND game_on = '1' THEN
            game_on <= '0';
        END IF;
        -- Compute next laser vertical position. Variable temp adds one more bit to calculation to fix unsigned underflow problems. When laser_y is close to zero AND laser_y_motion is negative
        temp := ('0' & laser_y) + (laser_y_motion(10) & laser_y_motion);
        IF game_on = '0' OR laser_shot = '0' THEN
            laser_y <= (ship_y - ship_size) - 50;
        ELSIF temp(11) = '1' THEN
            laser_y <= (OTHERS => '0');
        ELSE laser_y <= temp(10 DOWNTO 0); -- 9 DOWNTO 0
        END IF;
        IF laser_shot = '0' THEN
            laser_x <= ship_x;
        END IF;
    END PROCESS;

    draw_aliens: PROCESS (pixel_row, pixel_col, alien0_x, alien0_y, alien_on_screen, alien_x, alien_y, aliensize1, aliensize2, game_on) IS
        BEGIN
            FOR i IN 0 TO 22 LOOP
                IF alien_on_screen(i) = '1' THEN IF (((CONV_INTEGER(pixel_row) - alien_y(i)) * (CONV_INTEGER(pixel_row) - alien_y(i))) + ((CONV_INTEGER(pixel_col) - alien_x(i)) * (CONV_INTEGER(pixel_col) - alien_x(i))) <= aliensize1*aliensize1) AND pixel_row <= CONV_STD_LOGIC_VECTOR(alien_y(i),11) AND game_on = '1' THEN alien_on(i) <= '1'; ELSIF (((CONV_INTEGER(pixel_row) - alien_y(i)) * (CONV_INTEGER(pixel_row) - alien_y(i))) + ((CONV_INTEGER(pixel_col) - alien_x(i)) * (CONV_INTEGER(pixel_col) - alien_x(i))) <= aliensize2*aliensize2) AND pixel_row >= CONV_STD_LOGIC_VECTOR(alien_y(i),11) AND game_on = '1' THEN alien_on(i) <= '1';  ELSE alien_on(i) <= '0'; END IF; END IF;
            END LOOP;
    END PROCESS;

    move_aliens : PROCESS
    BEGIN
        WAIT UNTIL rising_edge(v_sync);
        IF aliens_move = 0 AND game_on = '1' THEN
            IF dir = '0' THEN alien0_x <= alien0_x + 5;
            IF alien0_x = 70 THEN alien0_y <= alien0_y + 25; dir <= '1';
            END IF;
            ELSIF dir = '1' THEN alien0_x <= alien0_x - 5;
            IF alien0_x = 30 THEN alien0_y <= alien0_y + 25; dir <= '0';
            END IF;
            END IF;
        END IF;

        -- IF alien0_x <= CONV_STD_LOGIC_VECTOR(500,11) AND game_on = '1' THEN
        --     lose <= '1';
        -- END IF;

        IF game_on = '0' THEN
            alien0_x <= 50;
            alien0_y <= 50;
            aliens_move <= "000000";
        ELSE aliens_move <= aliens_move + movespeed;
        END IF;

    END PROCESS;

    shoot_laser : PROCESS -- (shoot, laser_y, laser_shot, shoot, game_on, start)
        BEGIN
            WAIT UNTIL rising_edge(v_sync);
            IF start = '1' AND game_on = '0' THEN
                alien_on_screen <= (OTHERS => '1');
                IF win = '1' THEN
                    win <= '0';
                    movespeed <= movespeed * 2;
                ELSE score_num <= (OTHERS => '0');
                     movespeed <= 4;
                END IF;
            END IF;
            
            IF shoot = '1' AND game_on = '1' THEN
                laser_shot <= '1';
            ELSIF laser_y <= laser_h THEN -- dissapear at top wall
                laser_shot <= '0';
            END IF;
            
            FOR i IN 0 TO 22 LOOP
                IF alien_on_screen(i) = '1' AND (laser_x <= alien_x(i) + aliensize2) AND (laser_x >= alien_x(i) - aliensize2) AND (laser_y <= alien_y(i) + aliensize2) AND (laser_y >= alien_y(i) - aliensize1) AND laser_shot = '1' THEN
                alien_on_screen(i) <= '0';
                laser_shot <= '0';
                score_num <= score_num + 16;
                END IF;
            END LOOP;

            IF alien_on_screen = 0 AND game_on = '1' THEN win <= '1'; END IF;
    END PROCESS;

    -- winlose_draw : PROCESS (win, lose)
    -- BEGIN
    --     IF ("Box in Center") THEN
    --         IF win = '1' THEN win_on <= '1'' END IF;
    --         IF lose = '1' THEN lose_on <= '1'; END IF;
    --     END IF;
    -- END PROCESS;
END Behavioral;
