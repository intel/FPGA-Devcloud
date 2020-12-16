##### Number of times System Console will unsuccessfully attempt to Link
set max_attempts 3

##### The amount of time system Console delays between refresh and reattempt
##### scaled each reattempt (i.e. reattempt 3 will wait 3*delay after refresh)
set delay_seconds 5

##### Flush pipe after any stdout puts command
fconfigure stdout -buffering line

##### Do not block pipe when using gets command
fconfigure stdin -blocking 1

##### Tell main, System Console is initialized
puts "initialized"

##### Get global variables
source [gets stdin]

##### Get GUI procedures
source [gets stdin]

##### Get the sof path
set sof_path [gets_in]

##### Link will return "fail ref_number" or {master_path, idx}
set cable_words [gets_in]

puts "recieved params"

for { set i 0 } { $i < $max_attempts } { incr i } {

	set master_path [attempt_link $cable_words $sof_path]

	if { [lindex $master_path 0] != "fail" } {

		##### Tell main link was succesful
		puts "link success"
		##### Send main the master path
		puts $master_path
		##### Break out of link loop
		break

	} elseif { $i == [eval "$max_attempts - 1"] } {

		puts "link failed"
		##### Tell main link failed
		puts $master_path
		##### Exit System Console
		exit

	} else {

		refresh_connections
		after [expr "$i * $delay_seconds * 1000"]

	}
}

##### After successful board GUI launch, begin packet transactions
set board_GUI_status [gets_in]
if { $board_GUI_status != "launched" } {

	##### There was an error launching the board GUI
	exit

}

##### Initialize params to all 1s

set params ""
for { set i 0 } { $i <  $num_32b_parameters } { incr i } {

	lappend params 0xFFFFFFFF

}

##### Initialize switches to all 1s
set sw_values 0xFFF

set transmission_active 1
while { $transmission_active } {

	##### Begin transmission loop by updating the output memory map vector
	set output_update_response [update_outputs $mem_map_output_start $mem_map_output_num_words $master_path $cable_words $sof_path]

	##### If outputs were updated without error response will say success in first entry
	if { [lindex $output_update_response 0]  == "success" } {

		set output_map [lindex $output_update_response 1]

	##### Otherwise response will have 2 elements
	} else {

		set output_map [lindex $output_update_response 1] 
		set master_path [lindex  $output_update_response 2]

	}

	##### Request a parameter update
	puts "parameters"
	set status [gets_in]
	if {$status != "success"} {
		puts "Didn't get success params"
		exit
	}
	set new_params [gets stdin]

	##### For every parameter
	for { set i 0 } { $i <  $num_32b_parameters } { incr i } {

		##### If there is a change in it's value
		if { [lindex $new_params $i] != [lindex $params $i] } {

			set mem_map_param_start [expr "\$mem_map_param_[expr "${i}+1"]_start"]
			set input_update_response [update_inputs $master_path $mem_map_param_start [lindex $new_params $i] $cable_words $sof_path]
			puts $input_update_response
			if {$input_update_response} {
				set master_path $input_update_response
			}

		}
	}

	set params $new_params

	##### Request a parameter update
	puts "switch_inputs"
	set status [gets_in]
	if {$status != "success"} {
		puts "Didn't successfully retrieve sw inputs"
		exit
	}

	set new_sw_values [gets_in]
	if { "$new_sw_values" != "$sw_values" } {

		set input_update_response [update_inputs $master_path $mem_map_SW_start $new_sw_values $cable_words $sof_path 32]
		if {$input_update_response} {
			set master_path $input_update_response
		}

	}

	if { ( ${new_sw_values} & [expr "(1 << ( ${sw_num_obj} + ${pb_num_obj} ) )"]) == 0 } {

		puts "alt_inputs"
		puts [master_read_32 $master_path $input_alt_mem_start 1]

	}

	set sw_values $new_sw_values

	##### Send updated output (Will lag behind input 1 transmission)
	set output_payload ""

	##### Extract updated LED values from output map read above
	set LED_R       [lindex $output_map 0]
	puts $LED_R
	set LED_R     	[expr "$LED_R & 0x03FF"]
	lappend output_payload $LED_R

	##### Extract 6 7-segment display values from output map read above
	set SEG70    	[lindex $output_map 0]
	set SEG70		[expr " ($SEG70 & 0x00FF0000) >> 16 "]
	lappend output_payload $SEG70

	set SEG71    	[lindex $output_map 0]
	set SEG71		[expr " ($SEG71 & 0xFF000000) >> 24 "]
	lappend output_payload $SEG71

	set SEG72    	[lindex $output_map 4];
	set SEG72		[expr " ($SEG72 & 0x000000FF)"]
	lappend output_payload $SEG72

	set SEG73    	[lindex $output_map 4]
	set SEG73		[expr " ($SEG73 & 0x0000FF00) >> 8 "]
	lappend output_payload $SEG73

	set SEG74    	[lindex $output_map 4]
	set SEG74		[expr " ($SEG74 & 0x00FF0000) >> 16"]
	lappend output_payload $SEG74

	set SEG75    	[lindex $output_map 4]
	set SEG75		[expr " ($SEG75 & 0xFF000000) >> 24 "]
	lappend output_payload $SEG75

	##### Send output payload to main
	puts "output_update"
	##### Output payload is in the form idx0:LEDR, idx1:HEX0, idx2:HEX3...
	puts $output_payload

}