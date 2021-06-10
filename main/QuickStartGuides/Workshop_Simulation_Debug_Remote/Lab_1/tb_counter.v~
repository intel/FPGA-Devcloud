	`timescale 1ns/10ps //Time precision
	
	module testbench();
	
	 //declare inputs as reg and connect to top module
   //declare outputs as wire and connect to top module
	
	//Instantiation of top module 
	top t1( .refclk() , .reset_pll() ,.reset_count(), .check() ,  .Count_up() , .Count_down()  );
	
	initial 
	begin
		//Initialize inputs as 0
		
	/* Set inputs as 1,0 after different time intervals to check the functionality of testbench */
		
		
		#1000 $finish; //$finish to finish simulation or $stop to stop simulation.
	
	end
	
	always #10 clock = ~clock; //50 MHz Clock (20 ns clock period), many ways to write the clock
	
	endmodule