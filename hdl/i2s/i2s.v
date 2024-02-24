module i2s (
    input            rstn,      // reset
    input            clk_in,    // 64fs clock
    output           i2s_mclk,  // I2S clock
    output           i2s_ws,    // I2S word select
    input            i2s_sd,    // I2S serial data
    output reg[31:0] left_data, // left channel data
    output reg[31:0] right_data // right channel data

);

reg[5:0]  bit_counter; // will count from 0 to 63
reg[5:0]  bit_counter_ws; // will count from 0 to 63
reg[63:0] data;        // shift register

assign i2s_ws   = bit_counter_ws[5];
assign i2s_mclk = clk_in;

always @(negedge clk_in or negedge rstn)
    if (~rstn) bit_counter_ws <= 6'd0;
    else bit_counter_ws <= bit_counter_ws + 6'd1;

always @(posedge clk_in or negedge rstn)
    if (~rstn) begin
       bit_counter   <= 6'd0;
       data          <= 64'd0;
    end else begin
       bit_counter <= bit_counter + 6'd1;
       data        <= data << 1;
       data[0]     <= i2s_sd;

       if (bit_counter == 0) begin
           left_data  <= data[63:32];
           right_data <= data[31:0];
       end
    end

endmodule
