# nodemcu_toybox

This is my nodemcu toybox. Mainly, here is my HTTP bootloader thing. 

`init.lua` also has a function named `soon` which basically keeps track of timers and runs stuff in 10ms by default.

Timer juggeling is very useful.

# Setup
## MCU
Install nodemcu-tool, run `make`. Do make sure you tweaked scripts/wifi-setup.lua before, same with scripts/loadremote.lua, the URLs/mirrors.

There is a prebuilt firmware of the `dev` branch in the fw folder.

It has following libraries built in:

- ADC
- bit
- CJSON
- crypto
- encoder
- file
- GPIO
- HTTP
- i2c
- net
- node
- 1-Wire
- PWM
- RTC mem
- RTC time
- sntp
- SPI
- timer
- UART
- WiFi

## Server
For my bootloader to work, you need a custom web server script.

I have a very basic one built on [CApptain](https://github.com/vifino/capptain), the files you need to place capptains apps folder are in the `server` folder.

When the MCU requests a file, it looks for `nodemcu-fetch/<Wifi MAC with : deleted>/<file>`.
