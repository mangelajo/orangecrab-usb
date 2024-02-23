# orangecrab examples based on FPGA-USB-Device

This repository contains two examples using the great [FPGA-USB-Device](https://github.com/WangXuan95/FPGA-USB-Device) by WangXuan95 for the
OrangeCrab board.

## Building

You can install the yosys, nextpnr-ecp5 and dfu-utils locally, or the
makefile will automatically use the containers provided by 
https://github.com/mangelajo/fedora-hdl-containers if you have [podman](https://podman.io/docs/installation)
or [docker](https://docs.docker.com/engine/install/) installed in your system.


## Camera example
Build with:
`make`

you will get a .dfu file in the bin directory.

## Audio example
Build with, 

`make -f Makefile.audio`

this is an example connecting an INMP441 mems microphone
to the following pins:

* gpio_sck  -> i2s_mclk
* gpio_0    -> i2s_ws
* gpio_miso -> i2s_sd

Please note that the INMP441 is being oversampled by running a
the I2S clock over specification, in exchange we get only 16bits
instead of 24bits from the output, producing an overall better sound.




