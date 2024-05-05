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
        start : IN STD_LOGIC; -- Starts/Resets Game
        shoot : IN STD_LOGIC; -- Shoots Laser
        score : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
        red : OUT STD_LOGIC; -- VGA Red
        green : OUT STD_LOGIC; -- VGA Green
        blue : OUT STD_LOGIC -- VGA Blue
    );
END ship_n_laser;

ARCHITECTURE Behavioral OF ship_n_laser IS
--    SIGNAL alien0_x : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(50, 11); -- Original alien's starting horizontal position
--    SIGNAL alien0_y : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(50, 11); -- Original alien's starting horizontal position
--    SIGNAL alien1_x, alien2_x, alien3_x, alien4_x, alien5_x, alien6_x, alien7_x, alien8_x, alien9_x, alien10_x, alien11_x, alien12_x, alien13_x, alien14_x, alien15_x, alien16_x, alien17_x, alien18_x, alien19_x, alien20_x, alien21_x, alien22_x : STD_LOGIC_VECTOR(10 DOWNTO 0); -- Other aliens (horizontal)
--    SIGNAL alien1_y, alien2_y, alien3_y, alien4_y, alien5_y, alien6_y, alien7_y, alien8_y, alien9_y, alien10_y, alien11_y, alien12_y, alien13_y, alien14_y, alien15_y, alien16_y, alien17_y, alien18_y, alien19_y, alien20_y, alien21_y, alien22_y : STD_LOGIC_VECTOR(10 DOWNTO 0); -- Other aliens (horizontal)
    TYPE INT_ARRAY IS ARRAY (0 TO 22) OF INTEGER;
    SIGNAL alien0_x : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(50, 11); -- Original alien's starting horizontal position
    SIGNAL alien0_y : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(50, 11); -- Original alien's starting horizontal position
    SIGNAL alien_x : INT_ARRAY;
    SIGNAL alien_y : INT_ARRAY;
    SIGNAL alien_on_screen: STD_LOGIC_VECTOR (22 DOWNTO 0) := (OTHERS => '0'); -- Shut off referencing bit when alien is hit
    SIGNAL aliensize1 : INTEGER := 12; -- Radius of Upper UFO
    SIGNAL aliensize2 : INTEGER := 24; -- Radius of Lower UFO
    SIGNAL alien_on: STD_LOGIC_VECTOR (22 DOWNTO 0) := (OTHERS => '0'); -- Only turn on alien if referencing bit is '1'
    SIGNAL aliens_move : STD_LOGIC_VECTOR (5 DOWNTO 0):= "000000"; -- Alien movement clock
    CONSTANT laser_w : INTEGER := 2; -- laser width in pixels
    CONSTANT laser_h : INTEGER := 10; -- laser height in pixels
    CONSTANT ship_size : INTEGER := 6; -- ship height in pixels
    CONSTANT ship_h : INTEGER := 35;
    CONSTANT laser_speed : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR (10, 11); -- distance laser moves each frame
    SIGNAL laser_on : STD_LOGIC; -- indicates whether laser is at current pixel position
    SIGNAL ship_on : STD_LOGIC; -- indicates whether ship is over current pixel position
    SIGNAL game_on : STD_LOGIC := '0'; -- indicates whether laser is in play
    SIGNAL laser_x : STD_LOGIC_VECTOR (10 DOWNTO 0); -- current laser position (Horizontal)
    SIGNAL laser_y : STD_LOGIC_VECTOR (10 DOWNTO 0); -- current laser position (Vertical)
    CONSTANT ship_y : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(500, 11); -- ship vertical position
    SIGNAL laser_y_motion : STD_LOGIC_VECTOR (10 DOWNTO 0) := NOT (laser_speed) + 1; -- Do we need this?
    SIGNAL laser_on2 : STD_LOGIC := '0'; -- Controls when laser is triggered
    SIGNAL dir : STD_LOGIC := '0'; -- Alien movement direction (0 for Right/1 for Left)
    SIGNAL win, lose : STD_LOGIC := '0';
    SIGNAL score_num : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
BEGIN
    score <= score_num;
    -- Set Alien x Values
