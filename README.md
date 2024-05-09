# Final Project: Space Invaders

![Space Invaders](https://upload.wikimedia.org/wikipedia/en/0/0f/Space_Invaders_flyer%2C_1978.jpg)

## Expected Behavior

![Real Game GIF](https://codeheir.com/wp-content/uploads/2019/03/done.gif)

* Our goal in making this project is to mimic the gameplay of the Space Invaders video game (Above) as closely as possible.
  * The player should be able to move left and right to dodge enemy lasers while shooting lasers back.
  * Aliens should appear on the screen and slowly move towards the player while also shooting at them.
  * The player has multiple lives that decrease when they are hit by an alien's laser.
  * The player's score should increase whenever an alien is eliminated. 

## Neccessary Hardware

* [Nexys A7-100T FPGA Board](https://digilent.com/shop/nexys-a7-fpga-trainer-board-recommended-for-ece-curriculum/)
* Computer with *[Vivado](https://www.xilinx.com/products/design-tools/vivado.html)* installed
* Micro-USB Cable
* VGA Cable
* Monitor/TV with VGA input or VGA adapter

## Module Overview

* The **_[leddec16](/leddec16.vhd)_** module controls the displays on the Nexys A7 board.
  * By time multiplexing the 7-segment displays that share the same cathode lines (CA to CG), four different digits can appear on one display at a time.
    * Turn on display 0 for a few milliseconds by enabling its common anode AN0 and decoding data(0~3) to drive the cathode lines.
    * Switch to display 1 for a few milliseconds by turning   off AN0, turning on AN1 and decoding data(4~7) to drive the cathode lines.
    * Shift to display 2 for a few milliseconds and then finally display 3 for a few milliseconds, after that go back and start again at display 0.
    * While each digit is thus illuminated only one quarter of the time, it will appear to the naked eye that they're all on continuously.
  * The multiplexing clock (above) is controlled via the 'dig' input.
  * The score to display is controlled from the 'data' input.

* The **_[ship_n_laser](/ship_n_laser.vhd)_** module draws the ship, aliens, and laser(s) on the screen, controlling their movements and actions.
  * The VGA clock (v_sync), RGB signals (red, green, blue), pixel_row, and pixel_col ports are mapped to the [vga_sync](/vga_sync.vhd) module.
  * The ship_x port is determined by the [ship movement process](/space_invaders.vhd#L79-L89) in [space_invaders.vhd](/space_invaders.vhd).
  * The ports start, shoot, and quit are mapped directly to the buttons on the Nexys A7 board.
  * The score port outputs into the [leddec16](/leddec16.vhd) module to display the points earned.
  * 95% of the gameplay logic can be found in this module.
  * Specific details can be found in [Code Sources / Modifications](#code-sources--modifications).

* The **_[clk_wiz_0](/clk_wiz_0.vhd)_** and **_[clk_wiz_0_clk_wiz](/clk_wiz_0_clk_wiz.vhd)_** modules were taken from the [given code for Lab 6](https://github.com/byett/dsd/tree/CPE487-Spring2024/Nexys-A7/Lab-6) and left unmodified. These modules control the clock processes of the Nexys A7 board.
  * The Xilinx [Clocking Wizard](https://www.xilinx.com/products/intellectual-property/clocking_wizard.html).
  * [7 Series FPGAs Clocking Resources User Guide](https://www.xilinx.com/support/documentation/user_guides/ug472_7Series_Clocking.pdf).
  * CLKOUT0_DIVIDE_F in Line 124 of clk_wiz_0_clk_wiz.vhd was updated from 25.3125 to 25.25 because it shall be a multiple of 0.125.

* The **_[vga_sync](/vga_sync.vhd)_** module (also given and unmodified) uses a clock to drive horizontal and vertical counters h_cnt and v_cnt, respectively.
  * These counters are then used to generate the various timing signals.
  * The vertical and horizontal sync waveforms, vsync and hsync, will go directly to the VGA display with the column and row address, pixel_col and pixel_row, of the current pixel being displayed.
  * This module also takes as input the current red, green, and blue video data and gates it with a signal called video_on.
  * This ensures that no video is sent to the display during the sync and blanking periods.
  * Note that red, green, and blue video are each represented as 1-bit (on-off) quantities.
  * This is sufficient resolution for our application.

* The **_[space_invaders](/space_invaders.vhd)_** module is the top level.
  * Minor modifications (discussed below) were made to the [given Lab 6 file](https://github.com/byett/dsd/blob/CPE487-Spring2024/Nexys-A7/Lab-6/Alternative/pong_2.vhd) to fit with our adjusted **_[ship_n_laser](/ship_n_laser.vhd)_** module.
  * All 5 of the buttons on the lower right of the Nexys A7 board are used in this gameplay.
    * BTNU (Up) is used to start the game.
    * BTNC (Center) is used to shoot the lasers.
    * BTNL (Left) and BTNR (Right) are used to move the ship left and right, respectively.
    * BTND (Down) is used to quit the game.

## Code Sources / Modifications

### Modifications from [Lab 6 Alternate Code's pong_2 module](https://github.com/byett/dsd/blob/CPE487-Spring2024/Nexys-A7/Lab-6/Alternative/pong_2.vhd)

* Changed entity name from 'pong' to 'space_invaders'.
* Changed all instances of 'bat' to 'ship' and 'ball' to 'laser'.
* Initialized ship_x position to `CONV_STD_LOGIC_VECTOR(400,11)` in order to start the ship in the center of the screen.
* Added/Modified btnu (start), btnd (quit), and btnc (shoot) input ports and mapped accordingly to ship_n_laser component.
* Added 'score' output port to ship_n_laser component and mapped to leddec 'data' port.

### Processes added into [ship_n_laser](/ship_n_laser.vhd) architecture

1. [draw_ship](/ship_n_laser.vhd#L97-L115)
    * This process draws the ship that will be controlled by the player.
    * Has multiple if statements to draw the shape of the ship, which is a combination of 4 triangles and a rectangle.
2. [draw_laser](/ship_n_laser.vhd#L117-L127)
    * This process draws the shape of the laser that the player will shoot from their ship.
    * The laser is a simple rectangle with a height and width that is dependant on the values of the laser_h and laser_w constants.
3. [move_laser](/ship_n_laser.vhd#L129-L153)
    * This process determines the position of the player's laser.
    * The laser will stay in its idle position (just above the ship) if the game is not in play or the laser has not been shot. The "game_on" and "laser_shot" signals determine if the laser stays still or starts moving.
    * The equation to find the next vertical position was taken from the lab 6 code that determined the next position of the ball.
    * This process also has the code that determines if the game is currently in play or not. The game will stop if the player wins, loses, or quits their current round of aliens.
4. [shoot_laser](/ship_n_laser.vhd#L239-L269)
    * This process determines if the player's laser should appear on the screen or not.
    * If the player presses BTNC and the game is currently in play then the laser is shot. But if the laser touches the top of the screen or the game is not in play, then the laser will disappear.
    * This process also controls the collisions between the aliens and the player's laser and causes the aliens to disappear and the score to increase when they collide.
    * The X and Y coordinates of the 23 ships are stored in an array so that it is easy to loop through the array and check if the laser was close enough to collide with the alien.
    * This process resets the score whenever the loser does not win the round they are currently on.
    * Lastly, this processes causes the aliens to appear whenever there is a new round and increases their speed to make the game harder after the first round.
5. [draw_aliens](/ship_n_laser.vhd#L155-L160)
    * This process controls the shape of the enemy aliens.
    * The aliens are meant to look like UFOs.
    * To do this, the top half of a small semicircle was placed on top of the bottom half of a larger semicircle.
6. [move_aliens](/ship_n_laser.vhd#L207-L237)
    * This process controls the movement of the aliens.
    * The aliens move side to side and when they hit one of the side walls, they move downwards, closer to the player.
    * This process also causes the player to lose the game if the aliens get too close to the ship.
7. [draw_alien_laser](/ship_n_laser.vhd#L195-L205)
    * This process draws the shape of the laser that the enemy aliens shoot. It is the same size and shape as the laser that the player shoots.
8. [move_alien_laser](/ship_n_laser.vhd#L162-L193)
    * This process determines which alien the enemy laser starts from. To simulate that a random alien is shooting at the player, an array of integers from 0 to 22 was created and a variable was created to iterate through that array to get the random number.
    * This process also checks if the player's ship and the enemy laser have collided and decreases the player's lives by 1 if they have collided.
9. [draw_lives](/ship_n_laser.vhd#L271-L306)
    * This process draws the lives on the top left corner of the screen.
    * The lives were drawn in the shape of the spaceship.
    * As the player loses lives (in move_alien_laser), the associated life on the screen will dissapear.
10. [draw_text](/ship_n_laser.vhd#L308-L345)
    * This process draws the text on the screen.
    * This includes the "Lives:" text on the top of the screen, the "You Win"/"You Lose" text when game is won or lost, and the flashing "Press BTNU to Start" text when the game isn't running.
11. [flash_text](/ship_n_laser.vhd#L347-L352)
    * This process controls the flashing of the text at game start, win, or loss.
    * Signal 'flash_clock' iterates at each cycle of v_sync, and each time the limit is reached, the state of the text flips.

### Alien Array Logic

* A lot of thought was put into the creation of the aliens as there were multiple requirements that needed to be fulfilled:
  * There needed to be 23 identical aliens.
  * They all needed to be in different locations, but moving in sync with each other.
  * The aliens needed the ability to be shut off one at a time without affecting the other aliens.
* This was able to be accomplished in the following way:
  * The alien_x and alien_y positions were separated into a 23-index integer array, all based on the original x and y position.
  * This allows each alien to be put in a different position, while all moving in sync.
  * The alien_on and alien_on_screen signals were made as 23-bit logic vectors with each bit corresponding to a specific alien.
    * alien_on_screen controlled the drawing logic for each alien, while alien_on was or_reduced (Every bit orred with each other) into either a '1' or a '0' to turn on the green pixels.
  * Lastly, to allow every alien to be drawn distinctively without using 23 different blocks of code, a FOR loop was created to iterate between 0 and 22 to correspond to each index of the arrays.

### Text Display Logic

* Creating text to display can be quite difficult as the exact pixel-mapping can't be done through patterns the way shapes are.
* For the text in this project, we avoided using patterns by creating an exact pixel map of the text and storing it into a 2D binary array (Ex. you_win below).

```vhdl
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
```

* Lastly, in the [draw_text process](/ship_n_laser.vhd#L308-L345), a nested for loop is created to iterate through every index of the 2D Array, check if the specific pixel should be set to on or off, increasing by the set text size, and then centering the text in the specified area.

```vhdl
        win_on <= '0';
        FOR j IN 0 TO 15 LOOP
            FOR i IN 0 TO 63 LOOP
                IF (pixel_col >= 400 - (32 * text_size2) + text_size2 * i) AND (pixel_col < 400 - (32 * text_size2) + text_size2 * (i + 1)) AND (pixel_row >= 150 - (8 * text_size2) + text_size2 * j) AND (pixel_row < 150 - (8 * text_size2) + text_size2 * (j + 1)) AND
                you_win(j)(63 - i) = '1' AND win = '1' THEN win_on <= '1';
                END IF;
            END LOOP;
        END LOOP;
```

## Hardware Instructions

### 1. On your Nexys A7 board, connect the VGA port (Red) to your monitor, the USB port (Blue) to your computer, and ensure that the power switch (Purple) is set to "on". Note that adapters may be needed depending on your specific hardware

![Annotated Nexys A7 Board](https://github.com/vrenda720/DSD_Project/assets/91331978/40603d61-35d2-4873-a231-258c75c2a731)

## Vivado Project Instructions

### 1. Clone this github repository to your PC (Or download the files manually)

![Terminal Screenshot](https://github.com/vrenda720/DSD_Project/assets/91331978/b3381363-e96e-4cf0-824a-2962cea7008b)

### 2. Create a new RTL project _Space_Invaders_ in Vivado Quick Start

![Vivado Screenshot](https://github.com/vrenda720/DSD_Project/assets/91331978/b2711ad7-41ec-40d8-8338-e88ba8813179)

![Vivado Screenshot](https://github.com/vrenda720/DSD_Project/assets/91331978/1a6f0b8d-9813-4acd-914e-7d3f133c2866)

![Vivado Screenshot](https://github.com/vrenda720/DSD_Project/assets/91331978/49103c72-ef59-4fce-9d53-f25c7b762080)

* Import VHDL source files: **_[clk_wiz_0](/clk_wiz_0.vhd)_**, **_[clk_wiz_0_clk_wiz](/clk_wiz_0_clk_wiz.vhd)_**, **_[vga_sync](/vga_sync.vhd)_**, **_[ship_n_laser](/ship_n_laser.vhd)_**, **_[leddec16](/leddec16.vhd)_** and **_[space_invaders](/space_invaders.vhd)_**

![Vivado Screenshot](https://github.com/vrenda720/DSD_Project/assets/91331978/539b205a-c28a-4954-9438-ac311cb251e3)

* Import constraint file: **_[space_invaders](/space_invaders.xdc)_**

![Vivado Screenshot](https://github.com/vrenda720/DSD_Project/assets/91331978/86af17de-93f8-46c0-95c2-fe1546e2be47)

* Choose Nexys A7-100T board for the project

![Vivado Screenshot](https://github.com/vrenda720/DSD_Project/assets/91331978/bbcb4641-7e0a-4838-80b5-1de6ae8d5c35)

![Vivado Screenshot](https://github.com/vrenda720/DSD_Project/assets/91331978/6eb5a988-a023-465d-8737-532d68c762a9)

* Click 'Finish'

![Vivado Screenshot](https://github.com/vrenda720/DSD_Project/assets/91331978/0cdce3ff-3420-4f4b-a4ac-5fe151650c5b)

### 3. Run Synthesis

![Vivado Screenshot](https://github.com/vrenda720/DSD_Project/assets/91331978/c63c485f-852d-4f30-b624-3b40da176d78)

### 4. Run Implementation

![Vivado Screenshot](https://github.com/vrenda720/DSD_Project/assets/91331978/bfaec302-edc0-4216-89f9-512699cb401e)

### 5. Generate Bitstream, Open Hardware Manager, and Program Device

* Click 'Generate Bitstream'

![Vivado Screenshot](https://github.com/vrenda720/DSD_Project/assets/91331978/0b6f9f52-d0b1-48e5-98c5-8e880403e16f)

* Click 'Open Hardware Manager' and click 'Open Target' then 'Auto Connect'

![Vivado Screenshot](https://github.com/vrenda720/DSD_Project/assets/91331978/a9293b81-5bf0-4940-9c70-e8d6c3dadcfd)
![Vivado Screenshot](https://github.com/vrenda720/DSD_Project/assets/91331978/e43221ec-15d6-434b-847f-aa08302d53e3)

* Click 'Program Device', then select space_invaders.bit to download to the Nexys A7-100T board

![Vivado Screenshot](https://github.com/vrenda720/DSD_Project/assets/91331978/e90815b7-f2e4-4986-8ae2-fb473bbf9f56)
![Vivado Screenshot](https://github.com/vrenda720/DSD_Project/assets/91331978/ec5acdbf-7f61-48da-b2b8-b0b157f13590)

## Alternative Vivado Instructions

### 1. Download **_space_invaders.bit_** from our [releases](https://github.com/vrenda720/DSD_Project/releases) page

### 2. Open Vivado

### 3. From the **Tasks** Menu, select **_Open Hardware Manager_**

![Vivado Screenshot](https://github.com/vrenda720/DSD_Project/assets/91331978/5241a127-4fb3-4039-ba26-b023f813a07b)

### 4. Select **_Open Target_**, then **_Auto Connect_**

![Vivado Screenshot](https://github.com/vrenda720/DSD_Project/assets/91331978/08292c79-2daa-47c8-b659-e1426efc806f)
![Vivado Screenshot](https://github.com/vrenda720/DSD_Project/assets/91331978/b92b8409-1df6-417c-aa66-4aa514c5f655)

### 5. Click **_Program Device_** then select the downloaded bitstream file, and click **_Program_**

![Vivado Screenshot](https://github.com/vrenda720/DSD_Project/assets/91331978/04e4beb3-3021-4ab2-8bd4-bc47527d7f69)
![Vivado Screenshot](https://github.com/vrenda720/DSD_Project/assets/91331978/9d751b0b-6219-474b-bdcd-30804bd02f2f)

## Gameplay Summary

* When the bitstream is initially uploaded to the FPGA board, the player will be able see their ship and flashing text that says "Press BTNU to Start".

![startgif](https://github.com/vrenda720/DSD_Project/assets/91331978/f0839c2e-a1d2-4cc7-95eb-690a7558d0d6)

* Once BTNU is clicked, the aliens will appear and start shooting downwards towards the player. The player will have to dodge the enemy lasers and shoot back at the aliens. If an enemy laser hits the player they will lose one of the lives that are indicated on the top right of the screen.
* The player will be able to move their ship left and right by pressing BTNL and BTNR respectively.
* Pressing BTNC will allow the player to shoot back at the aliens. Hitting an alien with a laser will cause that alien to disappear and the players score will increase, the player's score is visable on the FPGA board itself.

![image](/Img/scoreincreasing.gif)

* By eliminating all the aliens on the screen, the player will have won that round and a screen will appear that says, "You Win" and "Press BTNU to Continue". If the player chooses to continue, they will keep their score and more aliens will appear but this time they will move faster.

![image](/Img/Wingif.gif)

* If the player is unable to dodge the lasers being shot at them and lose all 3 of their lives, a screen will appear that says, "You Lose" and "Press BTNU to Restart". When the player presses BTNU, new aliens will appear and their score will be reset.

![Liveslose](https://github.com/vrenda720/DSD_Project/assets/91331978/f237b627-cd5b-40d4-9094-2f359979d329)

* If the player chooses to quit the current round they are in by pressing BTND, a screen will appear that says, "You Lose" and "Press BTNU to Restart". When the player presses BTNU, new aliens will appear and their score will be reset.
* If the player is not able to eliminate all the aliens before they pass the ship, a screen will appear that says, "You Lose" and "Press BTNU to Restart". When the player presses BTNU, new aliens will appear and their score will be reset.

![Invasionlose](https://github.com/vrenda720/DSD_Project/assets/91331978/b8e88863-80c5-4cf3-b156-7775281e8854)


## Concluding Summary

### Contributions

Moshe:

* All text graphics
* Added in text flashing
* Added in aliens (movement/shape)
* Added in lives
* Added in quit feature
* Added to README

Vincent:

* Ship graphic (I hate triangles)
* Laser-Alien collision
* Laser-Player collision
* Added in player's laser (movement/shape)
* Added in enemy laser (movement/shape/randomeness)
* Made score display on FPGA board
* Added to README

<!-- ![battle](https://github.com/vrenda720/DSD_Project/assets/91331978/df49b37c-8393-4c2d-967f-2bfaf791f4b3) -->

### Timeline

* Thursday May 2: Project/Repo started, triangle ship made, preliminary alien code put in place.
* Friday May 3/Saturday May 4: Combined aliens into arrays called by for loops, built ship shape, created laser shooting and functionality.
* Sunday May 5: Some debugging, added speed increase on game win, added quit option, added preliminary win/lose graphic, started README.
* Monday May 6: Added text, added enemy retaliation, added preliminary lives, condensed code.
* Tuesday May 7: Added lives shape, debugged code.
* Wednesday May 8: Minor debugging, built up README.
* Thursday May 9: Finalized README, prepared submission.

### Difficulties

* Some processes would not work correctly if they did not wait until the rising edge of v_sync even if the logic within the processes were correct. This took a lot of time to realize.
  * After much experimentation, it was found that the **"move"** processes needed to have the process begin by waiting for the rising edge of v_sync, while the **"draw"** processes were better with a sensitivity list rather than a wait statement.
* Triangles were somewhat difficult to add in. The fact that the origin for the coordinate system is on the top-left and not the bottom-left created some confusion when making the processes that drew out triangles.
* Keeping track of 23 aliens and their movement/collisions was difficult so we turned things like the position of each alien and if each alien should appear on the screen into an array that can be easily looped through.
  * This is more thoroughly discussed in [Alien Array Logic](#Alien-Array-Logic).
* There did not seem to be a built in random number generator so we decided to streamline the process of random number generation by compiling an extensive array of predetermined random values for efficient utilization.
