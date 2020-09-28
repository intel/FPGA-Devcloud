
proc attempt_link { cable_words sof_path} {

	##### Get service paths
	if { [catch {set dev_svc_paths [get_service_paths device]} ] != 0 } {
		return "fail 0"
	}

	##### Check that both service and master paths have elements
	if { [llength $dev_svc_paths] == 0 } {
		return "fail 1"
	}

	##### From the user selected cable words get the corresponding master/service
	#####  path & idx from the device connected in the loop above
	if { [llength $cable_words] > 1 } {
		set idx 0
		foreach device_path $dev_svc_paths {
			if { [string match *[lindex $cable_words 1]*[lindex $cable_words 0]*[lindex $cable_words 2]* "$device_path"]} {
				set device_index $idx;
				set device $device_path;
				break;
			} else {
				incr idx;
			}
		}
	} else {
		set idx 0
		foreach device_path $dev_svc_paths {
			if { [string match *[lindex $cable_words 0]* "$device_path"] } {
				set device_index $idx;
				set device $device_path;
				break;
			} else {
				incr idx;
			}
		}
	}

	##### Check if design is identified in .sof
	if { [catch {set design [design_load $sof_path]}] != 0 } {
		return "fail 2"
	}

	##### Link design to device
	if { [catch {design_link $design $device}] != 0 } {
		return "fail 3"
	}

	##### Get master paths
	if { [catch {set master_svc_paths [get_service_paths master]} ] != 0 } {
		return "fail 4"
	}

	##### Check that both service and master paths have elements
	if { [llength $master_svc_paths] == 0 } {
		return "fail 5"
	}

	if { [llength $cable_words] > 1 } {
		set idx 0
		foreach master_path $master_svc_paths {
			if { [string match *[lindex $cable_words 1]*[lindex $cable_words 0]*[lindex $cable_words 2]* "$master_path"]} {
				set master_index $idx;
				break;
			} else {
				incr idx;
			}
		}
	} else {
		set idx 0
		foreach master_path $master_svc_paths {
			if { [string match *[lindex $cable_words 0]* "$master_path"] } {
				set master_index $idx;
				break;
			} else {
				incr idx;
			}
		}
	}

	##### Claim master path first to block pgm on the device
	if { [catch {set master_path [lindex [get_service_paths master] $master_index]} ] != 0 } {
		return "fail 6"
	}

	if { [catch {set master_path_claim [claim_service master $master_path ""]} ] != 0 } {
		return "fail 7"
	}

	return "$master_path_claim"

}

proc update_outputs {mem_map_output_start mem_map_output_num_words master_path cable_words sof_path } {
	

	##### If output map update fails, attempt to re-link, if re-link fails exit
	if { [catch {set output_map [master_read_32 $master_path $mem_map_output_start $mem_map_output_num_words]} ] != 0} {

		##### Attempt several reads before reattempting to connect
		for { set i 0 } { i < 3 } { incr i } {

			if { [catch {set output_map [master_read_32 $master_path $mem_map_output_start $mem_map_output_num_words]} ] == 0} {

				return [list "success" $output_map]

			}

		}

		puts "Attempting to reconnect after failed output update"

		##### Re-attempt link
		if { [catch {set new_master_path [attempt_link $cable_words $sof_path]}] != 0} {
			puts_out "output update error"
			exit

		#### If link worked, try to get the output map agian
		} else {

			##### If output map update still fails, exit System Console
			if { [catch {set output_map [master_read_32 $master_path $mem_map_output_start $mem_map_output_num_words]} ] != 0} {
				
				puts_out "output update error"
				exit

			} else {

				##### if re-link fixed issues, return updated outputs and new master path
				return [list "fail" $output_map $new_master_path]

			}

		}

	##### If no problems were encountered, just return the updated output map
	} else {

		return [list "success" $output_map]

	}
}

proc update_inputs {master_path mem_map_param_start data cable_words sof_path {size 32} } {

	if { [catch {master_write_${size} $master_path $mem_map_param_start $data} ] != 0} {

		##### Attempt several writes before reattempting to connect
		for { set i 0 } { i < 3 } { incr i } {

			if { [catch {master_write_${size} $master_path $mem_map_param_start $data} ] == 0 } {

				return 0

			}

		}

		puts "Attempting to reconnect after failed input update"

		##### Re-attempt link
		if { [catch {set new_master_path [attempt_link $cable_words $sof_path]}] != 0} {
			##### If link failed exit

			puts_out "output update error"
			exit

		#### If link worked, try again
		} else {

			puts $new_master_path

			##### If second output map update fails, exit System Console
			if { [catch {master_write_${size} $master_path $mem_map_param_start $data} ] != 0} {

				puts_out "output update error"
				exit

			} else {

				##### if re-link fixed issues, return new master path
				return $new_master_path

			}
		}

	##### If no problems were encountered, just return 0
	} else {

		return 0

	}
	
}

proc gets_in {  } {

	##### Tries to get a message from standard in,
	##### If msg is blank or gets fails, exit System Console

	if { [catch {set msg [gets stdin]}] != 0} {

		exit

	} elseif {$msg == ""} {

		exit

	} else {

		return $msg

	}
}

proc puts_out { msg } {

	##### If sending a message to main fails,
	##### exit quietly

	if { [catch {puts $msg}] != 0} {

		exit

	}
}