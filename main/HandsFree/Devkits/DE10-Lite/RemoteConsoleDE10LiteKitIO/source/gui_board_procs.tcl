##### Procedures used by GUI

proc init_top_window { title {background white} } {

	##### Create a top level tk window w/ a given title, bg, and zoom
	. configure -background $background;

	##### Add title to window
	wm title . $title;

}


proc init_board_canvas {  	img_path {background white} {border_size 0}
				       		{relief ridge} {highlightthickness 0}	} {

	##### Creates a canvas the size of the board image, and then
	##### pute the image as the bottom most item on the canvas

	##### Create image object and get sizing information
	set board_img [image create photo -file $img_path];
	set x [image width $board_img]
	set y [image height $board_img]

    ##### Makes board canvas on a top-level window of size X x Y
    canvas .board_canvas -bg $background -bd ${border_size} -relief ${relief} \
           -highlightthickness $highlightthickness -width $x -height $y;

    ##### Place the image of the board on the canvas
    .board_canvas create image 0 0 -anchor nw -image ${board_img} -tag "board_canvas"

    return 0

}

proc add_board_canv_obj		{	img_path base_x base_y num_obj state beta_x beta_y 
						  		alpha_x alpha_y obj_type io_dir offset_en {offsets_x ""} {offsets_y ""}	} {

	##### Returns bounding box parameters of the image for click_rel bind usage
	set img 	[image create photo -file $img_path]
	set width 	[image width  $img]
	set height 	[image height $img]

	set locs_x ""
	set locs_y ""

	##### Place the switch widgets and hide them (because switches are init to 0)
	for { set i 0 } { $i < $num_obj } { incr i } {

		set tag [expr "$num_obj-$i-1"]

		if { $offset_en } {

			set loc_x [ expr " ( pow($i, 2) * $alpha_x ) + ( $i * $beta_x ) + $base_x + int([lindex $offsets_x $tag]) " ]
			set loc_y [ expr " ( pow($i, 2) * $alpha_y ) + ( $i * $beta_y ) + $base_y + int([lindex $offsets_y $tag]) " ]
			
		} else {

			set loc_x [ expr " ( pow($i, 2) * $alpha_x ) + ( $i * $beta_x ) + $base_x " ]
			set loc_y [ expr " ( pow($i, 2) * $alpha_y ) + ( $i * $beta_y ) + $base_y " ]

		}

		lappend locs_x $loc_x
		lappend locs_y $loc_y

		.board_canvas create image $loc_x $loc_y -anchor nw -image ${img} -tag "${obj_type}${tag}" -state $state;

	}

	if { $io_dir == "input" } {
 
		return [list $width $height $locs_x $locs_y]


	} else {

		return 0

	}

}

proc board_canvas_rel {		PBs SWs sw_img_width sw_img_height sw_locs_x sw_locs_y 
							sw_num_obj pb_img_width pb_img_height pb_locs_x pb_locs_y 
							pb_num_obj x y } {

		for { set i 0 } { $i < $sw_num_obj } { incr i } {

			set tag [expr "$sw_num_obj - $i - 1"]
			set sw_loc_x0 [lindex $sw_locs_x $i]
			set sw_loc_y0 [lindex $sw_locs_y $i]
			set sw_loc_x1 [expr " $sw_loc_x0 +  $sw_img_width" ] 
			set sw_loc_y1 [expr " $sw_loc_y0 +  $sw_img_height"]

			if { ($x > $sw_loc_x0) &&  ($x < $sw_loc_x1) && ($y > $sw_loc_y0) &&  ($y < $sw_loc_y1) } {

				set SWs [ expr " ( 0x1 << $tag ) ^ $SWs " ]
				return [list $PBs $SWs]

			}

		}

		for { set i 0 } { $i < $pb_num_obj } { incr i } {

			set tag [expr "$pb_num_obj - $i - 1"]
			set pb_loc_x0 [lindex $pb_locs_x $i]
			set pb_loc_y0 [lindex $pb_locs_y $i]
			set pb_loc_x1 [expr " $pb_loc_x0 +  $pb_img_width" ] 
			set pb_loc_y1 [expr " $pb_loc_y0 +  $pb_img_height"]

			if { ($x > $pb_loc_x0) &&  ($x < $pb_loc_x1) && ($y > $pb_loc_y0) &&  ($y < $pb_loc_y1) } {

				set PBs [ expr " ( ( (2**(${pb_num_obj} - 1)) >> $tag ) | $PBs )" ]
				return [list $PBs $SWs]

			}

		}

		return [list $PBs $SWs]

}

