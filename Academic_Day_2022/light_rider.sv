//
// This SystemVerilog version of the Light Rider code
// displays a scanning LED wave pattern.
// 
// In addition to the Light Rider lab code
// the design receives the buttons (KEY) and when you click on each
// button, it will show the corresponding button number
// in the corresponding 7-segment display (HEX3-HEX0).
// Using a touchscreen you can press multiple keys at once.
// SW[9] shows SW[6:0] positions on HEX5 for prototyping characters.
//
module light_rider(CLOCK_50, SW, KEY, LEDR, HEX5, HEX3, HEX2, HEX1, HEX0);
  input  logic CLOCK_50;
  input  logic [9:0] SW;
  input  logic [3:0] KEY;
  output logic [9:0] LEDR;
  output logic [6:0] HEX5, HEX3, HEX2, HEX1, HEX0;

  logic slow_clock;
  logic [3:0] count; 
  logic count_up;

  // Instantiates the clock_divider to slow the blink rate of the LEDs
  clock_divider u0 (.fast_clock(CLOCK_50), .slow_clock(slow_clock));

  // Controls the direction of the light pattern
  always_ff @(posedge slow_clock) begin 
    if (count_up)
      count <= count + 1'b1
    else
      count <= count - 1'b1;
  end

  // Controls the cutoffs of the light pattern
  always_ff @(posedge slow_clock) begin
    if (count == 9)
      count_up <= 1'b0;
    else if (count == 0) 
      count_up <= 1'b1;
    else 
      count_up <= count_up;
  end

  assign LEDR[9:0] = (1'b1 << count);
  
  assign HEX5 = SW[9] ? SW[6:0] : 7'B1111111;

  // Receives key presses and displays the pattern on the display
  //
  //     7-segment display layout
  //
  //      --0--
  //      5   1
  //      --6--
  //      4   2
  //      --3--
  //
  always_comb begin
                     // 6543210 - 0 is on, 1 is off
    HEX0 = ~KEY[0] ? 7'B1000000 : 7'B1111111; // 0
    HEX1 = ~KEY[1] ? 7'B1111001 : 7'B1111111; // 1
    HEX2 = ~KEY[2] ? 7'B0100100 : 7'B1111111; // 2
    HEX3 = ~KEY[3] ? 7'B0110000 : 7'B1111111; // 3
  end
endmodule

// The clock_divider module receives the fast_clock as an input
// and outputs a slow_clock which is modified by
// the parameter COUNTER_SIZE.
module clock_divider(input fast_clock, output slow_clock);
  parameter COUNTER_SIZE = 5; 
  parameter COUNTER_MAX_COUNT = (2 ** COUNTER_SIZE) - 1;
  logic [COUNTER_SIZE-1:0] count;

  // Resets the clock when the COUNTER_MAX_COUNT has been reached
  always_ff @(posedge fast_clock) begin 
    if (count == COUNTER_MAX_COUNT)
      count <= 0; 
    else 
      count <= count + 1'b1;
  end

  assign slow_clock = count[COUNTER_SIZE-1];
endmodule
