
# Final Project: Space Invaders

> # **[Project Instructions](https://github.com/moshem1234/dsd/blob/CPE487-Spring2024/Projects/README.md)**

![Space Invaders](https://upload.wikimedia.org/wikipedia/en/0/0f/Space_Invaders_flyer%2C_1978.jpg)

## Expected Behavior

![Real Game GIF](https://codeheir.com/wp-content/uploads/2019/03/done.gif)

> TODO: Describe regular space invaders gameplay in a few bullets

* Our goal in making this project is to mimic the gameplay of the Space Invaders video game (Above) as closely as possible.
* ...
* ...
* ...

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
    * Shift to display 2 for a few milliseconds and then finally display 3 for a few milliseconds, after that go   back and start again at display 0.
    * While each digit is thus illuminated only one quarter of the time, it will appear to the naked eye that they're all on continuously.
  * The multiplexing clock (above) is controlled via the 'dig' input.
  * The score to display is controlled from the 'data' input.

* The **_[ship_n_laser](/bat_n_ball.vhd)_** module draws the ship, aliens, and laser(s) on the screen, controlling their movements and actions.
  * 95% of the gameplay logic can be found in this module.
  * Specific details can be found in [Code Sources / Modifications](#code-sources--modifications).

* The **_[clk_wiz_0](/clk_wiz_0.vhd)_** and **_[clk_wiz_0_clk_wiz](/clk_wiz_0_clk_wiz.vhd)_** modules were taken from the [given code for Lab 6](https://github.com/byett/dsd/tree/CPE487-Spring2024/Nexys-A7/Lab-6) and left unmodified. These modules control the clock processes of the Nexys A7 board.
  * The Xilinx [Clocking Wizard](https://www.xilinx.com/products/intellectual-property/clocking_wizard.html)
  * [7 Series FPGAs Clocking Resources User Guide](https://www.xilinx.com/support/documentation/user_guides/ug472_7Series_Clocking.pdf)
  * CLKOUT0_DIVIDE_F in Line 124 of clk_wiz_0_clk_wiz.vhd was updated from 25.3125 to 25.25 because it shall be a multiple of 0.125

* The **_[vga_sync](/vga_sync.vhd)_** module (also given and unmodified) uses a clock to drive horizontal and vertical counters h_cnt and v_cnt, respectively.
  * These counters are then used to generate the various timing signals.
  * The vertical and horizontal sync waveforms, vsync and hsync, will go directly to the VGA display with the column and row address, pixel_col and pixel_row, of the current pixel being displayed.
  * This module also takes as input the current red, green, and blue video data and gates it with a signal called video_on.
  * This ensures that no video is sent to the display during the sync and blanking periods.
  * Note that red, green, and blue video are each represented as 1-bit (on-off) quantities.
  * This is sufficient resolution for our application.

* The **_[space_invaders](/pong_2.vhd)_** module is the top level.
  * Minor modifications were made to the [given Lab 6 file](https://github.com/byett/dsd/blob/CPE487-Spring2024/Nexys-A7/Lab-6/Alternative/pong_2.vhd) to fit with our adjusted **_[ship_n_laser](/bat_n_ball.vhd)_** module
  * All 5 of the buttons on the lower right of the Nexys A7 board are used in this gameplay.
    * BTNU (Up) is used to start the game.
    * BTNC (Center) is used to shoot the lasers.
    * BTNL (Left) and BTNR (Right) are used to move the ship left and right, respectively.
    * BTND (Down) is used to quit the game.

## Code Sources / Modifications

### Modifications from [Lab 6 Alternate Code](https://github.com/byett/dsd/blob/CPE487-Spring2024/Nexys-A7/Lab-6/Alternative) ([pong_2.vhd/space_invaders.vhd](/pong_2.vhd) and [pong_2.xdc/space_invaders.xdc](/pong_2.xdc))

* Changed entity name from 'pong' to 'space_invaders'
* Changed all instances of 'bat' to 'ship' and 'ball' to 'laser'
* Initialized ship_x position to `CONV_STD_LOGIC_VECTOR(400,11)` in order to start the ship in the center of the screen.
* Added/Modified btnu (start), btnd (quit), and btnc (shoot) input ports and mapped accordingly to ship_n_laser component
* Added 'score' output port to ship_n_laser component and mapped to leddec 'data' port

> TODO: List processes in *ship_n_laser* and describe logic for each one

## Hardware Instructions

### 1. On your Nexys A7 board, connect the VGA port (Red) to your monitor, the USB port (Blue) to your computer, and ensure that the power switch (Purple) is set to "on". Note that adapters may be needed depending on your specific hardware

![image (1)](https://github.com/vrenda720/DSD_Project/assets/91331978/40603d61-35d2-4873-a231-258c75c2a731)

## Vivado Project Instructions

> TODO: (Maybe) Add pictures

### 1. Clone this github repository to your PC (Or download the files manually)

### 2. Create a new RTL project _Space_ in Vivado Quick Start

* Import VHDL source files: **_[clk_wiz_0](/clk_wiz_0.vhd)_**, **_[clk_wiz_0_clk_wiz](/clk_wiz_0_clk_wiz.vhd)_**, **_[vga_sync](/vga_sync.vhd)_**, **_[bat_n_ball](/bat_n_ball.vhd)_**, **_[leddec16](/leddec16.vhd)_** and **_[pong_2](/pong_2.vhd)_**

* Import constraint file: **_[pong_2](/pong_2.xdc)_**

* Choose Nexys A7-100T board for the project

* Click 'Finish'

### 3. Run Synthesis

### 4. Run Implementation

### 5. Generate Bitstream, Open Hardware Manager, and Program Device

* Click 'Generate Bitstream'

* Click 'Open Hardware Manager' and click 'Open Target' then 'Auto Connect'

* Click 'Program Device' then xc7a100t_0 to download space_invaders.bit to the Nexys A7-100T board

## Alternative Vivado Instructions

### 1. Download **_space_invaders.bit_** from our [releases](https://github.com/vrenda720/DSD_Project/releases) page

### 2. Open Vivado

### 3. From the **Tasks** Menu, select **_Open Hardware Manager_**

![image](https://github.com/vrenda720/DSD_Project/assets/91331978/5241a127-4fb3-4039-ba26-b023f813a07b)

### 4. Select **_Open Target_**, then **_Auto Connect_**

![image](https://github.com/vrenda720/DSD_Project/assets/91331978/08292c79-2daa-47c8-b659-e1426efc806f)
![image](https://github.com/vrenda720/DSD_Project/assets/91331978/b92b8409-1df6-417c-aa66-4aa514c5f655)

### 5. Click **_Program Device_** then select the downloaded bitstream file, and click **_Program_**

![image](https://github.com/vrenda720/DSD_Project/assets/91331978/04e4beb3-3021-4ab2-8bd4-bc47527d7f69)
![image](https://github.com/vrenda720/DSD_Project/assets/91331978/9d751b0b-6219-474b-bdcd-30804bd02f2f)

## Gameplay Summary

> TODO: Include sentence description and video/GIF for each of the following:
>
> * Flashing text after first programmed
> * Game in action
>   * Losing lives when hit
>   * Aliens disappearing when shot
>   * Score going up when aliens hit
> * Game win + Win Screen
> * Game loss (out of lives) + Lose Screen
> * Game loss (Aliens fall too low) + Lose Screen
> * Game quit + Lose screen

![image](battle.jpg)
