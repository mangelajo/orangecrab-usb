
//--------------------------------------------------------------------------------------------------------
// Module  : fpga_top_usb_audio
// Type    : synthesizable, fpga top
// Standard: Verilog 2001 (IEEE1364-2001)
// Function: example for usb_audio_top
//--------------------------------------------------------------------------------------------------------

module fpga_top_usb_audio (
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

    // I2S signals
    output wire        gpio_sck,  //  i2s_mclk,   // I2S clock
    output wire        gpio_0,    //  i2s_ws,    // I2S word select
    input  wire        gpio_miso  // i2s_sd,    // I2S serial data

  );



//-------------------------------------------------------------------------------------------------------------------------------------
// The USB controller core needs a 60MHz clock, this PLL module is to convert clk50mhz to clk60mhz
// This PLL module is only available on Altera Cyclone IV E.
// If you use other FPGA families, please use their compatible primitives or IP-cores to generate clk60mhz
//-------------------------------------------------------------------------------------------------------------------------------------
wire [3:0] subwire0;
wire       clk60mhz;
wire       clk_locked;
wire [31:0] audio_l, audio_r;

wire clk3_15mhz;

// instantiate PLL
  pll my_pll(
    .clkin(clk48),
    .clkout0(clk60mhz),
    .locked(clk_locked)
  );

  clkdiv #(
    .DIVISOR(10) // The divisor of the input clock
  ) u_clkdiv (
    .clk_in(clk60mhz),
    .clk_out(clk3_15mhz)
  );

  i2s u_i2s (
    .rstn       ( clk_locked & usr_btn ),
    .clk_in     ( clk3_15mhz ),
    .i2s_mclk   ( gpio_sck   ),
    .i2s_ws     ( gpio_0     ),
    .i2s_sd     ( gpio_miso  ),
    .left_data  ( audio_l    ),
    .right_data ( audio_r    )
  );

//-------------------------------------------------------------------------------------------------------------------------------------
// USB-UAC audio output (speaker) and input (microphone) device
//-------------------------------------------------------------------------------------------------------------------------------------

// Here we simply make a loopback connection for testing.
// The audio output will be returned to the audio input.
// You can play music to the device, and then use a record software to record voice from the device. The music you played will be recorded.


usb_audio_top #(
    .DEBUG           ( "FALSE"             )    // If you want to see the debug info of USB device core, set this parameter to "TRUE"
) u_usb_audio (
    .rstn            ( clk_locked & usr_btn ),
    .clk             ( clk60mhz            ),
    // USB signals
    .usb_dp_pull     ( usb_pullup          ),
    .usb_dp          ( usb_d_p             ),
    .usb_dn          ( usb_d_n             ),
    // USB reset output
    .usb_rstn        ( rgb_led0_b                 ),   // 1: connected , 0: disconnected (when USB cable unplug, or when system reset (rstn=0))
    // user data : audio output (host-to-device, such as a speaker), and audio input (device-to-host, such as a microphone).
    .audio_en        (                     ),
    .audio_lo        (                     ),   // left-channel output : 16-bit signed integer, which will be valid when audio_en=1
    .audio_ro        (                     ),   // right-channel output: 16-bit signed integer, which will be valid when audio_en=1
    .audio_li        ( audio_r[30:15]      ),   // left-channel input  : 16-bit signed integer, which will be sampled when audio_en=1
    .audio_ri        ( audio_r[30:15]      ),   // right-channel input : 16-bit signed integer, which will be sampled when audio_en=1
    // debug output info, only for USB developers, can be ignored for normally use
    .debug_en        (                     ),
    .debug_data      (                     ),
    .debug_uart_tx   (                     )
);



endmodule
