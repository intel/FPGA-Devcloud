module top(
    // inputs
    CLOCK_50,
    KEY,
    SW,


    // bidirectional
    PS2_CLK,
    PS2_DAT,

    // outputs
    LED,
    HEX0,
    HEX1,
    HEX2,
    HEX3,
    HEX4,
    HEX5,

    VGA_CLK,   						//	VGA Clock
    VGA_HS,							//	VGA H_SYNC
	VGA_VS,							//	VGA V_SYNC
	VGA_BLANK_N,					//	VGA BLANK
	VGA_SYNC_N,						//	VGA SYNC
	VGA_R,   						//	VGA Red[9:0]
	VGA_G,	 						//	VGA Green[9:0]
	VGA_B   						//	VGA Blue[9:0]

);



/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/

// Inputs
input				CLOCK_50;
input		[3:0]	KEY;        
input       [9:0]   SW;


// Bidirectional
inout       PS2_CLK;
inout       PS2_DAT;


// Outputs
output      [9:0]   LED;
output		[6:0]	HEX0;
output		[6:0]	HEX1;
output      [6:0]   HEX2;
output      [6:0]   HEX3;
output      [6:0]   HEX4;
output      [6:0]   HEX5;


output	VGA_CLK;   				//	VGA Clock
output	VGA_HS;					//	VGA H_SYNC
output	VGA_VS;					//	VGA V_SYNC
output	VGA_BLANK_N;			//	VGA BLANK
output	VGA_SYNC_N;				//	VGA SYNC
output	[9:0]	VGA_R;   		//	VGA Red[9:0]
output	[9:0]	VGA_G;	 		//	VGA Green[9:0]
output	[9:0]	VGA_B;   		//	VGA Blue[9:0]




/*****************************************************************************
 *                            Program Modules                                *
 *****************************************************************************/

assign LED = SW;


endmodule