`timescale 1ns/10ps

module tb_counter();

reg clock,reset_pll,reset_count,counter_direction;
wire [3:0] count_up , count_down;


top_counter DUT ( .refclk(clock) ,
						.reset_pll(reset_pll) ,
						.reset_count(reset_count), 
						.counter_direction(counter_direction),  
						.count_up(count_up), 
						.count_down(count_down)  );

	initial 
	begin
		clock = 0;
		reset_pll =1; 
		reset_count=1;
		counter_direction =0; 
		
		#10 reset_pll=0;
		#30 reset_count=0;
		#10 counter_direction=1;
		#30 counter_direction=0;
		#10 counter_direction=1;
		#30 counter_direction=0;
		#10 counter_direction=1;
		#30 counter_direction=0;
		
		
		#1000 $stop;
	
	end
	
	always #10 clock = ~clock;

endmodule
