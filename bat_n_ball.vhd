LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_MISC.OR_REDUCE;

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
    TYPE INT_ARRAY IS ARRAY (0 TO 22) OF INTEGER; -- Type definition for int array
    TYPE ROW_ARRAY IS ARRAY (0 TO 15) OF STD_LOGIC_VECTOR (63 DOWNTO 0); -- Type definition for 2D vector array
    TYPE START_ARRAY IS ARRAY (0 TO 15) OF STD_LOGIC_VECTOR (175 DOWNTO 0); -- Type definition for 2D vector array
    TYPE LIVES_ARRAY IS ARRAY (0 TO 9) OF STD_LOGIC_VECTOR (47 DOWNTO 0); -- Type definition for 2D vector array
    TYPE INT_ARRAY2 IS ARRAY (0 TO 99) OF INTEGER; -- Type definition for int array
    SIGNAL alien0_x : INTEGER := 50; -- Original alien's starting horizontal position
    SIGNAL alien0_y : INTEGER := 50; -- Original alien's starting horizontal position
    SIGNAL alien_x : INT_ARRAY; -- Array of alien x positions
    SIGNAL alien_y : INT_ARRAY; -- Array of alien y positions
    SIGNAL alien_on_screen: STD_LOGIC_VECTOR (22 DOWNTO 0) := (OTHERS => '0'); -- Shut off referencing bit when alien is hit
    SIGNAL aliensize1 : INTEGER := 12; -- Radius of Upper UFO
    SIGNAL aliensize2 : INTEGER := 24; -- Radius of Lower UFO
    SIGNAL alien_on : STD_LOGIC_VECTOR (22 DOWNTO 0) := (OTHERS => '0'); -- Only turn on alien if referencing bit is '1'
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
    CONSTANT ship_y : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(550, 11); -- ship vertical position
    SIGNAL laser_y_motion : STD_LOGIC_VECTOR (10 DOWNTO 0) := NOT (laser_speed) + 1;
    SIGNAL alien_laser_y_motion : STD_LOGIC_VECTOR (10 DOWNTO 0) := laser_speed;
    SIGNAL laser_shot : STD_LOGIC := '0'; -- Controls when laser is triggered
    SIGNAL dir : STD_LOGIC := '0'; -- Alien movement direction (0 for Right/1 for Left)
    SIGNAL win, lose, quit2 : STD_LOGIC := '0'; -- Set to 1 when game is won, lost, or quit
    SIGNAL win_on, lose_on : STD_LOGIC; -- Displays win/lose graphic when set to 1
    SIGNAL score_num : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0'); -- Keep score
    SIGNAL movespeed : INTEGER := 4; -- Clock speed of alien movement
    SIGNAL you_win : ROW_ARRAY :=      ("0000000000000000000000000000000000000000000000000000000000000000",
                                        "0000000000000000000000000000000000000000000000000000000000000000",
                                        "1100001100000000000000000000000011000011000110000000000000011000",
                                        "1100001100000000000000000000000011000011000110000000000000111100",
                                        "1100001100000000000000000000000011000011000000000000000000111100",
                                        "0110011001111100110011000000000011000011001110001101110000111100",
                                        "0011110011000110110011000000000011000011000110000110011000011000",
                                        "0001100011000110110011000000000011011011000110000110011000011000",
                                        "0001100011000110110011000000000011011011000110000110011000011000",
                                        "0001100011000110110011000000000011111111000110000110011000000000",
                                        "0001100011000110110011000000000001100110000110000110011000011000",
                                        "0011110001111100011101100000000001100110001111000110011000011000",
                                        "0000000000000000000000000000000000000000000000000000000000000000",
                                        "0000000000000000000000000000000000000000000000000000000000000000",
                                        "0000000000000000000000000000000000000000000000000000000000000000",
                                        "0000000000000000000000000000000000000000000000000000000000000000");
    SIGNAL you_lose : ROW_ARRAY :=     ("0000000000000000000000000000000000000000000000000000000000000000",
                                        "0000000000000000000000000000000000000000000000000000000000000000",
                                        "1100001100000000000000000000000011110000000000000000000000000000",
                                        "1100001100000000000000000000000001100000000000000000000000000000",
                                        "1100001100000000000000000000000001100000000000000000000000000000",
                                        "0110011001111100110011000000000001100000011111000111110001111100",
                                        "0011110011000110110011000000000001100000110001101100011011000110",
                                        "0001100011000110110011000000000001100000110001100110000011111110",
                                        "0001100011000110110011000000000001100000110001100011100011000000",
                                        "0001100011000110110011000000000001100010110001100000110011000000",
                                        "0001100011000110110011000000000001100110110001101100011011000110",
                                        "0011110001111100011101100000000011111110011111000111110001111100",
                                        "0000000000000000000000000000000000000000000000000000000000000000",
                                        "0000000000000000000000000000000000000000000000000000000000000000",
                                        "0000000000000000000000000000000000000000000000000000000000000000",
                                        "0000000000000000000000000000000000000000000000000000000000000000");
    SIGNAL to_start : START_ARRAY :=   ("00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
                                        "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
                                        "00000000000011111100000000000000000000000000000000000000000011111100111111110110001101100011000000000000100000000000000000000011111000001000000000000000000000001000000000000000",
                                        "00000000000001100110000000000000000000000000000000000000000001100110110110110111001101100011000000000001100000000000000000000110001100011000000000000000000000011000000000000000",
                                        "00000000000001100110000000000000000000000000000000000000000001100110100110010111101101100011000000000001100000000000000000000110001100011000000000000000000000011000000000000000",
                                        "00000000000001100110110111000111110001111100011111000000000001100110000110000111111101100011000000000111111000111110000000000011000001111110001111000110111001111110000000000000",
                                        "00000000000001111100011101101100011011000110110001100000000001111100000110000110111101100011000000000001100001100011000000000001110000011000000001100011101100011000000000000000",
                                        "00000000000001100000011001101111111001100000011000000000000001100110000110000110011101100011000000000001100001100011000000000000011000011000001111100011001100011000000000000000",
                                        "00000000000001100000011000001100000000111000001110000000000001100110000110000110001101100011000000000001100001100011000000000000001100011000011001100011000000011000000000000000",
                                        "00000000000001100000011000001100000000001100000011000000000001100110000110000110001101100011000000000001100001100011000000000110001100011000011001100011000000011000000000000000",
                                        "00000000000001100000011000001100011011000110110001100000000001100110000110000110001101100011000000000001101101100011000000000110001100011011011001100011000000011011000000000000",
                                        "00000000000011110000111100000111110001111100011111000000000011111100001111000110001100111110000000000000111000111110000000000011111000001110001110110111100000001110000000000000",
                                        "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
                                        "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
                                        "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
                                        "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000");
    SIGNAL to_restart : START_ARRAY :=  ("00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
                                         "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
                                         "00001111110000000000000000000000000000000000000000001111110011111111011000110110001100000000000010000000000000000000011111100000000000000000000010000000000000000000000010000000",
                                         "00000110011000000000000000000000000000000000000000000110011011011011011100110110001100000000000110000000000000000000001100110000000000000000000110000000000000000000000110000000",
                                         "00000110011000000000000000000000000000000000000000000110011010011001011110110110001100000000000110000000000000000000001100110000000000000000000110000000000000000000000110000000",
                                         "00000110011011011100011111000111110001111100000000000110011000011000011111110110001100000000011111100011111000000000001100110011111000111110011111100011110001101110011111100000",
                                         "00000111110001110110110001101100011011000110000000000111110000011000011011110110001100000000000110000110001100000000001111100110001101100011000110000000011000111011000110000000",
                                         "00000110000001100110111111100110000001100000000000000110011000011000011001110110001100000000000110000110001100000000001101100111111100110000000110000011111000110011000110000000",
                                         "00000110000001100000110000000011100000111000000000000110011000011000011000110110001100000000000110000110001100000000001100110110000000011100000110000110011000110000000110000000",
                                         "00000110000001100000110000000000110000001100000000000110011000011000011000110110001100000000000110000110001100000000001100110110000000000110000110000110011000110000000110000000",
                                         "00000110000001100000110001101100011011000110000000000110011000011000011000110110001100000000000110110110001100000000001100110110001101100011000110110110011000110000000110110000",
                                         "00001111000011110000011111000111110001111100000000001111110000111100011000110011111000000000000011100011111000000000011100110011111000111110000011100011101101111000000011100000",
                                         "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
                                         "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
                                         "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
                                         "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000");
    SIGNAL to_continue : START_ARRAY := ("00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
                                         "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
                                         "11111100000000000000000000000000000000000000000011111100111111110110001101100011000000000000100000000000000000000001111000000000000000000000100000001100000000000000000000000000",
                                         "01100110000000000000000000000000000000000000000001100110110110110111001101100011000000000001100000000000000000000011001100000000000000000001100000001100000000000000000000000000",
                                         "01100110000000000000000000000000000000000000000001100110100110010111101101100011000000000001100000000000000000000110000100000000000000000001100000000000000000000000000000000000",
                                         "01100110110111000111110001111100011111000000000001100110000110000111111101100011000000000111111000111110000000000110000000111110011011100111111000011100011011100110011000111110",
                                         "01111100011101101100011011000110110001100000000001111100000110000110111101100011000000000001100001100011000000000110000001100011001100110001100000001100001100110110011001100011",
                                         "01100000011001101111111001100000011000000000000001100110000110000110011101100011000000000001100001100011000000000110000001100011001100110001100000001100001100110110011001111111",
                                         "01100000011000001100000000111000001110000000000001100110000110000110001101100011000000000001100001100011000000000110000001100011001100110001100000001100001100110110011001100000",
                                         "01100000011000001100000000001100000011000000000001100110000110000110001101100011000000000001100001100011000000000110000101100011001100110001100000001100001100110110011001100000",
                                         "01100000011000001100011011000110110001100000000001100110000110000110001101100011000000000001101101100011000000000011001101100011001100110001101100001100001100110110011001100011",
                                         "11110000111100000111110001111100011111000000000011111100001111000110001100111110000000000000111000111110000000000001111000111110001100110000111000011110001100110011101100111110",
                                         "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
                                         "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
                                         "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
                                         "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000");
    SIGNAL lives_label : LIVES_ARRAY := ("111100000011000000000000000000000000000000000000",
                                         "011000000011000000000000000000000000000000000000",
                                         "011000000000000000000000000000000000000000011000",
                                         "011000000111000110000110011111000111110000011000",
                                         "011000000011000110000110110001101100011000000000",
                                         "011000000011000110000110111111100110000000000000",
                                         "011000000011000110000110110000000011100000000000",
                                         "011000100011000011001100110000000000110000011000",
                                         "011001100011000001111000110001101100011000011000",
                                         "111111100111100000110000011111000111110000000000");
    CONSTANT text_size : INTEGER := 4; -- Size of the "Press BTNU" text
    CONSTANT text_size2 : INTEGER := 10; -- Size of the win/lose text
    CONSTANT text_size3 : INTEGER := 3; -- Size of the lives text
    SIGNAL flash_clock : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0000";
    SIGNAL flash_on : STD_LOGIC := '0';
    SIGNAL text_on : STD_LOGIC; -- Displays text message when set to 1
    SIGNAL lives : INTEGER := 3;
    SIGNAL lives_on : STD_LOGIC;
    SIGNAL alien_laser_x : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0, 11);
    SIGNAL alien_laser_y : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(900, 11);
    SIGNAL enemy_laser_inbound : STD_LOGIC := '1';
    SIGNAL alien_laser_on: STD_LOGIC;
    SIGNAL laser_start_loc : INT_ARRAY2 := (2, 8, 14, 17, 3, 20, 5, 7, 1, 6, 10, 19, 13, 22, 9, 0, 12, 18, 15, 11, 4, 16, 0, 8, 3, 18, 20, 2, 17, 21, 5, 7, 6, 1, 11, 16, 15, 10, 9, 12, 13, 19, 22, 4, 14, 21, 18, 12, 0, 20, 3, 9, 5, 19, 8, 10, 7, 4, 1, 6, 17, 11, 21, 14, 16, 22, 15, 13, 2, 18, 20, 5, 0, 7, 1, 9, 10, 8, 14, 11, 3, 12, 6, 17, 21, 13, 19, 4, 2, 22, 16, 15, 18, 0, 5, 10, 14, 3, 19, 20);
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
    red <= laser_on OR lose_on OR alien_laser_on;
    green <= win_on OR ship_on OR (OR_REDUCE(alien_on));
    blue <= ship_on OR text_on OR lives_on OR alien_laser_on;
    
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
            quit2 <= '0';
        END IF;
        IF (win = '1' OR lose = '1') AND game_on = '1' THEN
            game_on <= '0';
        ELSIF quit = '1' AND game_on = '1' THEN
            game_on <= '0'; quit2 <= '1';
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

    move_alien_laser: PROCESS is
    VARIABLE temp1 : STD_LOGIC_VECTOR (11 DOWNTO 0);
    VARIABLE laser_start : INTEGER := 0;
        BEGIN
        WAIT UNTIL rising_edge(v_sync);
        IF (enemy_laser_inbound = '0' AND game_on = '1') THEN
            IF (alien_on_screen(laser_start_loc(laser_start)) = '1') THEN
                enemy_laser_inbound <= '1';
                alien_laser_x <= CONV_STD_LOGIC_VECTOR(alien_x(laser_start_loc(laser_start)), 11);
                alien_laser_y <= CONV_STD_LOGIC_VECTOR(alien_y(laser_start_loc(laser_start)), 11);
            END IF;
            laser_start := laser_start + 1;
            IF (laser_start = 100) THEN
                laser_start := 0;
            END IF;
        END IF;
        IF (enemy_laser_inbound = '1' AND game_on = '1') THEN
        temp1 := ('0' & alien_laser_y) + (alien_laser_y_motion(10) & alien_laser_y_motion);
            IF (alien_laser_x <= ship_x + aliensize2) AND (alien_laser_x >= ship_x - aliensize2) AND (alien_laser_y <= ship_y + aliensize2) AND (alien_laser_y >= ship_y - aliensize1) THEN
                lives <= lives - 1;
                enemy_laser_inbound <= '0';
            ELSIF alien_laser_y + laser_h >= 600 THEN
                enemy_laser_inbound <= '0';
            ELSE alien_laser_y <= temp1(10 DOWNTO 0);
            END IF;
        END IF;
        IF start = '1' AND game_on = '0' THEN lives <= 3; END IF;
    END PROCESS;
    
    draw_alien_laser: PROCESS (alien_laser_x, alien_laser_y, pixel_row, pixel_col, game_on, enemy_laser_inbound) IS
        BEGIN
        IF ((pixel_col >= alien_laser_x - laser_w) OR (alien_laser_x <= laser_w)) AND
             pixel_col <= alien_laser_x + laser_w AND
             pixel_row >= alien_laser_y - laser_h AND
             pixel_row <= alien_laser_y + laser_h AND game_on = '1' THEN
                alien_laser_on <= enemy_laser_inbound;
        ELSE
            alien_laser_on <= '0';
        END IF;
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

        IF alien0_y + 100 + aliensize2 >= 500 AND game_on = '1' AND alien_on_screen(15 DOWNTO 8) /= 0 THEN
            lose <= '1';
        ELSIF alien0_y + 50 + aliensize2 >= 500 AND game_on = '1' AND alien_on_screen(22 DOWNTO 16) /= 0 THEN
            lose <= '1';
        ELSIF alien0_y + aliensize2 >= 500 AND game_on = '1' AND alien_on_screen(7 DOWNTO 0) /= 0 THEN
            lose <= '1';
        ELSIF lives = 0 THEN lose <= '1';
        END IF;

        IF game_on = '0' THEN
            alien0_x <= 50;
            alien0_y <= 50;
            aliens_move <= "000000";
            IF start = '1' THEN lose <= '0'; END IF;
        ELSE aliens_move <= aliens_move + movespeed;
        END IF;

    END PROCESS;

    shoot_laser : PROCESS
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
            ELSIF laser_y <= laser_h OR game_on = '0' THEN -- dissapear at top wall
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

    draw_text : PROCESS (pixel_row, pixel_col, win_on, lose_on, win, lose, quit2, you_win, you_lose, game_on, text_on, to_start, to_continue, to_restart, lives, lives_label, lives_on)
    BEGIN
        win_on <= '0';
        lose_on <= '0';
        FOR j IN 0 TO 15 LOOP
            FOR i IN 0 TO 63 LOOP
                IF (pixel_col >= 400 - (32 * text_size2) + text_size2 * i) AND (pixel_col < 400 - (32 * text_size2) + text_size2 * (i + 1)) AND (pixel_row >= 150 - (8 * text_size2) + text_size2 * j) AND (pixel_row < 150 - (8 * text_size2) + text_size2 * (j + 1)) AND
                you_win(j)(63 - i) = '1' AND win = '1' THEN win_on <= '1';
                ELSIF (pixel_col >= 400 - (32 * text_size2) + text_size2 * i) AND (pixel_col < 400 - (32 * text_size2) + text_size2 * (i + 1)) AND (pixel_row >= 150 - (8 * text_size2) + text_size2 * j) AND (pixel_row < 150 - (8 * text_size2) + text_size2 * (j + 1)) AND
                you_lose(j)(63 - i) = '1' AND (lose = '1' or quit2 = '1') THEN lose_on <= '1';
                END IF;
            END LOOP;
        END LOOP;
        text_on <= '0';
        IF game_on = '0' THEN
            FOR j IN 0 TO 15 LOOP
                FOR i IN 0 TO 175 LOOP
                    IF (pixel_col >= 400 - (88 * text_size) + text_size * i) AND (pixel_col < 400 - (88 * text_size) + text_size * (i + 1)) AND (pixel_row >= 300 - (8 * text_size) + text_size * j) AND (pixel_row < 300 - (8 * text_size) + text_size * (j + 1)) AND
                    to_start(j)(175 - i) = '1' AND flash_on = '1' THEN IF (win = '0' OR lose = '0' OR quit2 = '0') THEN text_on <= '1'; END IF;
                    ELSIF (pixel_col >= 400 - (88 * text_size) + text_size * i) AND (pixel_col < 400 - (88 * text_size) + text_size * (i + 1)) AND (pixel_row >= 400 - (8 * text_size) + text_size * j) AND (pixel_row < 400 - (8 * text_size) + text_size * (j + 1)) AND
                    to_continue(j)(175 - i) = '1' AND win = '1' AND flash_on = '1' THEN text_on <= '1';
                    ELSIF (pixel_col >= 400 - (88 * text_size) + text_size * i) AND (pixel_col < 400 - (88 * text_size) + text_size * (i + 1)) AND (pixel_row >= 400 - (8 * text_size) + text_size * j) AND (pixel_row < 400 - (8 * text_size) + text_size * (j + 1)) AND
                    to_restart(j)(175 - i) = '1' AND (lose = '1' or quit2 = '1') AND flash_on = '1' THEN text_on <= '1';
                    END IF;
                END LOOP;
            END LOOP;
        END IF;
        FOR j IN 0 TO 9 LOOP
            FOR i IN 0 TO 47 LOOP
                IF (pixel_col >= 526 + text_size3 * i) AND (pixel_col < 526 + text_size3 * (i + 1)) AND (pixel_row >= 5 + text_size3 * j) AND (pixel_row < 5 + text_size3 * (j + 1)) AND
                lives_label(j)(47 - i) = '1' AND game_on = '1' THEN text_on <= '1';
                END IF;
            END LOOP;
        END LOOP;
        IF    (lives = 3 OR lives = 2 OR lives = 1) AND pixel_row >= 10 AND pixel_row <= 35 AND pixel_col >= 680 AND pixel_col <= 710 AND game_on = '1' THEN lives_on <= '1';
        ELSIF (lives = 3 OR lives = 2) AND pixel_row >= 5 AND pixel_row <= 35 AND pixel_col >= 720 AND pixel_col <= 750 AND game_on = '1' THEN lives_on <= '1';
        ELSIF  lives = 3 AND pixel_row >= 5 AND pixel_row <= 35 AND pixel_col >= 760 AND pixel_col <= 790 AND game_on = '1' THEN lives_on <= '1';
        ELSE lives_on <= '0';
        END IF;
    END PROCESS;

    flash_text : PROCESS
    BEGIN
        WAIT UNTIL rising_edge(v_sync);
        IF flash_clock = 0 THEN flash_on <= (NOT flash_on); END IF; 
        flash_clock <= flash_clock + 1;
    END PROCESS;
END Behavioral;
