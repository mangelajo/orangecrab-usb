
//--------------------------------------------------------------------------------------------------------
// Module  : fpga_top_usb_camera
// Type    : synthesizable, fpga top
// Standard: Verilog 2001 (IEEE1364-2001)
// Function: example for usb_camera_top
//--------------------------------------------------------------------------------------------------------

module fpga_top_usb_camera (
    // clock
    input  wire        clk48,     // connect to a 50MHz oscillator
    // reset button
    input  wire        usr_btn,       // connect to a reset button, 0=reset, 1=release. If you don't have a button, tie this signal to 1.
    // LED
    output wire        rgb_led0_b,          // 1: USB connected , 0: USB disconnected
    // USB signals
    output wire        usb_pullup,  // connect to USB D+ by an 1.5k resistor
    inout              usb_d_p,       // connect to USB D+
    inout              usb_d_n,       // connect to USB D-
    // debug output info, only for USB developers, can be ignored for normally use
);




//-------------------------------------------------------------------------------------------------------------------------------------
// The USB controller core needs a 60MHz clock, this PLL module is to convert clk50mhz to clk60mhz
// This PLL module is only available on Altera Cyclone IV E.
// If you use other FPGA families, please use their compatible primitives or IP-cores to generate clk60mhz
//-------------------------------------------------------------------------------------------------------------------------------------
wire [3:0] subwire0;
wire       clk60mhz;
wire       clk_locked;
// instantiate PLL
  pll my_pll(
    .clkin(clk48),
    .clkout0(clk60mhz),
    .locked(clk_locked)
  );


//-------------------------------------------------------------------------------------------------------------------------------------
// USB-UVC camera device
//-------------------------------------------------------------------------------------------------------------------------------------

wire        vf_sof;
wire        vf_req;
reg  [ 7:0] vf_byte;

usb_camera_top #(
    .FRAME_TYPE      ( "MONO"              ),   // "MONO" or "YUY2"
    .FRAME_W         ( 14'd252             ),   // video-frame width  in pixels, must be a even number
    .FRAME_H         ( 14'd120             ),   // video-frame height in pixels, must be a even number
    .DEBUG           ( "FALSE"             )    // If you want to see the debug info of USB device core, set this parameter to "TRUE"
) u_usb_camera (
    .rstn            ( clk_locked & usr_btn ),
    .clk             ( clk60mhz            ),
    // USB signals
    .usb_dp_pull     ( usb_pullup         ),
    .usb_dp          ( usb_d_p              ),
    .usb_dn          ( usb_d_n              ),
    // USB reset output
    .usb_rstn        ( rgb_led0_b                 ),   // 1: connected , 0: disconnected (when USB cable unplug, or when system reset (rstn=0))
    // video frame fetch interface
    .vf_sof          ( vf_sof              ),
    .vf_req          ( vf_req              ),
    .vf_byte         ( vf_byte             ),
    // debug output info, only for USB developers, can be ignored for normally use
    .debug_en        (                     ),
    .debug_data      (                     ),
    .debug_uart_tx   (              )
);




//-------------------------------------------------------------------------------------------------------------------------------------
// generate pixels
//-------------------------------------------------------------------------------------------------------------------------------------
reg  [7:0] init_pixel = 8'h00;

always @ (posedge clk60mhz)
    if (vf_sof) begin                          // at start of frame
        init_pixel <= init_pixel + 8'h1;
        vf_byte <= init_pixel;
    end else if (vf_req) begin                 // request a pixel
        vf_byte <= vf_byte + 8'h1;
    end



endmodule