--    alien1_x <= alien0_x + 100; alien2_x <= alien0_x + 200; alien3_x <= alien0_x + 300; alien4_x <= alien0_x + 400; alien5_x <= alien0_x + 500; alien6_x <= alien0_x + 600; alien7_x <= alien0_x + 700; alien8_x <= alien0_x; alien9_x <= alien0_x + 100; alien10_x <= alien0_x + 200; alien11_x <= alien0_x + 300; alien12_x <= alien0_x + 400; alien13_x <= alien0_x + 500; alien14_x <= alien0_x + 600; alien15_x <= alien0_x + 700; alien16_x <= alien0_x + 50; alien17_x <= alien0_x + 150; alien18_x <= alien0_x + 250; alien19_x <= alien0_x + 350; alien20_x <= alien0_x + 450; alien21_x <= alien0_x + 550; alien22_x <= alien0_x + 650;  alien1_y <= alien0_y;
    -- Set Alien y Values
--    alien2_y <= alien0_y; alien3_y <= alien0_y; alien4_y <= alien0_y; alien5_y <= alien0_y; alien6_y <= alien0_y; alien7_y <= alien0_y; alien8_y <= alien0_y + 100; alien9_y <= alien0_y + 100; alien10_y <= alien0_y + 100; alien11_y <= alien0_y + 100; alien12_y <= alien0_y + 100; alien13_y <= alien0_y + 100; alien14_y <= alien0_y + 100; alien15_y <= alien0_y + 100; alien16_y <= alien0_y + 50; alien17_y <= alien0_y + 50; alien18_y <= alien0_y + 50; alien19_y <= alien0_y + 50; alien20_y <= alien0_y + 50; alien21_y <= alien0_y + 50; alien22_y <= alien0_y + 50;
    alien_x(1) <= CONV_INTEGER(alien0_x + 100);
    alien_x(2) <= CONV_INTEGER(alien0_x + 200);
    alien_x(3) <= CONV_INTEGER(alien0_x + 300);
    alien_x(4) <= CONV_INTEGER(alien0_x + 400);
    alien_x(5) <= CONV_INTEGER(alien0_x + 500);
    alien_x(6) <= CONV_INTEGER(alien0_x + 600);
    alien_x(7) <= CONV_INTEGER(alien0_x + 700);
    alien_x(8) <= CONV_INTEGER(alien0_x);
    alien_x(9) <= CONV_INTEGER(alien0_x + 100);
    alien_x(10) <= CONV_INTEGER(alien0_x + 200);
    alien_x(11) <= CONV_INTEGER(alien0_x + 300);
    alien_x(12) <= CONV_INTEGER(alien0_x + 400);
    alien_x(13) <= CONV_INTEGER(alien0_x + 500);
    alien_x(14) <= CONV_INTEGER(alien0_x + 600);
    alien_x(15) <= CONV_INTEGER(alien0_x + 700);
    alien_x(16) <= CONV_INTEGER(alien0_x + 50);
    alien_x(17) <= CONV_INTEGER(alien0_x + 150);
    alien_x(18) <= CONV_INTEGER(alien0_x + 250);
    alien_x(19) <= CONV_INTEGER(alien0_x + 350);
    alien_x(20) <= CONV_INTEGER(alien0_x + 450);
    alien_x(21) <= CONV_INTEGER(alien0_x + 550);
    alien_x(22) <= CONV_INTEGER(alien0_x + 650);
    
    alien_y(1 TO 7) <= (OTHERS => CONV_INTEGER(alien0_y));
    alien_y(8 TO 15) <= (OTHERS => CONV_INTEGER(alien0_y + 100));
    alien_y(16 TO 22) <= (OTHERS => CONV_INTEGER(alien0_y + 50));
    -- Set Colors
    red <= laser_on;
    green <= alien_on(0) OR alien_on(1) OR alien_on(2) OR alien_on(3) OR alien_on(4) OR alien_on(5) OR alien_on(6) OR alien_on(7) OR alien_on(8) OR alien_on(9) OR alien_on(10) OR alien_on(11) OR alien_on(12) OR alien_on(13) OR alien_on(14) OR alien_on(15) OR alien_on(16) OR alien_on(17) OR alien_on(18) OR alien_on(19) OR alien_on(20) OR alien_on(21) OR alien_on(22) OR ship_on;
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

    draw_laser : PROCESS (laser_x, laser_y, pixel_row, pixel_col) IS
    BEGIN
        IF ((pixel_col >= laser_x - laser_w) OR (laser_x <= laser_w)) AND
             pixel_col <= laser_x + laser_w AND
             pixel_row >= laser_y - laser_h AND
             pixel_row <= laser_y + laser_h AND game_on = '1' THEN
                laser_on <= laser_on2;
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
            -- laser_y_motion <= (NOT laser_speed) + 1; -- set vspeed to (- laser_speed) pixels
        END IF;
        -- compute next laser vertical position
        -- variable temp adds one more bit to calculation to fix unsigned underflow problems
        -- when laser_y is close to zero AND laser_y_motion is negative
        temp := ('0' & laser_y) + (laser_y_motion(10) & laser_y_motion);
        IF game_on = '0' OR laser_on2 = '0' THEN
            laser_y <= (ship_y - ship_size) - 50;
        ELSIF temp(11) = '1' THEN
            laser_y <= (OTHERS => '0');
        ELSE laser_y <= temp(10 DOWNTO 0); -- 9 DOWNTO 0
        END IF;
        IF laser_on2 = '0' THEN
            laser_x <= ship_x;
        END IF;
    END PROCESS;

    draw_aliens: PROCESS (pixel_row, pixel_col, alien0_x, alien0_y) IS
        BEGIN
