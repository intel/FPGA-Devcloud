
/*
*   Keyboard interface
*   NOTICE: this module only includes basic functionality of PS2 keyboard receiving command and sending data,
*           ps2 clock period is set to 4 times of CLOCK_PERIOD (clock_50)
*
*   NOT IMPLEMENTED: host aborting command, host interrupting data sending, 
                     response to some of the commands fromm host (e.g. set scan code set, set repeat rate, etc.)
*/


module keyboard_interface (clk, reset, key_action, scan_code, ps2_clk, ps2_dat, 
                            lock_controls);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


// Timing info for initiating Host-to-Device communication 
//   when using a 50MHz system clock
parameter   CLOCK_CYCLES_FOR_100US		= 5000;
parameter	NUMBER_OF_BITS_FOR_100US	= 13;

parameter  CMD_LED          = 8'hed;
parameter  CMD_ECHO         = 8'hee;
parameter  CMD_CODE_SET     = 8'hf0; 
parameter  CMD_REPEAT_RATE  = 8'hf3; 
parameter  CMD_ENABLE       = 8'hf4;
parameter  CMD_DISABLE      = 8'hf5;
parameter  CMD_RESEND       = 8'hfe;


parameter  ACK_CODE        = 8'hfa;
parameter  ECHO_CODE       = 8'hee;

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
input clk;
input reset;
inout ps2_clk;
inout ps2_dat;


/*****************************************************************************
 *                            PS2 Port Declarations                             *
 *****************************************************************************/

// From Keyboard
input             key_action;
input        [7:0] scan_code;

// To Keyboard 
output reg   [2:0]  lock_controls;
reg            disable_control;

initial begin
    lock_controls <= 0;
    disable_control <= 1'b0;
end



/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/


// Internal Wires
wire sent_data_en;
wire received_cmd_en;
wire [7:0] command_received;


// Internal Registers
// reg     [NUMBER_OF_BITS_FOR_100US:0] command_wait_counter; // wait 100us

// next data to send
reg     [7:0]   next_to_send;
// command being processed
reg     [7:0]   command_to_process;

reg     [7:0]   keyboard_buffer [0:15];
reg     [4:0]   buffer_length;  


initial begin
    next_to_send <= 8'h0;
    command_to_process <= 8'h0;
    buffer_length <= 0;
end


// State Machine Registers
reg		[2:0]	s_kb_transceiver;
reg		[2:0]	ns_kb_transceiver;



/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/

localparam  KB_STATE_0_IDLE     = 3'h0,
            KB_STATE_1_LOAD_DATA = 3'h1, 
            KB_STATE_2_DATA_OUT = 3'h2,
            KB_STATE_3_CMD_IN   = 3'h3,
            KB_STATE_4_CMD_END  = 3'h4, // handle command
            KB_STATE_5_RESPONSE = 3'h5,
            KB_STATE_6_CLK_LOW = 3'h6;




