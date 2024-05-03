<!-- # Tomorrow

![image](battle.jpg) -->

# Final Project: Space Invaders

# **[Project Instructions](https://github.com/moshem1234/dsd/blob/CPE487-Spring2024/Projects/README.md)**

![Space Invaders](https://upload.wikimedia.org/wikipedia/en/0/0f/Space_Invaders_flyer%2C_1978.jpg)

## Expected Behavior

...

![Real Game GIF](https://codeheir.com/wp-content/uploads/2019/03/done.gif)

## Module Overview

* The **_bat_n_ball_** module draws the bat and ball on the screen and also causes the ball to bounce (by reversing its speed) when it collides with the bat or one of the walls.
  * It also uses a variable game_on to indicate whether the ball is currently in play.
  * When game_on = ‘1’, the ball is visible and bounces off the bat and/or the top, left and right walls.
  * If the ball hits the bottom wall, game_on is set to ‘0’. When game_on = ‘0’, the ball is not visible and waits to be served.
  * When the serve input goes high, game_on is set to ‘1’ and the ball becomes visible again.

* The **_adc_if_** module converts the serial data from both channels of the ADC into 12-bit parallel format.
  * When the CS line of the ADC is taken low, it begins a conversion and serially outputs a 16-bit quantity on the next 16 falling edges of the ADC serial clock.
  * The data consists of 4 leading zeros followed by the 12-bit converted value.
  * These 16 bits are loaded into a 12-bit shift register from the least significant end.
  * The top 4 zeros fall off the most significant end of the shift register leaving the 12-bit data in place after 16 clock cycles.
  * When CS goes high, this data is synchronously loaded into the two 12-bit parallel outputs of the module.

* The **_pong_** module is the top level.
  * BTN0 on the NexysA7 board is used to start the game.
  * The process ckp is used to generate timing signals for the VGA and ADC modules.
  * The output of the adc_if module drives bat_x of the bat_n_ball module.

## Code Sources / Modifications

...

## Vivado Project Instructions

### 1. Create a new RTL project _space_ in Vivado Quick Start

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
