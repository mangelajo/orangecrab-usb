PROJ=fpga_top_usb_camera
TOP_MODULE=fpga_top_usb_camera
FPGA_USB_D=ip/FPGA-USB-Device/RTL

PLL_FNAME=ip/pll
VERILOG_FILES=hdl/${TOP_MODULE}.v $(PLL_FNAME).v \
			  ${FPGA_USB_D}/usbfs_core/*.v \
			  ${FPGA_USB_D}/usb_class/usb_camera_top.v

SYNTH_FLAGS=-noabc9 # yosys's abc9 crashes with the FPGA-USB-Device code
YOSYS_FLAGS=-q

include common.mk
include container.mk
