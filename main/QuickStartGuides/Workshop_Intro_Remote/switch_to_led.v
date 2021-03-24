module switch_to_led(SW, LEDR); //create module Switch_to_LED
    input   [9:0] SW;           // input declarations: 10 switches 
    output  [9:0] LEDR;         // output declarations: 10 red LEDs 
    assign  LEDR = SW;          // connect switches to LEDs
endmodule
