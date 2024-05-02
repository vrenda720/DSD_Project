LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY bat_n_ball IS
    PORT (
        v_sync : IN STD_LOGIC;
        pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        bat_x : IN STD_LOGIC_VECTOR (10 DOWNTO 0); -- current bat x position
        start : IN STD_LOGIC; -- initiates serve
        shoot : IN STD_LOGIC;
        red : OUT STD_LOGIC;
        green : OUT STD_LOGIC;
        blue : OUT STD_LOGIC
    );
END bat_n_ball;

ARCHITECTURE Behavioral OF bat_n_ball IS

    SIGNAL alien1_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(50, 11);
    SIGNAL alien2_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(150, 11);
    SIGNAL alien3_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(250, 11);
    SIGNAL alien4_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(350, 11);
    SIGNAL alien5_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(450, 11);
    SIGNAL alien6_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(550, 11);
    SIGNAL alien7_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(650, 11);
    SIGNAL alien8_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(750, 11);
    SIGNAL alien1_y, alien2_y, alien3_y, alien4_y, alien5_y, alien6_y, alien7_y, alien8_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);
    SIGNAL alien_on_screen: std_logic_vector(7 downto 0) := (OTHERS => '1');
    SIGNAL aliensize : integer := 12;
    SIGNAL alien_on: std_logic_vector(7 downto 0) := (OTHERS => '1');

    CONSTANT ball_w : INTEGER := 2; -- ball size in pixels
    CONSTANT ball_h : INTEGER := 10; -- ball size in pixels
    CONSTANT bat_w : INTEGER := 50; -- bat width in pixels
    CONSTANT bat_h : INTEGER := 10; -- bat height in pixels
    -- distance ball moves each frame
    CONSTANT ball_speed : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR (6, 11);
    SIGNAL ball_on : STD_LOGIC; -- indicates whether ball is at current pixel position
    SIGNAL bat_on : STD_LOGIC; -- indicates whether bat at over current pixel position
    SIGNAL game_on : STD_LOGIC := '0'; -- indicates whether ball is in play
    -- current ball position - intitialized to center of screen
    SIGNAL ball_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11);
    SIGNAL ball_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);
    -- bat vertical position
    CONSTANT bat_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(500, 11);
    -- current ball motion - initialized to (+ ball_speed) pixels/frame in both X and Y directions
    SIGNAL ball_y_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := ball_speed;
    --signal ball_x_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00000000000";
    SIGNAL laser_on : STD_LOGIC := '0';