--            IF alien_on_screen(0) = '1' THEN IF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien0_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien0_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien0_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien0_x))) <= aliensize1*aliensize1) AND pixel_row <= alien0_y THEN     alien_on(0) <= '1'; ELSIF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien0_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien0_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien0_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien0_x))) <= aliensize2*aliensize2) AND pixel_row >= alien0_y THEN     alien_on(0) <= '1'; ELSE     alien_on(0) <= '0'; END IF; END IF;
--            IF alien_on_screen(1) = '1' THEN IF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien1_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien1_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien1_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien1_x))) <= aliensize1*aliensize1) AND pixel_row <= alien1_y THEN     alien_on(1) <= '1'; ELSIF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien1_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien1_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien1_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien1_x))) <= aliensize2*aliensize2) AND pixel_row >= alien1_y THEN     alien_on(1) <= '1'; ELSE     alien_on(1) <= '0'; END IF; END IF;
--            IF alien_on_screen(2) = '1' THEN IF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien2_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien2_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien2_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien2_x))) <= aliensize1*aliensize1) AND pixel_row <= alien2_y THEN     alien_on(2) <= '1'; ELSIF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien2_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien2_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien2_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien2_x))) <= aliensize2*aliensize2) AND pixel_row >= alien2_y THEN     alien_on(2) <= '1'; ELSE     alien_on(2) <= '0'; END IF; END IF;
--            IF alien_on_screen(3) = '1' THEN IF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien3_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien3_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien3_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien3_x))) <= aliensize1*aliensize1) AND pixel_row <= alien3_y THEN     alien_on(3) <= '1'; ELSIF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien3_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien3_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien3_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien3_x))) <= aliensize2*aliensize2) AND pixel_row >= alien3_y THEN     alien_on(3) <= '1'; ELSE     alien_on(3) <= '0'; END IF; END IF;
--            IF alien_on_screen(4) = '1' THEN IF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien4_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien4_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien4_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien4_x))) <= aliensize1*aliensize1) AND pixel_row <= alien4_y THEN     alien_on(4) <= '1'; ELSIF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien4_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien4_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien4_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien4_x))) <= aliensize2*aliensize2) AND pixel_row >= alien4_y THEN     alien_on(4) <= '1'; ELSE     alien_on(4) <= '0'; END IF; END IF;
--            IF alien_on_screen(5) = '1' THEN IF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien5_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien5_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien5_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien5_x))) <= aliensize1*aliensize1) AND pixel_row <= alien5_y THEN     alien_on(5) <= '1'; ELSIF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien5_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien5_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien5_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien5_x))) <= aliensize2*aliensize2) AND pixel_row >= alien5_y THEN     alien_on(5) <= '1'; ELSE     alien_on(5) <= '0'; END IF; END IF;
--            IF alien_on_screen(6) = '1' THEN IF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien6_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien6_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien6_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien6_x))) <= aliensize1*aliensize1) AND pixel_row <= alien6_y THEN     alien_on(6) <= '1'; ELSIF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien6_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien6_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien6_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien6_x))) <= aliensize2*aliensize2) AND pixel_row >= alien6_y THEN     alien_on(6) <= '1'; ELSE     alien_on(6) <= '0'; END IF; END IF;
--            IF alien_on_screen(7) = '1' THEN IF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien7_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien7_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien7_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien7_x))) <= aliensize1*aliensize1) AND pixel_row <= alien7_y THEN     alien_on(7) <= '1'; ELSIF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien7_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien7_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien7_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien7_x))) <= aliensize2*aliensize2) AND pixel_row >= alien7_y THEN     alien_on(7) <= '1'; ELSE     alien_on(7) <= '0'; END IF; END IF;
--            IF alien_on_screen(8) = '1' THEN IF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien8_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien8_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien8_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien8_x))) <= aliensize1*aliensize1) AND pixel_row <= alien8_y THEN     alien_on(8) <= '1'; ELSIF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien8_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien8_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien8_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien8_x))) <= aliensize2*aliensize2) AND pixel_row >= alien8_y THEN     alien_on(8) <= '1'; ELSE     alien_on(8) <= '0'; END IF; END IF;
--            IF alien_on_screen(9) = '1' THEN IF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien9_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien9_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien9_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien9_x))) <= aliensize1*aliensize1) AND pixel_row <= alien9_y THEN     alien_on(9) <= '1'; ELSIF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien9_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien9_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien9_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien9_x))) <= aliensize2*aliensize2) AND pixel_row >= alien9_y THEN     alien_on(9) <= '1'; ELSE     alien_on(9) <= '0'; END IF; END IF;
--            IF alien_on_screen(10) = '1' THEN IF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien10_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien10_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien10_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien10_x))) <= aliensize1*aliensize1) AND pixel_row <= alien10_y THEN     alien_on(10) <= '1'; ELSIF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien10_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien10_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien10_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien10_x))) <= aliensize2*aliensize2) AND pixel_row >= alien10_y THEN     alien_on(10) <= '1'; ELSE     alien_on(10) <= '0'; END IF; END IF;
--            IF alien_on_screen(11) = '1' THEN IF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien11_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien11_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien11_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien11_x))) <= aliensize1*aliensize1) AND pixel_row <= alien11_y THEN     alien_on(11) <= '1'; ELSIF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien11_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien11_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien11_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien11_x))) <= aliensize2*aliensize2) AND pixel_row >= alien11_y THEN     alien_on(11) <= '1'; ELSE     alien_on(11) <= '0'; END IF; END IF;
--            IF alien_on_screen(12) = '1' THEN IF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien12_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien12_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien12_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien12_x))) <= aliensize1*aliensize1) AND pixel_row <= alien12_y THEN     alien_on(12) <= '1'; ELSIF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien12_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien12_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien12_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien12_x))) <= aliensize2*aliensize2) AND pixel_row >= alien12_y THEN     alien_on(12) <= '1'; ELSE     alien_on(12) <= '0'; END IF; END IF;
--            IF alien_on_screen(13) = '1' THEN IF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien13_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien13_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien13_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien13_x))) <= aliensize1*aliensize1) AND pixel_row <= alien13_y THEN     alien_on(13) <= '1'; ELSIF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien13_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien13_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien13_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien13_x))) <= aliensize2*aliensize2) AND pixel_row >= alien13_y THEN     alien_on(13) <= '1'; ELSE     alien_on(13) <= '0'; END IF; END IF;
--            IF alien_on_screen(14) = '1' THEN IF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien14_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien14_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien14_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien14_x))) <= aliensize1*aliensize1) AND pixel_row <= alien14_y THEN     alien_on(14) <= '1'; ELSIF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien14_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien14_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien14_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien14_x))) <= aliensize2*aliensize2) AND pixel_row >= alien14_y THEN     alien_on(14) <= '1'; ELSE     alien_on(14) <= '0'; END IF; END IF;
--            IF alien_on_screen(15) = '1' THEN IF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien15_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien15_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien15_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien15_x))) <= aliensize1*aliensize1) AND pixel_row <= alien15_y THEN     alien_on(15) <= '1'; ELSIF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien15_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien15_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien15_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien15_x))) <= aliensize2*aliensize2) AND pixel_row >= alien15_y THEN     alien_on(15) <= '1'; ELSE     alien_on(15) <= '0'; END IF; END IF;
--            IF alien_on_screen(16) = '1' THEN IF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien16_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien16_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien16_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien16_x))) <= aliensize1*aliensize1) AND pixel_row <= alien16_y THEN     alien_on(16) <= '1'; ELSIF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien16_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien16_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien16_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien16_x))) <= aliensize2*aliensize2) AND pixel_row >= alien16_y THEN     alien_on(16) <= '1'; ELSE     alien_on(16) <= '0'; END IF; END IF;
--            IF alien_on_screen(17) = '1' THEN IF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien17_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien17_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien17_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien17_x))) <= aliensize1*aliensize1) AND pixel_row <= alien17_y THEN     alien_on(17) <= '1'; ELSIF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien17_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien17_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien17_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien17_x))) <= aliensize2*aliensize2) AND pixel_row >= alien17_y THEN     alien_on(17) <= '1'; ELSE     alien_on(17) <= '0'; END IF; END IF;
--            IF alien_on_screen(18) = '1' THEN IF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien18_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien18_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien18_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien18_x))) <= aliensize1*aliensize1) AND pixel_row <= alien18_y THEN     alien_on(18) <= '1'; ELSIF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien18_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien18_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien18_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien18_x))) <= aliensize2*aliensize2) AND pixel_row >= alien18_y THEN     alien_on(18) <= '1'; ELSE     alien_on(18) <= '0'; END IF; END IF;
--            IF alien_on_screen(19) = '1' THEN IF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien19_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien19_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien19_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien19_x))) <= aliensize1*aliensize1) AND pixel_row <= alien19_y THEN     alien_on(19) <= '1'; ELSIF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien19_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien19_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien19_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien19_x))) <= aliensize2*aliensize2) AND pixel_row >= alien19_y THEN     alien_on(19) <= '1'; ELSE     alien_on(19) <= '0'; END IF; END IF;
--            IF alien_on_screen(20) = '1' THEN IF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien20_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien20_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien20_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien20_x))) <= aliensize1*aliensize1) AND pixel_row <= alien20_y THEN     alien_on(20) <= '1'; ELSIF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien20_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien20_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien20_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien20_x))) <= aliensize2*aliensize2) AND pixel_row >= alien20_y THEN     alien_on(20) <= '1'; ELSE     alien_on(20) <= '0'; END IF; END IF;
--            IF alien_on_screen(21) = '1' THEN IF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien21_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien21_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien21_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien21_x))) <= aliensize1*aliensize1) AND pixel_row <= alien21_y THEN     alien_on(21) <= '1'; ELSIF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien21_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien21_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien21_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien21_x))) <= aliensize2*aliensize2) AND pixel_row >= alien21_y THEN     alien_on(21) <= '1'; ELSE     alien_on(21) <= '0'; END IF; END IF;
--            IF alien_on_screen(22) = '1' THEN IF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien22_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien22_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien22_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien22_x))) <= aliensize1*aliensize1) AND pixel_row <= alien22_y THEN     alien_on(22) <= '1'; ELSIF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien22_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien22_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien22_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien22_x))) <= aliensize2*aliensize2) AND pixel_row >= alien22_y THEN     alien_on(22) <= '1'; ELSE     alien_on(22) <= '0'; END IF; END IF;
            IF alien_on_screen(0) = '1' THEN IF ((
                (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien0_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien0_y)))
                 + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien0_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien0_x))) <= aliensize1*aliensize1) AND pixel_row <= alien0_y THEN     alien_on(0) <= '1'; ELSIF (((CONV_INTEGER(pixel_row) - CONV_INTEGER(alien0_y)) * (CONV_INTEGER(pixel_row) - CONV_INTEGER(alien0_y))) + ((CONV_INTEGER(pixel_col) - CONV_INTEGER(alien0_x)) * (CONV_INTEGER(pixel_col) - CONV_INTEGER(alien0_x))) <= aliensize2*aliensize2) AND pixel_row >= alien0_y THEN     alien_on(0) <= '1'; ELSE     alien_on(0) <= '0'; END IF; END IF;
            FOR i IN 1 TO 22 LOOP
                IF alien_on_screen(i) = '1' THEN IF (((CONV_INTEGER(pixel_row) - alien_y(i)) * (CONV_INTEGER(pixel_row) - alien_y(i))) + ((CONV_INTEGER(pixel_col) - alien_x(i)) * (CONV_INTEGER(pixel_col) - alien_x(i))) <= aliensize1*aliensize1) AND pixel_row <= CONV_STD_LOGIC_VECTOR(alien_y(i),11) THEN alien_on(i) <= '1'; ELSIF (((CONV_INTEGER(pixel_row) - alien_y(i)) * (CONV_INTEGER(pixel_row) - alien_y(i))) + ((CONV_INTEGER(pixel_col) - alien_x(i)) * (CONV_INTEGER(pixel_col) - alien_x(i))) <= aliensize2*aliensize2) AND pixel_row >= CONV_STD_LOGIC_VECTOR(alien_y(i),11) THEN alien_on(i) <= '1';  ELSE alien_on(i) <= '0'; END IF; END IF;
            END LOOP;
    END PROCESS;

    move_aliens : PROCESS
    BEGIN
