module clkdiv #(
    parameter DIVISOR = 8  // The divisor of the input clock
)(
    input      clk_in,    // input clock
    output reg clk_out    // output clock after dividing the input clock by divisor
);

reg[7:0] counter = 8'd0;

always @(posedge clk_in)
begin
    counter <= counter + 8'd1;
    if(counter>=(DIVISOR-1))
        counter <= 0;
    clk_out <= (counter<DIVISOR/2)?1'b1:1'b0;
end

endmodule

