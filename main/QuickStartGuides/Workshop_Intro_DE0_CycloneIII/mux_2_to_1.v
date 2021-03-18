module mux_2_to_1 (SW, LEDR);	//Create module mux_2_to_1
input [9:0]SW; //Input Declarations: 10 slide switches 
output[9:0]LEDR; //Output Declarations: 10 red LED lights
wire S; //Declare the Select signal
wire [2:0] X, Y, M; //Declare the inputs and outputs to the MUX
  assign S = SW[9]; //Assigning input switches to internal signals 
  assign X = SW[2:0]; 
  assign Y = SW[5:3];
  assign LEDR[8:6] = M; //Assigning internal signals to output LEDs 
  assign LEDR[9] = SW[9]; 
  assign LEDR[2:0] = SW[2:0]; 
  assign LEDR[5:3] = SW[5:3];
  assign M = (S == 0) ? X : Y; //MuxSelect Function 
endmodule