--        WAIT UNTIL rising_edge(v_sync);
--        IF aliens_move = CONV_STD_LOGIC_VECTOR(0,6) THEN alien0_x <= alien0_x + 25;
--        ELSIF aliens_move = CONV_STD_LOGIC_VECTOR(8,6) THEN alien0_y <= alien0_y + 25;
--        ELSIF aliens_move = CONV_STD_LOGIC_VECTOR(16,6) THEN alien0_x <= alien0_x - 25;
--        ELSIF aliens_move = CONV_STD_LOGIC_VECTOR(24,6) THEN alien0_x <= alien0_x - 25;
--        ELSIF aliens_move = CONV_STD_LOGIC_VECTOR(32,6) THEN alien0_y <= alien0_y - 25;
--        ELSIF aliens_move = CONV_STD_LOGIC_VECTOR(40,6) THEN alien0_y <= alien0_y - 25;
--        ELSIF aliens_move = CONV_STD_LOGIC_VECTOR(48,6) THEN alien0_x <= alien0_x + 25;
--        ELSIF aliens_move = CONV_STD_LOGIC_VECTOR(56,6) THEN alien0_y <= alien0_y + 25;
--        END IF;
--        aliens_move <= aliens_move + 1;
        WAIT UNTIL rising_edge(v_sync);
        IF aliens_move = 0 THEN
            IF dir = '0' THEN alien0_x <= alien0_x + 5;
            IF alien0_x = CONV_STD_LOGIC_VECTOR(70,11) THEN alien0_y <= alien0_y + 25; dir <= '1';
            END IF;
            ELSIF dir = '1' THEN alien0_x <= alien0_x - 5;
            IF alien0_x = CONV_STD_LOGIC_VECTOR(30,11) THEN alien0_y <= alien0_y + 25; dir <= '0';
            END IF;
            END IF;
        END IF;
        aliens_move <= aliens_move + 4;
    END PROCESS;

    shoot_laser : PROCESS-- (shoot, laser_y, laser_on2, shoot, game_on, start)
        BEGIN
            WAIT UNTIL rising_edge(v_sync);
            IF start = '1' AND game_on = '0' THEN
                alien_on_screen <= (OTHERS => '1');
