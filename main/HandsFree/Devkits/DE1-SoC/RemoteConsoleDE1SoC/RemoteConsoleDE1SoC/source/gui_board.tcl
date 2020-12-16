##### Figure out path to this script's location
variable gui_board_location [file normalize [info script]]

##### Flush pipe after any stdout puts command
fconfigure stdout -buffering line

##### Do not block pipe when using gets command
fconfigure stdin -blocking 1

##### Get global variables
source "${gui_board_location}/../../setup.tcl"

##### Get GUI procedures
source "${gui_board_location}/../gui_board_procs.tcl"

##### Make GUI objects

	##### Make main window, title is the board's name
	init_top_window $board_name

	##### Create a canvas w/ a board image canvas will be called board_canvas
	init_board_canvas $board_img_path

	# Default is normal
	##### Create switches and get switch width, switch height, and object locations for click rel binding
	lassign [add_board_canv_obj 	$sw_img_path $sw_base_x $sw_base_y $sw_num_obj "hidden" \
						  			$sw_beta_x $sw_beta_y $sw_alpha_x $sw_alpha_y "SW" "input"\
						  			$sw_offset_en $sw_offsets_x $sw_offsets_y] \
						  			sw_img_width sw_img_height sw_locs_x sw_locs_y

	# Default is hidden
	##### Create pbs and get pw width, pb height, and object locations for click press binding
	lassign [add_board_canv_obj 	$pb_img_path $pb_base_x $pb_base_y $pb_num_obj "hidden" \
						  			$pb_beta_x $pb_beta_y $pb_alpha_x $pb_alpha_y "KEY" "input" \
						  			$pb_offset_en $pb_offsets_x $pb_offsets_y] \
						  			pb_img_width pb_img_height pb_locs_x pb_locs_y

	##### Bind functions to clicks on the board_canvas, check input clicks and update input vectors
	bind .board_canvas <ButtonRelease-1> 	{ lassign [ board_canvas_rel 	$PBs $SWs $sw_img_width \
																			$sw_img_height $sw_locs_x \
																			$sw_locs_y $sw_num_obj $pb_img_width \
																			$pb_img_height $pb_locs_x \
																			$pb_locs_y $pb_num_obj %x %y ] PBs SWs
											  
											  update_input_objects $PBs $pb_num_obj $SWs $sw_num_obj }

	bind .board_canvas <ButtonPress-1> 		{ set PBs [ board_canvas_press 	$PBs $pb_img_width \
																			$pb_img_height $pb_locs_x \
																			$pb_locs_y  $pb_num_obj %x %y ] 
											  
											  update_input_objects $PBs $pb_num_obj $SWs $sw_num_obj }

	##### Create red LEDs
	add_board_canv_obj 	$led_img_path $led_base_x $led_base_y $led_num_obj "hidden"\
						$led_beta_x $led_beta_y $led_alpha_x $led_alpha_y "LEDR" "output" \
						$led_offset_en $led_offsets_x $led_offsets_y

	##### Create HEXas
	add_board_canv_obj 	$hexa_img_path $hexa_base_x $hexa_base_y $hex_num_obj "hidden" \
						$hex_beta_x $hex_beta_y $hex_alpha_x $hex_alpha_y "HEX0" "output" \
						$hex_offset_en $hex_offsets_x $hex_offsets_y

	##### Create HEXbs
	add_board_canv_obj 	$hexb_img_path $hexb_base_x $hexb_base_y $hex_num_obj "hidden" \
						$hex_beta_x $hex_beta_y $hex_alpha_x $hex_alpha_y "HEX1" "output" \
						$hex_offset_en $hex_offsets_x $hex_offsets_y

	##### Create HEXcs
	add_board_canv_obj 	$hexc_img_path $hexc_base_x $hexc_base_y $hex_num_obj "hidden" \
		 				$hex_beta_x $hex_beta_y $hex_alpha_x $hex_alpha_y "HEX2" "output" \
						$hex_offset_en $hex_offsets_x $hex_offsets_y

	##### Create HEXds
	add_board_canv_obj 	$hexd_img_path $hexd_base_x $hexd_base_y $hex_num_obj "hidden" \
						$hex_beta_x $hex_beta_y $hex_alpha_x $hex_alpha_y "HEX3" "output" \
						$hex_offset_en $hex_offsets_x $hex_offsets_y

	##### Create HEXes
	add_board_canv_obj 	$hexe_img_path $hexe_base_x $hexe_base_y $hex_num_obj "hidden" \
						$hex_beta_x $hex_beta_y $hex_alpha_x $hex_alpha_y "HEX4" "output" \
						$hex_offset_en $hex_offsets_x $hex_offsets_y

	##### Create HEXfs
	add_board_canv_obj 	$hexf_img_path $hexf_base_x $hexf_base_y $hex_num_obj "hidden" \
						$hex_beta_x $hex_beta_y $hex_alpha_x $hex_alpha_y "HEX5" "output" \
						$hex_offset_en $hex_offsets_x $hex_offsets_y

	##### Create HEXgs
	add_board_canv_obj 	$hexg_img_path $hexg_base_x $hexg_base_y $hex_num_obj "hidden" \
						$hex_beta_x $hex_beta_y $hex_alpha_x $hex_alpha_y "HEX6" "output" \
						$hex_offset_en $hex_offsets_x $hex_offsets_y

	##### Create HEXhs
	add_board_canv_obj 	$hexh_img_path $hexh_base_x $hexh_base_y $hex_num_obj "hidden" \
						$hex_beta_x $hex_beta_y $hex_alpha_x $hex_alpha_y "HEX7" "output" \
						$hex_offset_en $hex_offsets_x $hex_offsets_y

	##### Use pack geometry manager to organize the canvas
	grid .board_canvas -padx 10 -pady 10 -column 1 -row 1 -columnspan 6

	##### Create n 32-bit parameters
	##### Make global text-variables for entries
	for { set i 0 } { $i < $num_32b_parameters } { incr i } {

		set textin${i} "32-bit Parameter $i"

	}
	for { set i 0 } { $i < $num_32b_parameters } { incr i } {

		set param${i} 0

	}

	create_32b_parameters $num_32b_parameters

	grid [text .msg -background white -height 4 -width 51 -foreground blue -relief ridge \
		-borderwidth 3 -font {Courier -17} -state disabled -wrap word -yscrollcommand {.scroll set} ] \
		-padx 1 -pady 10 -column 3 -row 2 -columnspan 2 -rowspan 2

	grid [scrollbar .scroll -command {.msg yview}] -padx 1 -pady 10 -column 5 -row 2\
		-columnspan 1 -rowspan 2

	grid [button .resetTimeout  -text "Reset Timer"  -height 1 -width 12 -command "set session_started 0"] \
		 -pady 10 -column 3 -row 4 -columnspan 2

##### Periodically run polling function

	puts "initialized"
	status_message "Board launched!\nConnected to [gets stdin]\n\n" 2

##### Do not block pipe when using gets command

	fconfigure stdin -blocking 0

##### Run a function periodically to update board i/o

	##### Spawn the periodic coroutine
	spawn "periodic_function 1"	
