<!-- # Tomorrow

![image](battle.jpg) -->

# Final Project: Space Invaders

# **[Project Instructions](https://github.com/moshem1234/dsd/blob/CPE487-Spring2024/Projects/README.md)**

![Space Invaders](https://upload.wikimedia.org/wikipedia/en/0/0f/Space_Invaders_flyer%2C_1978.jpg)

## Expected Behavior

![Real Game GIF](https://codeheir.com/wp-content/uploads/2019/03/done.gif)

* Our goal in making this project is to mimic the gameplay of the Space Invaders video game (Above) as closely as possible.
* ...
* ...
* ...

## Module Overview

* The **_[bat_n_ball](/bat_n_ball.vhd)_** module draws the bat and ball on the screen and also causes the ball to bounce (by reversing its speed) when it collides with the bat or one of the walls.
  * It also uses a variable game_on to indicate whether the ball is currently in play.
  * When game_on = ‘1’, the ball is visible and bounces off the bat and/or the top, left and right walls.
  * If the ball hits the bottom wall, game_on is set to ‘0’. When game_on = ‘0’, the ball is not visible and waits to be served.
  * When the serve input goes high, game_on is set to ‘1’ and the ball becomes visible again.

* The **_[clk_wiz_0](/clk_wiz_0.vhd)_** and **_[clk_wiz_0_clk_wiz](/clk_wiz_0_clk_wiz.vhd)_** modules were taken from the [given code for Lab 6](https://github.com/byett/dsd/tree/CPE487-Spring2024/Nexys-A7/Lab-6) and left unmodified. These modules do .........

* The **_[vga_sync](/vga_sync.vhd)_** module uses a clock to drive horizontal and vertical counters h_cnt and v_cnt, respectively.
  * These counters are then used to generate the various timing signals.
  * The vertical and horizontal sync waveforms, vsync and hsync, will go directly to the VGA display with the column and row address, pixel_col and pixel_row, of the current [pixel](https://en.wikipedia.org/wiki/Pixel) being displayed.
  * This module also takes as input the current red, green, and blue video data and gates it with a signal called video_on.
  * This ensures that no video is sent to the display during the sync and blanking periods.
  * Note that red, green, and blue video are each represented as 1-bit (on-off) quantities.
  * This is sufficient resolution for our application.

* The **_[adc_if](/adc_if.vhd)_** module (also given and unmodified) converts the serial data from both channels of the ADC into 12-bit parallel format.
  * When the CS line of the ADC is taken low, it begins a conversion and serially outputs a 16-bit quantity on the next 16 falling edges of the ADC serial clock.
  * The data consists of 4 leading zeros followed by the 12-bit converted value.
  * These 16 bits are loaded into a 12-bit shift register from the least significant end.
  * The top 4 zeros fall off the most significant end of the shift register leaving the 12-bit data in place after 16 clock cycles.
  * When CS goes high, this data is synchronously loaded into the two 12-bit parallel outputs of the module.

* The **_[pong](/pong_2.vhd)_** module is the top level.
  * All 5 of the buttons on the lower right of the NexysA7 board are used in this gameplay.
    * BTNU is used to start the game.
    * BTNC is used to shoot the lasers.
    * BTNL and BTNR are used to move the ship left and right, respectively.
    * BTND is used to quit the game.
  * The process ckp is used to generate timing signals for the VGA and ADC modules.
  * The output of the adc_if module drives ship_x of the ship_n_laser module.

## Code Sources / Modifications

...

## Vivado Project Instructions

### 1. Create a new RTL project _Space_ in Vivado Quick Start

* Import VHDL source files: **_[clk_wiz_0](/clk_wiz_0.vhd)_**, **_[clk_wiz_0_clk_wiz](/clk_wiz_0_clk_wiz.vhd)_**, **_[vga_sync](/vga_sync.vhd)_**, **_[bat_n_ball](/bat_n_ball.vhd)_**, **_[adc_if](/adc_if.vhd)_**, **_[leddec16](/leddec16.vhd)_** and **_[pong_2](/pong_2.vhd)_**

* Import constraint file: **_[pong_2](/pong_2.xdc)_**

* Choose Nexys A7-100T board for the project

* Click 'Finish'

### 2. Run Synthesis

### 3. Run Implementation

### 4. Generate Bitstream, Open Hardware Manager, and Program Device

* Click 'Generate Bitstream'

* Click 'Open Hardware Manager' and click 'Open Target' then 'Auto Connect'

* Click 'Program Device' then xc7a100t_0 to download space_invaders.bit to the Nexys A7-100T board

## Summary

...
