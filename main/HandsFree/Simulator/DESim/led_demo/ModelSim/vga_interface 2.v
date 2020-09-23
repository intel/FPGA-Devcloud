
module vga_interface( 
    clk, reset, vga_clk, hsync, vsync, blank, red, green, blue
);


/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/* Number of pixels */
parameter H_ACTIVE 						= 640;
parameter H_FRONT_PORCH					=  16;
parameter H_SYNC						=  96;
parameter H_BACK_PORCH 					=  48;
parameter H_TOTAL 						= 800;

/* Number of lines */
parameter V_ACTIVE 						= 480;
parameter V_FRONT_PORCH					=  10;
parameter V_SYNC						=   2;
parameter V_BACK_PORCH 					=  33;
parameter V_TOTAL						= 525;


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input clk;
input reset;
input vga_clk;
input hsync;
input vsync;
input blank;

input [9:0] red;
input [9:0] green;
input [9:0] blue;


/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
wire [18:0] address;
wire [3:0] data;


integer fd, status;

initial begin
    fd = $fopen("demo.txt", "r+");
end


/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/
localparam	STATE_0_SYNC	= 2'b00,
            STATE_1_PORCH   = 2'b01,
            STATE_2_DISPLAY = 2'b10;


reg     [1:0]nh_mode;
reg		[1:0]h_mode;
reg     [1:0]nv_mode;
reg     [1:0]v_mode;

reg     [5:0]h_back_count;
reg     [5:0]v_back_count;



always @(posedge clk)	// sync reset
begin
	if (reset) begin
		v_mode <= STATE_0_SYNC;
        h_mode <= STATE_0_SYNC;
    end
	else begin
		v_mode <= nv_mode;
        h_mode <= nh_mode;
    end
end


// horizontal signal
always @(*)
begin
    nh_mode = STATE_0_SYNC;

    case(h_mode)
        STATE_0_SYNC:
        begin
            // h sync end
            if(hsync == 1'b1)
                nh_mode = STATE_1_PORCH;
            else
                nh_mode = STATE_0_SYNC;
        end
        STATE_1_PORCH:
        begin
            // count back porch
            if (h_back_count == H_BACK_PORCH)
                nh_mode = STATE_2_DISPLAY;
            else
                nh_mode = STATE_1_PORCH;
        end
        STATE_2_DISPLAY:
        begin
            // h sync start
            if(hsync == 1'b0)
                nh_mode = STATE_0_SYNC;
            else
                nh_mode = STATE_2_DISPLAY;
            
        end 
        default:
            nh_mode = STATE_0_SYNC;  
    endcase
end


// vertical signal
always @(*)
begin
    nv_mode = STATE_0_SYNC;

    case(v_mode)
        STATE_0_SYNC:
        begin
            // v sync end
            if(vsync == 1'b1)
                nv_mode = STATE_1_PORCH;
            else
                nv_mode = STATE_0_SYNC;
        end
        STATE_1_PORCH:
        begin
            // count back porch
            if (v_back_count == V_BACK_PORCH)
                nv_mode = STATE_2_DISPLAY;
            else
                nv_mode = STATE_1_PORCH;
        end
        STATE_2_DISPLAY:
        begin
            // v sync start
            if(vsync == 1'b0)
                nv_mode = STATE_0_SYNC;
            else
                nv_mode = STATE_2_DISPLAY;
            
        end
        default:
            nh_mode = STATE_0_SYNC;
       
    endcase   
end
/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

reg [9:0] pixel_count; // 640
reg [9:0] line_count;  // 480


always @(posedge vga_clk) begin
    if(reset) begin
        pixel_count <= 0;
        line_count <= 0;
        h_back_count <= 0;
        v_back_count <= 0;
    end

    else begin
        /* write pixel */
        if(pixel_count < H_ACTIVE && line_count < V_ACTIVE) begin
            status = $fseek(fd, address, 0);
            $fwrite(fd, "%01h", data);
            status = $rewind(fd);
        end
        case(h_mode)
            STATE_0_SYNC:
            begin
                h_back_count <= 0;
                pixel_count <= 0;
                if(v_mode == STATE_2_DISPLAY && pixel_count == H_ACTIVE + H_FRONT_PORCH) begin
                    line_count <= line_count + 1;
                end
                else if (v_mode == STATE_1_PORCH && pixel_count == H_ACTIVE + H_FRONT_PORCH) begin
                    v_back_count <= v_back_count + 1;
                end
            end
            STATE_1_PORCH:
            begin
                h_back_count <= h_back_count + 1'b1;
            end
            STATE_2_DISPLAY:
            begin
                pixel_count <= pixel_count + 1'b1;
            end
            default:
            begin
                h_back_count <= 0;
                pixel_count <= 0;
            end
        endcase


        if(v_mode == STATE_0_SYNC) begin
            v_back_count <= 0;
            line_count <= 0;
        end
    end
end


assign data = (blank == 1'b1) ? ({1'b0, red[0], 2'd0} + {1'b0, green[0], 1'd0} + {1'b0, blue[0]}) : 0;


address_translator user_input_translator(
    .x(pixel_count), .y(line_count), .mem_address(address) );

endmodule





module address_translator(x, y, mem_address);

	input [9:0] x; 
	input [9:0] y;	
	output reg [18:0] mem_address;
	
    // (y * 512) + (y * 128) + x
	wire [19:0] res_640x480 = ({1'b0, y, 9'd0} + {1'b0, y, 7'd0}  + {1'b0, x});
    
	
	always @(*)
	begin
		mem_address = res_640x480[18:0];
	end
endmodule