LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY space_invaders IS
    PORT (
        clk_in : IN STD_LOGIC; -- system clock
        VGA_red : OUT STD_LOGIC_VECTOR (3 DOWNTO 0); -- VGA red output
        VGA_green : OUT STD_LOGIC_VECTOR (3 DOWNTO 0); -- VGA green output
        VGA_blue : OUT STD_LOGIC_VECTOR (3 DOWNTO 0); -- VGA blue output
        VGA_hsync : OUT STD_LOGIC;
        VGA_vsync : OUT STD_LOGIC;
        btnl : IN STD_LOGIC; -- Left Button
        btnu : IN STD_LOGIC; -- Up Button
        btnr : IN STD_LOGIC; -- Right Button
        btnc : IN STD_LOGIC; -- Center Button
        SEG7_anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- anodes of four 7-seg displays
        SEG7_seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0) -- seg of four 7-seg displays
    ); 
END space_invaders;

ARCHITECTURE Behavioral OF space_invaders IS
    SIGNAL pxl_clk : STD_LOGIC := '0'; -- 25 MHz clock to VGA sync module
    -- internal signals to connect modules
    SIGNAL S_red, S_green, S_blue : STD_LOGIC; --_VECTOR (3 DOWNTO 0);
    SIGNAL S_vsync : STD_LOGIC;
    SIGNAL S_pixel_row, S_pixel_col : STD_LOGIC_VECTOR (10 DOWNTO 0);
    SIGNAL shippos : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400,11); -- Start ship at center
    SIGNAL count : STD_LOGIC_VECTOR (20 DOWNTO 0); -- 21-bit multiplexing counter
    SIGNAL display : std_logic_vector (15 DOWNTO 0); -- Value to be displayed
    SIGNAL led_mpx : STD_LOGIC_VECTOR (2 DOWNTO 0); -- 7-seg multiplexing clock
    COMPONENT ship_n_laser IS
        PORT (
            v_sync : IN STD_LOGIC; -- vga "clock"
            pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
            pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
            ship_x : IN STD_LOGIC_VECTOR (10 DOWNTO 0); -- Ship x position
            start : IN STD_LOGIC; -- Starts/Resets Game
            shoot : IN STD_LOGIC; -- Shoots Laser
            score : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            red : OUT STD_LOGIC; -- VGA Red
            green : OUT STD_LOGIC; -- VGA Green
            blue : OUT STD_LOGIC -- VGA Blue
        );
    END COMPONENT;
    COMPONENT vga_sync IS
        PORT (
            pixel_clk : IN STD_LOGIC;
            red_in    : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            green_in  : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            blue_in   : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            red_out   : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            green_out : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            blue_out  : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            hsync : OUT STD_LOGIC;
            vsync : OUT STD_LOGIC;
            pixel_row : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
            pixel_col : OUT STD_LOGIC_VECTOR (10 DOWNTO 0)
        );
    END COMPONENT;
    COMPONENT clk_wiz_0 IS
        PORT (
            clk_in1  : IN STD_LOGIC;
            clk_out1 : OUT STD_LOGIC
        );
    END COMPONENT;
    COMPONENT leddec16 IS
        PORT (
            dig : IN STD_LOGIC_VECTOR (2 DOWNTO 0); -- which digit to currently display
            data : IN STD_LOGIC_VECTOR (15 DOWNTO 0); -- 16-bit (4-digit) data
            anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- which anode to turn on
            seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)); -- segment code for current digit
    END COMPONENT;
    
BEGIN
    pos : PROCESS (clk_in) is
    BEGIN
        IF rising_edge(clk_in) then
            count <= count + 1;
            IF (btnl = '1' and count = 0 and shippos > 0) THEN
                shippos <= shippos - 10;
            ELSIF (btnr = '1' and count = 0 and shippos < 800) THEN
                shippos <= shippos + 10;
            END IF;
        END IF;
    END PROCESS;
    led_mpx <= count(19 DOWNTO 17); -- 7-seg multiplexing clock    
    add_sl : ship_n_laser
    PORT MAP(
        v_sync => S_vsync, 
        pixel_row => S_pixel_row, 
        pixel_col => S_pixel_col, 
        ship_x => shippos, 
        start => btnu,
        shoot => btnc,
        score => display,
        red => S_red, 
        green => S_green, 
        blue => S_blue
    );
    
    vga_driver : vga_sync
    PORT MAP(
        pixel_clk => pxl_clk, 
        red_in => S_red & "000", 
        green_in => S_green & "000", 
        blue_in => S_blue & "000", 
        red_out => VGA_red, 
        green_out => VGA_green, 
        blue_out => VGA_blue, 
        pixel_row => S_pixel_row, 
        pixel_col => S_pixel_col, 
        hsync => VGA_hsync, 
        vsync => S_vsync
    );
    VGA_vsync <= S_vsync; --connect output vsync
        
    clk_wiz_0_inst : clk_wiz_0
    PORT MAP (
      clk_in1 => clk_in,
      clk_out1 => pxl_clk
    );
    led1 : leddec16
    PORT MAP(
      dig => led_mpx, data => display, 
      anode => SEG7_anode, seg => SEG7_seg
    );
END Behavioral;