proc board_canvas_press {	PBs pb_img_width pb_img_height pb_locs_x pb_locs_y pb_num_obj x y 	} {

	for { set i 0 } { $i < $pb_num_obj } { incr i } {

		set tag [expr "$pb_num_obj - $i - 1"]
		set pb_loc_x0 [lindex $pb_locs_x $i]
		set pb_loc_y0 [lindex $pb_locs_y $i]
		set pb_loc_x1 [expr " $pb_loc_x0 +  $pb_img_width" ] 
		set pb_loc_y1 [expr " $pb_loc_y0 +  $pb_img_height"]

		if { ($x > $pb_loc_x0) &&  ($x < $pb_loc_x1) && ($y > $pb_loc_y0) &&  ($y < $pb_loc_y1) } {

			set PBs [ expr " ( ~ ( (2**(${pb_num_obj} - 1)) >> $tag ) ) & $PBs " ]
			return $PBs

		}

	}

	return $PBs

}

proc show_board_can_item { tag } {

	.board_canvas itemconfigure $tag -state normal

}

proc hide_board_can_item { tag } {

	.board_canvas itemconfigure $tag -state hidden

}

proc update_input_objects { PBs pb_num_obj SWs sw_num_obj } {

	for { set i 0 } { $i < $pb_num_obj } { incr i } {

		if { [expr " $PBs & ( (2**(${pb_num_obj} - 1)) >> $i ) "] } {

			hide_board_can_item "KEY${i}"

		} else {

			show_board_can_item "KEY${i}"

		}

	}

	for { set i 0 } { $i < $sw_num_obj } { incr i } {

		if { [expr " $SWs & (0x1 << $i) "] } {

			hide_board_can_item "SW${i}"

		} else {

			show_board_can_item "SW${i}"

		}

	}

}

proc create_32b_parameters { num_32b_parameters } {

	for { set i 0 } { $i < $num_32b_parameters } { incr i } {

		global param${i}
		global textin${i}
		create_disabled_entry param${i} textin${i} param${i} [expr "$i + 2"]

	}

}

proc create_disabled_entry {	entry_name textvariable paramvariable position	} {

	global ${textvariable}

	entry .${entry_name} -background white -foreground black  -relief ridge -borderwidth 4 \
		-font {Courier -18} -width 20 -textvariable ${textvariable} -justify left -state normal
	grid .${entry_name} -padx 10 -pady 10 -column 1 -row $position -columnspan 2

	##### On click clear parameter, and on Return press, check that entry is valid hex and update parameter value
	bind .${entry_name} <ButtonRelease-1> " set ${textvariable} \"0x\" "
	bind .${entry_name} <Return> " if \{ \[catch \{set ${paramvariable} \[expr \" \$\{${textvariable}\} & 0xFFFFFFFF\" \] \} \] != 0 \} \{
										set ${paramvariable} 0x00000000
										set ${textvariable} 0x00000000
									\}
									set param_update [expr "$position - 1"]
									focus ."

	return 0

}

proc status_message { text {offset 0} {color blue}} {

	.msg configure -state normal
	.msg configure -foreground $color
	.msg delete "end-${offset} lines" end
	.msg insert end "\n$text"
	.msg configure -state disabled
	.msg see end

}

proc error_message { text } {

	.msg configure -state normal
	.msg configure -foreground red
	.msg insert end "\nError: $text"
	.msg configure -state disabled
	.msg see end

}

proc update_outputs { output_update led_num_obj hex_num_obj} {

	##### Update LEDRs
	for { set i 0 } { $i < $led_num_obj } { incr i } {

		if { [expr "(0x1 << $i) & [lindex $output_update 0]"] } {

			show_board_can_item "LEDR${i}"

		} else {

			hide_board_can_item "LEDR${i}"

		}
	}

	for {set i 0} {$i < 6} {incr i} {

		set HEXi [lindex $output_update [expr "$i+1"]];

		if { $HEXi  == "" } {

			set $HEXi  0x00

		}

		for {set j 0} {$j < 8} {incr j} {

			if {[expr "($HEXi) & (0x001 << $j)"] > 0} {

				hide_board_can_item "HEX${j}${i}"

			} else {

				show_board_can_item "HEX${j}${i}"

			}
		} 
	}

}