BEGIN
    red <= NOT bat_on; -- color setup for red ball and cyan bat on white background
    green <= NOT (alien_on(0) or alien_on(1) or alien_on(2) or alien_on(3) or alien_on(4) or alien_on(5) or alien_on(6) or alien_on(7));
    blue <= NOT (alien_on(0) or alien_on(1) or alien_on(2) or alien_on(3) or alien_on(4) or alien_on(5) or alien_on(6) or alien_on(7));
    -- process to draw round ball
    -- set ball_on if current pixel address is covered by ball position
    -- process to draw bat
    -- set bat_on if current pixel address is covered by bat position
    batdraw : PROCESS (bat_x, pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    BEGIN
        IF ((pixel_col >= bat_x - bat_w) OR (bat_x <= bat_w)) AND
         pixel_col <= bat_x + bat_w AND
             pixel_row >= bat_y - bat_h AND
             pixel_row <= bat_y + bat_h THEN
                bat_on <= '1';
        ELSE
            bat_on <= '0';
        END IF;
    END PROCESS;
    -- process to move ball once every frame (i.e., once every vsync pulse)
    mball : PROCESS
        VARIABLE temp : STD_LOGIC_VECTOR (11 DOWNTO 0);
    BEGIN
        WAIT UNTIL rising_edge(v_sync);
        IF start = '1' AND game_on = '0' THEN -- test for new serve
            game_on <= '1';
            ball_y_motion <= (NOT ball_speed) + 1; -- set vspeed to (- ball_speed) pixels
        END IF;
        -- allow for bounce off bat
        IF (ball_x + ball_w/2) >= (bat_x - bat_w) AND
         (ball_x - ball_w/2) <= (bat_x + bat_w) AND
             (ball_y + ball_h/2) >= (bat_y - bat_h) AND
             (ball_y - ball_h/2) <= (bat_y + bat_h) THEN
                ball_y_motion <= (NOT ball_speed) + 1; -- set vspeed to (- ball_speed) pixels
        END IF;
        -- compute next ball vertical position
        -- variable temp adds one more bit to calculation to fix unsigned underflow problems
        -- when ball_y is close to zero and ball_y_motion is negative
        temp := ('0' & ball_y) + (ball_y_motion(10) & ball_y_motion);
        IF game_on = '0' or laser_on = '0' THEN
            ball_y <= bat_y;--CONV_STD_LOGIC_VECTOR(440, 11);
        ELSIF temp(11) = '1' THEN
            ball_y <= (OTHERS => '0');
        ELSE ball_y <= temp(10 DOWNTO 0); -- 9 downto 0
        END IF;

        IF laser_on = '0' THEN
            ball_x <= bat_x;
        END IF;
    END PROCESS;
    
--    laser_shootshoot : process
    
--    end process;

aliendraw: PROCESS (pixel_row, pixel_col,alien1_y,alien2_y, alien3_y, alien4_y,alien5_y,alien6_y,alien7_y,alien8_y ) IS
    BEGIN
    -- draw first alien
        IF alien_on_screen(0) = '1' THEN 
            IF pixel_col >= alien1_x - aliensize AND
            pixel_col <= alien1_x + aliensize AND
                pixel_row >= alien1_y - aliensize AND
                pixel_row <= alien1_y + aliensize THEN
                   alien_on(0) <= '1';
            ELSE
                alien_on(0) <= '0';
            END IF;
        END IF;
    -- draw second alien
    IF alien_on_screen(1) = '1' THEN 
            IF pixel_col >= alien2_x - aliensize AND
            pixel_col <= alien2_x + aliensize AND
                pixel_row >= alien2_y - aliensize AND
                pixel_row <= alien2_y + aliensize THEN
                   alien_on(1) <= '1';
            ELSE
                alien_on(1) <= '0';
            END IF;
        END IF;
    -- draw third alien
    IF alien_on_screen(2) = '1' THEN 
            IF pixel_col >= alien3_x - aliensize AND
            pixel_col <= alien3_x + aliensize AND
                pixel_row >= alien3_y - aliensize AND
                pixel_row <= alien3_y + aliensize THEN
                   alien_on(2) <= '1';
            ELSE
                alien_on(2) <= '0';
            END IF;
        END IF;
    -- draw fourth alien
    IF alien_on_screen(3) = '1' THEN 
            IF pixel_col >= alien4_x - aliensize AND
            pixel_col <= alien4_x + aliensize AND
                pixel_row >= alien4_y - aliensize AND
                pixel_row <= alien4_y + aliensize THEN
                   alien_on(3) <= '1';
            ELSE
                alien_on(3) <= '0';
            END IF;
        END IF;
    -- draw fifth alien
    IF alien_on_screen(4) = '1' THEN 
            IF pixel_col >= alien5_x - aliensize AND
            pixel_col <= alien5_x + aliensize AND
                pixel_row >= alien5_y - aliensize AND
                pixel_row <= alien5_y + aliensize THEN
                   alien_on(4) <= '1';
            ELSE
                alien_on(4) <= '0';
            END IF;
        END IF;
     -- draw sixth alien
    IF alien_on_screen(5) = '1' THEN 
            IF pixel_col >= alien6_x - aliensize AND
            pixel_col <= alien6_x + aliensize AND
                pixel_row >= alien6_y - aliensize AND
                pixel_row <= alien6_y + aliensize THEN
                   alien_on(5) <= '1';
            ELSE
                alien_on(5) <= '0';
            END IF;
        END IF;
    -- draw seventh alien
    IF alien_on_screen(6) = '1' THEN 
            IF pixel_col >= alien7_x - aliensize AND
            pixel_col <= alien7_x + aliensize AND
                pixel_row >= alien7_y - aliensize AND
                pixel_row <= alien7_y + aliensize THEN
                   alien_on(6) <= '1';
            ELSE
                alien_on(6) <= '0';
            END IF;
        END IF;
    -- draw eigth alien
    IF alien_on_screen(7) = '1' THEN 
            IF pixel_col >= alien8_x - aliensize AND
            pixel_col <= alien8_x + aliensize AND
                pixel_row >= alien8_y - aliensize AND
                pixel_row <= alien8_y + aliensize THEN
                   alien_on(7) <= '1';
            ELSE
                alien_on(7) <= '0';
            END IF;
        END IF;
    END PROCESS;


laser_shootshoot : process(shoot, ball_y)
begin
    if shoot = '1' then
        laser_on <= '1';
    elsif ball_y <= ball_h THEN -- bounce off top wall
        laser_on <= '0';
    end if;
end process;
END Behavioral;
