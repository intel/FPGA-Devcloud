module PS2_Comm(
    // inputs
    CLOCK_50,
    KEY,
    SW,

    // bidrectionals
    PS2_CLK,
    PS2_DAT,

    // outputs
    HEX0,
    HEX1

);


/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/

// Inputs
input				CLOCK_50;
input		[1:0]	KEY;        // KEY[0] reset, KEY[1] send command
input       [9:0]   SW;

// Bidirectionals
inout				PS2_CLK;
inout				PS2_DAT;


// Outputs
output		[6:0]	HEX0;
output		[6:0]	HEX1;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

// Internal Wires
wire		[7:0]	ps2_key_data;
wire				ps2_key_pressed;
wire                send_command;
wire                command_was_sent;
wire                error_communication;

// Internal Registers
reg			[7:0]	last_data_received;
reg         [7:0]   the_command;
// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

/*
*  receiving data
*/
always @(posedge CLOCK_50)
begin
	if (KEY[0] == 1'b0)
		last_data_received <= 8'h00;
	else if (ps2_key_pressed == 1'b1)
		last_data_received <= ps2_key_data;
end

/*
*  sending data
*/
always @(posedge CLOCK_50)
begin
    if(KEY[0] == 1'b0) begin
        the_command <= 0;
    end
    else begin
        the_command <= SW[7:0];
        
    end

end

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/
assign send_command = ~KEY[1];

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

PS2_Controller PS2 (
	// Inputs
	.CLOCK_50			(CLOCK_50),
	.reset				(~KEY[0]),
    .the_command        (the_command),
    .send_command       (send_command),

	// Bidirectionals
	.PS2_CLK			(PS2_CLK),
 	.PS2_DAT			(PS2_DAT),

	// Outputs
    .command_was_sent   (command_was_sent),
    .error_communication_timed_out (error_communication),
	.received_data		(ps2_key_data),
	.received_data_en	(ps2_key_pressed)
);


Hexadecimal_To_Seven_Segment Segment0 (
	// Inputs
	.hex_number			(last_data_received[3:0]),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX0)
);

Hexadecimal_To_Seven_Segment Segment1 (
	// Inputs
	.hex_number			(last_data_received[7:4]),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX1)
);




endmodule