always @(posedge clk) begin
    if (reset == 1'b1)
        s_kb_transceiver <= KB_STATE_0_IDLE;
    else
        s_kb_transceiver <= ns_kb_transceiver;
end



always @(*) begin
    if(s_kb_transceiver != KB_STATE_1_LOAD_DATA)
        if(key_action) begin
            // i.e. buffer not full
            if(buffer_length[4] == 1'b0) begin
                keyboard_buffer[buffer_length] = scan_code; 
                buffer_length = buffer_length + 1'b1;
            end 
        end
end

integer i;

always @(*)
begin
    ns_kb_transceiver = KB_STATE_0_IDLE;

    case(s_kb_transceiver)
    KB_STATE_0_IDLE:
        begin
            // host brings clk low
            if(ps2_clk == 1'b0)
                ns_kb_transceiver = KB_STATE_6_CLK_LOW;
            
            // key pressed
            else if( (buffer_length > 0) && (disable_control == 1'b0)) begin
                ns_kb_transceiver = KB_STATE_1_LOAD_DATA;
            end
            else
                ns_kb_transceiver = KB_STATE_0_IDLE;
        end

    KB_STATE_1_LOAD_DATA:
        begin
            ns_kb_transceiver = KB_STATE_2_DATA_OUT;
            next_to_send = keyboard_buffer[0];
            buffer_length = buffer_length - 1;

            for (i=0; i < 15; i=i+1) begin
                keyboard_buffer[i] = keyboard_buffer[i+1];
            end
            keyboard_buffer[15] = 8'h0;
        end


    KB_STATE_2_DATA_OUT:
        begin
            if(sent_data_en == 1'b1)
                ns_kb_transceiver = KB_STATE_0_IDLE;
            else
                ns_kb_transceiver = KB_STATE_2_DATA_OUT;
        end

    KB_STATE_3_CMD_IN:
        begin
            if(received_cmd_en == 1'b1) 
                ns_kb_transceiver = KB_STATE_4_CMD_END;
            else
                ns_kb_transceiver = KB_STATE_3_CMD_IN; 
        end
    KB_STATE_4_CMD_END:
        begin
            if(command_to_process == 8'h0) begin
                case(command_received)
                CMD_ECHO:
                    begin
                        next_to_send = ECHO_CODE;
                        command_to_process = 8'h0; // No further command
                        ns_kb_transceiver = KB_STATE_5_RESPONSE;
                    end
                CMD_LED:
                    begin
                        next_to_send = ACK_CODE;
                        command_to_process = command_received;
                        ns_kb_transceiver = KB_STATE_5_RESPONSE; 
                    end
                CMD_ENABLE:
                    begin
                        disable_control = 1'b0;
                        next_to_send = ACK_CODE;
                        command_to_process = 8'h0; // No further command
                        ns_kb_transceiver = KB_STATE_5_RESPONSE;
                    end
                CMD_DISABLE:
                    begin
                        disable_control = 1'b1;
                        next_to_send = ACK_CODE;
                        command_to_process = 8'h0; // No further command
                        ns_kb_transceiver = KB_STATE_5_RESPONSE;
                    end
                default:
                    begin
                        next_to_send = 8'h0;
                        command_to_process = 8'h0;
                        ns_kb_transceiver = KB_STATE_0_IDLE;
                    end
                endcase
            end
            // if it's the second byte of command
            else begin
                ns_kb_transceiver = KB_STATE_0_IDLE;
                
                case(command_to_process)
                CMD_LED:
                    begin
                        lock_controls = command_received[2:0];
                        command_to_process = 8'h0;
                    end
                default:
                    command_to_process = 8'h0;
                endcase
            end
        end
    KB_STATE_5_RESPONSE:
        begin
            if(sent_data_en == 1'b1) begin
                ns_kb_transceiver = KB_STATE_0_IDLE;
            end
            else
                ns_kb_transceiver = KB_STATE_5_RESPONSE;
        end

    KB_STATE_6_CLK_LOW:
        begin
            if(ps2_clk == 1'b0) begin
                // if((command_wait_counter == CLOCK_CYCLES_FOR_100US) && (ps2_dat == 1'b0))
                //     ns_kb_transceiver = KB_STATE_3_CMD_IN;
                // else
                ns_kb_transceiver = KB_STATE_6_CLK_LOW;
            end 
            // Data low, clock high: Host Request-to-Send
            else if (ps2_dat == 1'b0) begin
                ns_kb_transceiver = KB_STATE_3_CMD_IN;
            end
            // Data high, clock high
            else
                ns_kb_transceiver = KB_STATE_0_IDLE; 
        end
    endcase
end

/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

// always @(posedge clk) begin
//     if(reset) begin
//         command_wait_counter <= 0;
//     end

//     else begin
//         if ((s_kb_transceiver == KB_STATE_6_CLK_LOW) && (command_wait_counter != CLOCK_CYCLES_FOR_100US)) begin
//             command_wait_counter <= command_wait_counter + 1'b1;
//         end
//         else if (s_kb_transceiver != KB_STATE_6_CLK_LOW) begin
//             command_wait_counter <= 0;
//         end
//     end
// end



/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

assign start_receiving = (s_kb_transceiver == KB_STATE_3_CMD_IN);
assign start_sending = (s_kb_transceiver == KB_STATE_5_RESPONSE) || (s_kb_transceiver == KB_STATE_2_DATA_OUT);


/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/


PS2_Data_Out Data_Out(
    // input
    .clk(clk),
    .reset(reset),
    .start_sending(start_sending),
    .scan_code(next_to_send),

    // bidirectional
    .ps2_clk(ps2_clk),
    .ps2_dat(ps2_dat),


    // output
    .data_sent(sent_data_en)
);



PS2_Command_In Command_In(
    .clk(clk),
    .reset(reset),
    .start_receiving(start_receiving),

    .ps2_clk(ps2_clk),
    .ps2_dat(ps2_dat),

    .command(command_received),
    .received(received_cmd_en)

);

endmodule


module PS2_Command_In(clk, reset, start_receiving, ps2_clk, ps2_dat, command, received);

input clk;
input reset;
input start_receiving;

inout ps2_clk;
inout ps2_dat;

output reg [7:0] command;
output received;

reg process_cmd;
reg acknowledge; // control ps2_dat to send ack bit
reg [3:0] counter;
reg [2:0] clk_div;


initial
begin : Clock_Div
	clk_div = 3'h7;
end
always @(posedge clk)
begin
    clk_div[2:1] = clk_div[1:0];
    if (process_cmd)
        clk_div[0] = ~clk_div[2];
    else
        clk_div[0] = 1'b1;
end


assign received = (counter == 4'b1100 & clk_div[2] & clk_div[1]); // before (posedge ps2_clk)


always @(*) begin
    if(reset == 1'b1)
        acknowledge = 1'b0;
    else if (counter == 4'b1100 & ps2_clk == 1'b0) 
        acknowledge = 1'b1;
    else
        acknowledge = 1'b0; 
end

always @(posedge clk) begin
    if(reset == 1'b1) begin
        counter <= 4'b0;
        command <= 8'b0;
        process_cmd <= 1'b0;
    end

    else if(~process_cmd & start_receiving) begin
        process_cmd <= 1'b1;
    end
    
    // after (posedge ps2_clk)
    else if(process_cmd & clk_div[2] & ~clk_div[1] & ps2_clk) begin
        if(counter == 0) begin
            counter <= counter + 1'b1;
        end
        // read in command
        else if (counter < 4'b1001) begin
            command[counter-1] <= ps2_dat;
            counter <= counter + 1'b1;
        end
        // parity
        else if(counter == 4'b1001) begin
            // check for parity bit (^command) ^ 1'b1;
            counter <= counter + 1'b1;
        end
        // stop bit
        else if(counter == 4'b1010) begin
            counter <= counter + 1'b1;
        end
        else if(counter == 4'b1011) begin
            // acknowledge
            counter <= counter + 1'b1;
        end
        else if(counter == 4'b1100) begin
            process_cmd <= 1'b0;
            counter <= 0;
        end
    end
end

assign (weak0, weak1) ps2_clk   = 1'b1;
assign (weak0, weak1) ps2_dat   = 1'b1; 


assign ps2_dat = (process_cmd & acknowledge) ? 1'b0 : 1'bz;
assign ps2_clk = (clk_div[2] | (~process_cmd)) ? 1'bz : 1'b0;

endmodule





module PS2_Data_Out(
    clk, reset, start_sending, scan_code, ps2_clk, ps2_dat, data_sent
);

input clk;
input reset;
input start_sending;
input [7:0] scan_code;

inout ps2_clk;
inout ps2_dat;

output data_sent;

reg [2:0]clk_div;
reg [7:0] data;
reg       data_ready;
reg [3:0] counter;
reg       ps2_buf;


always @(posedge clk)
begin
	if (reset) begin
		data <= 0;
        data_ready <= 1'b0;
        counter <= 0;
        ps2_buf <= 1'b1;
    end

    else if(start_sending & ~data_ready) begin
        data_ready <= 1'b1;
        data <= scan_code;
    end
   

    // not reset
	else if (data_ready & ~clk_div[2] & clk_div[1]) begin
	
	    if(counter == 0) begin
            ps2_buf <= 1'b0;
            counter <= counter + 1'b1;
        end
        // data bits
        else if (counter < 4'b1001) begin
            // take the lowest bit
            ps2_buf <= data[0];
            // shift data
            data <= {data[0], data[7:1]};
            counter <= counter + 1'b1;
        end
        else if(counter == 4'b1001) begin
            // parity bit
            ps2_buf <= (^data) ^ 1'b1;
            counter <= counter + 1'b1;
        end
        else if(counter == 4'b1010) begin
            // stop bit
            ps2_buf <= 1'b1;
            counter <= 0;
            data_ready <= 0;
        end
    end
end


assign data_sent = (counter == 4'b1010 & ~clk_div[2] & clk_div[1]); 

assign (weak0, weak1) ps2_clk    = 1'b1;
assign (weak0, weak1) ps2_dat   = 1'b1; 


initial
begin : Clock_Div
	clk_div = 3'h7;
end
always @(posedge clk)
begin
    clk_div[2:1] = clk_div[1:0];
    if (data_ready)
        clk_div[0] = ~clk_div[2];
    else
        clk_div[0] = 1'b1;
end



assign ps2_dat = (ps2_buf | (~data_ready)) ? 1'bz : 1'b0;
assign ps2_clk = (clk_div[2] | (~data_ready)) ? 1'bz : 1'b0;


endmodule

