##### Figure out path to this script's location
variable setup_location [file normalize [info script]]

##### All paths relative to setup.tcl source directory
##### All paths relative to setup.tcl source directory
set cfg_part "5CSEMA5F31"
set ign_part "SOCVHPS"
set prog_regex "*DE-SoC*"

##### Time (minutes) a user has before 30-second countdown
set session_timeout 20

##### GUI parameters

	##### Board parameters

		##### Board name
		set board_name "DE1-SoC Development Kit"

		##### Board image path
		set board_img_path "$setup_location/../widgets/DE1SoC.png"

	##### Slide switch parameters

		##### Initial switch value
		set SWs 0x000

		##### Path to switch widget image
		set sw_img_path 	"$setup_location/../widgets/SW.png"	

		##### Starting point of switch cluster placement (top left corner of first widget)
		set sw_base_x 		"85"							
		set sw_base_y 		"656"	

		##### Number of switches to create				
		set sw_num_obj		"10"

		##### Allow for individual offset to be added to spacing equation
		##### Note, if on, number of elements must match num_obj above
		set sw_offset_en 	"1"
		set sw_offsets_x 	"-6 -3 -2 0 0 0 0 0 0 0"
		set sw_offsets_y 	"0 0 0 0 0 0 0 0 0 0"

		##### b in a_x/y*i^2 + b_x/y*i + base_x/y spacing equation 				
		set sw_beta_x		"37"							
		set sw_beta_y		"0"

		##### a in a_x/y*i^2 + b_x/y*i + base_x/y spacing equation 	
		set sw_alpha_x		".2"
		set sw_alpha_y		"0"

	##### Push button highlight parameters

		##### Initial push button switch values
		set PBs 0xF

		##### Path to switch widget image
		set pb_img_path 	"$setup_location/../widgets/PB.png"	

		##### Starting point of switch cluster placement (top left corner of first widget)
		set pb_base_x 		"477"							
		set pb_base_y 		"659"	

		##### Number of switches to create				
		set pb_num_obj		"4"

		##### Allow for individual offset to be added to spacing equation
		##### Note, if on, number of elements must match num_obj above
		set pb_offset_en 	"1"
		set pb_offsets_x 	"-3 0 0 0"
		set pb_offsets_y 	"1 0 0 0"

		##### b in a_x/y*i^2 + b_x/y*i + base_x/y spacing equation 				
		set pb_beta_x		"71"							
		set pb_beta_y		"0"

		##### a in a_x/y*i^2 + b_x/y*i + base_x/y spacing equation 	
		set pb_alpha_x		"0"
		set pb_alpha_y		"0"

	##### LED parameters

		##### Initialize LEDs
		set LEDRs 0x000

		##### Path to led widget image
		set led_img_path 	"$setup_location/../widgets/LEDR.png"

		##### Starting point of led cluster placement (top left corner of first widget)
		set led_base_x 		"96"							
		set led_base_y 		"606"	

		##### Number of leds to create				
		set led_num_obj		"10"

		##### Allow for individual offset to be added to spacing equation
		##### Note, if on, number of elements must match num_obj above
		set led_offset_en 	"1"
		set led_offsets_x 	"-4 0 4 4 4 4 4 4 0 0"
		set led_offsets_y 	"0 0 0 0 0 0 0 0 0 0"

		##### b in a_x/y*i^2 + b_x/y*i + base_x/y spacing equation 				
		set led_beta_x		"33"							
		set led_beta_y		"0"

		##### a in a_x/y*i^2 + b_x/y*i + base_x/y spacing equation 	
		set led_alpha_x		".5"
		set led_alpha_y		"0"

	##### HEX parameters

		##### Initialize 7-segment displays
		set HEX  {0xFF 0xFF 0xFF 0xFF 0xFF 0xFF}

		##### Path to 7-segment widget images
		set hexa_img_path 	"$setup_location/../widgets/A.png"
		set hexb_img_path 	"$setup_location/../widgets/B.png"	
		set hexc_img_path 	"$setup_location/../widgets/C.png"	
		set hexd_img_path 	"$setup_location/../widgets/D.png"	
		set hexe_img_path 	"$setup_location/../widgets/E.png"	
		set hexf_img_path 	"$setup_location/../widgets/F.png"	
		set hexg_img_path 	"$setup_location/../widgets/G.png"
		set hexh_img_path 	"$setup_location/../widgets/H.png"

		##### Starting point of led cluster placement (top left corner of first widget)
		set hexa_base_x 		"107"							
		set hexa_base_y 		"555"

		set hexb_base_x 		"122"							
		set hexb_base_y 		"557"

		set hexc_base_x 		"119"							
		set hexc_base_y 		"579"

		set hexd_base_x 		"100"							
		set hexd_base_y 		"592"

		set hexe_base_x 		"98"							
		set hexe_base_y 		"576"

		set hexf_base_x 		"102"							
		set hexf_base_y 		"557"

		set hexg_base_x 		"106"							
		set hexg_base_y 		"573"

		set hexh_base_x 		"126"							
		set hexh_base_y 		"592"

		##### Number of leds to create				
		set hex_num_obj		"6"

		##### Allow for individual offset to be added to spacing equation
		##### Note number of elements must match num_obj above
		set hex_offset_en 	"1"
		set hex_offsets_x 	"-10 0 0 2 0 0"
		set hex_offsets_y 	"0 0 0 0 0 0"

		##### b in a_x/y*i^2 + b_x/y*i + base_x/y spacing equation 				
		set hex_beta_x		"41"							
		set hex_beta_y		"0"

		##### a in a_x/y*i^2 + b_x/y*i + base_x/y spacing equation 	
		set hex_alpha_x		"1"
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

	set input_alt_mem_start 0x60
	