set session_started 0
set end_time 0
set start_time 0
set ping_measure_start 0
set ping 0
set decision_made_30 0
set decision_made_15 0
set ping_measure_started 0
set ping_timer_start [clock seconds]
set ping_timer_now   [clock seconds]

proc main_loop { } {

	global num_32b_parameters
	global led_num_obj
	global hex_num_obj
	global session_started
	global session_timeout
	global end_time
	global ping_timer_start
	global ping_timer_now
	global ping_measure_start
	global ping_measure_started
	global ping 0
	global decision_made_30 0
	global decision_made_15 0
	global sw_num_obj
	global pb_num_obj
	global GUI_input
	global Board_output

	set ping_timer_now [clock seconds]
	set ping_trigger [expr "($ping_timer_now - $ping_timer_start) > 1"]

	if { $session_started == 1 } {

		set time_seconds [clock seconds]
		set available_time_sec [expr "$end_time - $time_seconds"]

		if { $available_time_sec >= 0 } {

			set available_time_form [clock format $available_time_sec -format %M:%S]

			if { $available_time_sec >= 30 } {

				status_message "Time remaining: $available_time_form\nPing: $ping ms" 2 

			} else {

				status_message "Time remaining: $available_time_form\nPing: $ping ms" 2 red

			}

		} else {

			exit

		}
	} 

	set main_msg [gets stdin]

	if {$main_msg == "parameters"} {

		if { $ping_measure_started == 1 } {

			set ping [expr "[clock milliseconds]-$ping_measure_start"]
			set ping_measure_started 0

		}

		if { $ping_trigger == 1 } {

			set ping_measure_start [clock milliseconds]
			set ping_timer_start [clock seconds]
			set ping_measure_started 1

		}

		if { $session_started == 0 } {

			set session_started 1
			set start_time [clock seconds]
			set end_time [expr "$start_time + int(($session_timeout * 60) + 30)"]

		}

		set param_payload ""
		for { set i 0 } { $i < $num_32b_parameters } { incr i } {

			global "param${i}"
			lappend param_payload [expr "\$param${i}"]

		}
		puts $param_payload

	} elseif { $main_msg == "switch_inputs" } {

		global SWs
		global PBs

		set Board_output_temp [expr "$Board_output != 0"]
		set GUI_input_temp [expr "$GUI_input != 0"]

		set sw_input_payload [expr "( ${Board_output_temp} << ( ${sw_num_obj} + ${pb_num_obj} + 1 ) ) | ( ${GUI_input_temp} << ( ${sw_num_obj} + ${pb_num_obj} ) ) | ( ${PBs} << ${sw_num_obj} ) | ${SWs} "]
		puts $sw_input_payload

	} elseif { $main_msg == "alt_inputs" } {

		global SWs
		global PBs

		set alt_inputs ""
		while { $alt_inputs == "" } {
			set alt_inputs [gets stdin]
		}

		set alt_inputs [expr " ${alt_inputs} << ( 32 - $sw_num_obj - $pb_num_obj )"]
		set alt_inputs [expr " ${alt_inputs} >> ( 32 - $sw_num_obj - $pb_num_obj )"]
		set SWs [expr " ${alt_inputs} << ( 32 - $sw_num_obj )"]
		set SWs [expr " $SWs >> ( 32 - $sw_num_obj )"]
		set PBs [expr " ${alt_inputs} >> ( $sw_num_obj )"]

		update_input_objects $PBs $pb_num_obj $SWs $sw_num_obj

	} elseif { $main_msg == "output_update" } {

		set output_update ""
		while { $output_update == "" } {
			set output_update [gets stdin]
		}
		update_outputs $output_update $led_num_obj $hex_num_obj

	} elseif { $main_msg == "sys cons exit" } {

		error_message "System Console unexpectedly exited!"

	}

}

##### Below are a set of functions which create a periodic coroutine
proc spawn cmd {
	set k [gensym];
	coroutine $k {*}$cmd;
}
proc gensym {{prefix "::coroutine"}} {
	variable gensymid;
	return $prefix[incr gensymid];
}
proc co_after ms {
	after $ms [info coroutine];
	yield;
}
proc periodic_function {ms} {
	set count 0;
	while 1 {
		main_loop;
		co_after $ms;
	}
}