module Counter (
    input clock, 
    input reset, 
    output reg [6:0] Ones_Display,
	 output reg [6:0] Tens_Display
    );
 
    reg [23:0] delay; //Delay variable for the counter values to get displayed on the seven segment (Like clock divider)
    reg [3:0] Ones_Counter = 4'b0;      //counter_ones variable   
    reg [3:0] Tens_Counter = 4'b0;  //counter_tens variable
	
	
    always @(posedge clock)
    begin
	      if(reset == 1'b0) //if reset set variables to 0
			begin
           Ones_Counter <= 0;
		   delay <=0;
		   Tens_Counter <=0;
			end
			
        else
		  begin
		  
		  delay <= delay +1;  //increment delay each cycle
		  if ((delay == 24'b100000000000000000000000) && (Ones_Counter <= 4'b1001) )  
        begin
		  Ones_Counter <= Ones_Counter + 1; //increment ones_counter once delay reached its value &  increment tens_counter 
		  if(Ones_Counter == 4'b1001)
		  begin
		  Tens_Counter<= Tens_Counter +1;
		  end
		  end
		  
		  else if(Ones_Counter > 4'b1001) //Rollover to zero 
		  Ones_Counter <= 4'b0000;
		  
		  else if(Tens_Counter > 4'b1001) //Rollover to zero
		  Tens_Counter <=4'b0000;
		  
		  end
		
		  
        case(Ones_Counter) //Seven Segment decoder
        4'b0000: Ones_Display <= 7'b1000000; // "0"     
        4'b0001: Ones_Display <= 7'b1111001; // "1" 
        4'b0010: Ones_Display <= 7'b0100100; // "2" 
        4'b0011: Ones_Display <= 7'b0110000; // "3" 
        4'b0100: Ones_Display <= 7'b0011001; // "4" 
        4'b0101: Ones_Display <= 7'b0010010; // "5" 
        4'b0110: Ones_Display <= 7'b0000010; // "6" 
        4'b0111: Ones_Display <= 7'b1111000; // "7" 
        4'b1000: Ones_Display <= 7'b0000000; // "8"     
        4'b1001: Ones_Display <= 7'b0010000; // "9" 
        default: Ones_Display <= 7'b1000000; // "0"
        endcase
		  
		  
		  	  
        case(Tens_Counter) //Seven Segment Decoder
        4'b0000: Tens_Display <= 7'b1000000; // "0"     
        4'b0001: Tens_Display <= 7'b1111001; // "1" 
        4'b0010: Tens_Display <= 7'b0100100; // "2" 
        4'b0011: Tens_Display <= 7'b0110000; // "3" 
        4'b0100: Tens_Display <= 7'b0011001; // "4" 
        4'b0101: Tens_Display <= 7'b0010010; // "5" 
        4'b0110: Tens_Display <= 7'b0000010; // "6" 
        4'b0111: Tens_Display <= 7'b1111000; // "7" 
        4'b1000: Tens_Display <= 7'b0000000; // "8"     
        4'b1001: Tens_Display <= 7'b0010000; // "9" 
        default: Tens_Display <= 7'b1000000; // "0"
        endcase
    end 
	 

	 
 endmodule
 