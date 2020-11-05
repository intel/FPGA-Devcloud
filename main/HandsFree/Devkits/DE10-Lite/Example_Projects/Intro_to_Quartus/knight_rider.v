module knight_rider(input  MAX10_CLK1_50, rst,
	            output [9:0] LEDR,
	            input  [31:0] counter_tap,
	            output [7:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
												
// Internal registers and wires
	
wire slow_clock;
reg [3:0] count;
reg count_up;
wire [3:0] decimal_ones;
wire [3:0] decimal_tens;
wire [3:0] decimal_hundreds;
	
// RTL to display BCD format of scanning LED
		
eight_bit_binary_to_decimal i2 (.binary(LEDR[7:0]), .decimal_ones(decimal_ones), .decimal_tens(decimal_tens), .decimal_hundreds(decimal_hundreds));
seven_segment i3 (.led_bcd(decimal_ones), .led_out(HEX0[6:0]));
seven_segment i4 (.led_bcd(decimal_tens), .led_out(HEX1[6:0]));
seven_segment i5 (.led_bcd(decimal_hundreds), .led_out(HEX2[6:0]));

assign HEX3[6:0] = {7'b1000000};
assign HEX4[6:0] = {7'b1000000};
assign HEX5[6:0] = {7'b1000000};
		
assign {HEX5[7], HEX4[7], HEX3[7], HEX2[7], HEX1[7], HEX0[7]} = 6'b111111;

	// RTL to display a scanning LED
		
clock_divider u0 (.fast_clock(MAX10_CLK1_50),.slow_clock(slow_clock), .counter_tap(counter_tap));
	
always @ (posedge slow_clock) begin
if(rst == 1'b0) begin
  if (count_up)
    count <= count + 1'b1;
  else
    count <= count - 1'b1;
  end 
  else count <= 1'b0;
end

always @ (posedge MAX10_CLK1_50) begin
if(rst == 1'b0) begin
  if (count == 7)
    count_up <= 1'b0;
  else if (count == 0)
    count_up <= 1'b1;
  else
    count_up <= count_up;
  end 
  else count_up <= 1'b0;
end

assign LEDR[9:0] = (1'b1 << count);

endmodule

module clock_divider(input fast_clock,
                     output slow_clock,
                     input [31:0] counter_tap);

parameter COUNTER_SIZE = 32;
parameter COUNTER_MAX_COUNT = (2 ** COUNTER_SIZE) - 1;

reg [COUNTER_SIZE-1:0] count;

always @(posedge fast_clock)
begin
if(count==COUNTER_MAX_COUNT)
  count <= 0;
else
  count<=count + 1'b1;
end

assign slow_clock = count[counter_tap];

endmodule

module add3(input [3:0] in, output reg 	[3:0] out);

always @ (in)
  case (in)
    4'b0000: out <= 4'b0000;  // 0 -> 0
    4'b0001: out <= 4'b0001;
    4'b0010: out <= 4'b0010;
    4'b0011: out <= 4'b0011; 
    4'b0100: out <= 4'b0100;  // 4 -> 4
    4'b0101: out <= 4'b1000;  // 5 -> 8
    4'b0110: out <= 4'b1001;  
    4'b0111: out <= 4'b1010;
    4'b1000: out <= 4'b1011;
    4'b1001: out <= 4'b1100;  // 9 -> 12
    default: out <= 4'b0000;
 endcase
endmodule

module eight_bit_binary_to_decimal (input [7:0]	binary,
                                    output [3:0] decimal_ones,
                                    output [3:0] decimal_tens,
                                    output [3:0] decimal_hundreds);

wire [3:0] c1out, c2out, c3out, c4out, c5out, c6out, c7out;

add3 c1 (.in({1'b0,binary[7:5]}), .out(c1out[3:0]));
add3 c2 (.in({c1out[2:0],binary[4]}), .out(c2out[3:0]));
add3 c3 (.in({c2out[2:0],binary[3]}), .out(c3out[3:0]));
add3 c4 (.in({c3out[2:0],binary[2]}), .out(c4out[3:0]));
add3 c5 (.in({c4out[2:0],binary[1]}), .out(c5out[3:0]));
add3 c6 (.in({1'b0,c1out[3],c2out[3],c3out[3]}), .out(c6out[3:0]));
add3 c7 (.in({c6out[2:0],c4out[3]}), .out(c7out[3:0]));

assign decimal_ones = ({c5out[2:0],binary[0]});
assign decimal_tens = ({c7out[2:0],c5out[3]});
assign decimal_hundreds = ({3'b0,c7out[3]});

endmodule

module seven_segment(input [3:0] led_bcd,
                     output reg	[6:0] led_out);

always @ (led_bcd) begin
  case(led_bcd) //Seven segment decoder
    4'b0000: led_out <= 7'b1000000; // "0"     
    4'b0001: led_out <= 7'b1111001; // "1" 
    4'b0010: led_out <= 7'b0100100; // "2" 
    4'b0011: led_out <= 7'b0110000; // "3" 
    4'b0100: led_out <= 7'b0011001; // "4" 
    4'b0101: led_out <= 7'b0010010; // "5" 
    4'b0110: led_out <= 7'b0000010; // "6" 
    4'b0111: led_out <= 7'b1111000; // "7" 
    4'b1000: led_out <= 7'b0000000; // "8"     
    4'b1001: led_out <= 7'b0010000; // "9" 
    default: led_out <= 7'b1000000; // "0"
    endcase
end

endmodule
