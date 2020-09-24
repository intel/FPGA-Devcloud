##### Figure out path to this script's location
variable setup_location [file normalize [info script]]

##### All paths relative to setup.tcl source directory

##### Time (minutes) a user has before 30-second countdown
set session_timeout 20

##### GUI parameters

	##### Board parameters

		##### Board name
		set board_name "DE10-Lite Development Kit"

		##### Board image path
		set board_img_path "$setup_location/../widgets/DE10Lite.png"

	##### Slide switch parameters

		##### Initial switch value
		set SWs 0x000

		##### Path to switch widget image
		set sw_img_path 	"$setup_location/../widgets/SWs.png"	

		##### Starting point of switch cluster placement (top left corner of first widget)
		set sw_base_x 		"413"							
		set sw_base_y 		"565"	

		##### Number of switches to create				
		set sw_num_obj		"10"

		##### Allow for individual offset to be added to spacing equation
		##### Note, if on, number of elements must match num_obj above
		set sw_offset_en 	"0"
		set sw_offsets_x 	""
		set sw_offsets_y 	""

		##### b in a_x/y*i^2 + b_x/y*i + base_x/y spacing equation 				
		set sw_beta_x		"34"							
		set sw_beta_y		"0"

		##### a in a_x/y*i^2 + b_x/y*i + base_x/y spacing equation 	
		set sw_alpha_x		"0"
		set sw_alpha_y		"0"

	##### Push button highlight parameters

		##### Initial push button switch values
		set PBs 0x3

		##### Path to switch widget image
		set pb_img_path 	"$setup_location/../widgets/circle.png"	

		##### Starting point of switch cluster placement (top left corner of first widget)
		set pb_base_x 		"710"							
		set pb_base_y 		"422"	

		##### Number of switches to create				
		set pb_num_obj		"2"

		##### Allow for individual offset to be added to spacing equation
		##### Note, if on, number of elements must match num_obj above
		set pb_offset_en 	"0"
		set pb_offsets_x 	""
		set pb_offsets_y 	""

		##### b in a_x/y*i^2 + b_x/y*i + base_x/y spacing equation 				
		set pb_beta_x		"0"							
		set pb_beta_y		"54"

		##### a in a_x/y*i^2 + b_x/y*i + base_x/y spacing equation 	
		set pb_alpha_x		"0"
		set pb_alpha_y		"0"

	##### LED parameters

		##### Initialize LEDs
		set LEDRs 0x000

		##### Path to led widget image
		set led_img_path 	"$setup_location/../widgets/led.png"	

		##### Starting point of led cluster placement (top left corner of first widget)
		set led_base_x 		"419"							
		set led_base_y 		"535"	

		##### Number of leds to create				
		set led_num_obj		"10"

		##### Allow for individual offset to be added to spacing equation
		##### Note, if on, number of elements must match num_obj above
		set led_offset_en 	"0"
		set led_offsets_x 	""
		set led_offsets_y 	""

		##### b in a_x/y*i^2 + b_x/y*i + base_x/y spacing equation 				
		set led_beta_x		"34"							
		set led_beta_y		"0"

		##### a in a_x/y*i^2 + b_x/y*i + base_x/y spacing equation 	
		set led_alpha_x		"0"
		set led_alpha_y		"0"

	##### HEX parameters

		##### Initialize 7-segment displays
		set HEX  {0xFF 0xFF 0xFF 0xFF 0xFF 0xFF}

		##### Path to 7-segment widget images
		set hexa_img_path 	"$setup_location/../widgets/a.png"
		set hexb_img_path 	"$setup_location/../widgets/b.png"	
		set hexc_img_path 	"$setup_location/../widgets/c.png"	
		set hexd_img_path 	"$setup_location/../widgets/d.png"	
		set hexe_img_path 	"$setup_location/../widgets/e.png"	
		set hexf_img_path 	"$setup_location/../widgets/f.png"	
		set hexg_img_path 	"$setup_location/../widgets/g.png"
		set hexh_img_path 	"$setup_location/../widgets/h.png"

		##### Starting point of led cluster placement (top left corner of first widget)
		set hexa_base_x 		"89"							
		set hexa_base_y 		"557"
		set hexb_base_x 		"109"							
		set hexb_base_y 		"560"
		set hexc_base_x 		"104"							
		set hexc_base_y 		"588"
		set hexd_base_x 		"81"							
		set hexd_base_y 		"608"
		set hexe_base_x 		"78"							
		set hexe_base_y 		"586"
		set hexf_base_x 		"84"							
		set hexf_base_y 		"560"
		set hexg_base_x 		"87"							
		set hexg_base_y 		"582"
		set hexh_base_x 		"114"							
		set hexh_base_y 		"607"

		##### Number of leds to create				
		set hex_num_obj		"6"

		##### Allow for individual offset to be added to spacing equation
		##### Note number of elements must match num_obj above
		set hex_offset_en 	"1"
		set hex_offsets_x 	"3 3 1 1 0 0"
		set hex_offsets_y 	"0 0 0 0 0 0"

		##### b in a_x/y*i^2 + b_x/y*i + base_x/y spacing equation 				
		set hex_beta_x		"56"							
		set hex_beta_y		"0"

		##### a in a_x/y*i^2 + b_x/y*i + base_x/y spacing equation 	
		set hex_alpha_x		"0"
		set hex_alpha_y		"0"

	###### Set number of 32-bit parameters to allow

		set num_32b_parameters 3

##### Other System Console parameters

	##### switch System Console map start
	set mem_map_SW_start 0x0000

	##### switch System Console number of 32-bit words
	set mem_map_SW_num_words 1 

	##### Base address of the output PIO memory map
	set mem_map_output_start 0x0010

	##### Number of 32-bit words in the output memory map
	set mem_map_output_num_words 8

	##### 32-bit (1-word) param base addresses
	set mem_map_param_1_start 0x30
	set mem_map_param_2_start 0x40
	set mem_map_param_3_start 0x50