--                alien0_x <= CONV_STD_LOGIC_VECTOR(50, 11);
--                alien0_y <= CONV_STD_LOGIC_VECTOR(50, 11);
--                score_num <= (OTHERS => '0');
            -- laser_y_motion <= (NOT laser_speed) + 1; -- set vspeed to (- laser_speed) pixels
            END IF;
            
            IF shoot = '1' AND game_on = '1' THEN
                laser_on2 <= '1';
            ELSIF laser_y <= laser_h THEN -- dissapear at top wall
                laser_on2 <= '0';
            END IF;
            
            IF (alien_on_screen(0) = '1') AND (laser_x <= alien0_x + 24) AND (laser_x >= alien0_x - 24) AND (laser_y <= alien0_y + aliensize2) AND (laser_y >= alien0_y - aliensize1) THEN
                laser_on2 <= '0';
                alien_on_screen(0) <= '0';
                score_num <= score_num + 10;
            END IF;
            
            FOR i IN 1 TO 22 LOOP
                IF alien_on_screen(i) = '1' AND (laser_x <= alien_x(i) + 24) AND (laser_x >= alien_x(i) - 24) AND (laser_y <= alien_y(i) + aliensize2) AND (laser_y >= alien_y(i) - aliensize1) THEN
                alien_on_screen(i) <= '0';
                laser_on2 <= '0';
                score_num <= score_num + 10;
                END IF;
            END LOOP;
    END PROCESS;
END Behavioral;
