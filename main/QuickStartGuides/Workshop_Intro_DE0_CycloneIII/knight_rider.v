module knight_rider( input wire CLOCK_50, 
	             output wire [9:0] LEDR
                   ); 
 wire slow_clock;
reg [3:0] count; 
reg count_up;

clock_divider u0 (.fast_clock(CLOCK_50),.slow_clock(slow_clock));

always @ (posedge slow_clock) begin 
if (count_up)
  count <= count + 1'b1
else
  count <= count - 1'b1;
end

always @ (posedge slow_clock) begin
if (count == 9)
  count_up <= 1'b0;
else if (count == 0) 
  count_up <= 1'b1;
else 
  count_up <= count_up;
end

assign LEDR[9:0] = (1'b1 << count);

endmodule

module clock_divider( input fast_clock, output slow_clock);
parameter COUNTER_SIZE = 5; 
parameter COUNTER_MAX_COUNT = (2 ** COUNTER_SIZE) - 1;
reg [COUNTER_SIZE-1:0] count;

always @(posedge fast_clock) begin 
  if(count==COUNTER_MAX_COUNT)
     count <= 0; 
  else 
     count<=count + 1'b1;
end

assign slow_clock = count[COUNTER_SIZE-1];

endmodule

