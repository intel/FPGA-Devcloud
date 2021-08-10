proc initialize_connect_gui { gui_connect_path } {
##### To properly initialize, you must either be in a directory
##### containing .sofs or be in the child of one that does

	##### Find gui_server script and start connection gui
	set gui_connect_pipe [open |[list wish $gui_connect_path] r+];
	fconfigure $gui_connect_pipe -buffering line -blocking 1;

	return $gui_connect_pipe

}

##### Connect, program, link loop
proc connect_pgm_link  {main_location cons_script_path gui_connect_path} {

	set linked 0

	##### Remove all JTAG server credential
	remove_server_credentials

	##### Initialize JTAG server connect GUI
	set gui_connect_pipe 	[initialize_connect_gui $gui_connect_path]

	while { $linked == 0 } {

		##### Wait for link button press
		if { [pipe_wait $gui_connect_pipe "connect"] == 0 } {

			##### Get server credentials
			set server_credentials [pipe_get $gui_connect_pipe 4 1]

			if { $server_credentials != 1 } {

				##### GUI was opened without error
				set ip_address       	[lindex $server_credentials 0]
				set password_pre_cut 	[lindex $server_credentials 1]
				set sof_path 	        [lindex $server_credentials 2]
				set pgm_device 	        [lindex $server_credentials 3]
				puts $sof_path
				set password_cut [split $password_pre_cut "|"]
				set password [join [lrange $password_cut 0 end-2] "|"]
				set port [lindex $password_cut end]
				set bus [lindex $password_cut end-1]


			} else {

				return 1

			}

		} else {

			return 1

		}

		##### Wait so status change is visible
		after 1000

		if { $ip_address != "local" } {

			##### Connect to JTAG server
			puts_gui $gui_connect_pipe "connection started"
			if { [jtag_server_connect $ip_address $port $password] != 0 } {

				puts_gui $gui_connect_pipe "connect fail"
				puts_sys_cons $sys_cons_pipe "pgm fail"
				remove_server_credentials
				continue

			}

			set devices [get_available_device]
			set device 1

			foreach device_i $devices {

				if { [string match "*on*${ip_address}:${port}*${bus}*" $device_i] } {

					set device $device_i
					regsub -all "\{" $device "" device
					regsub -all "\}" $device "" device
					break

				}

			}

			set cable_words "$ip_address $bus $port"

		} else {

			set device [lindex [get_available_device] 0]
			regsub -all "\{" $device "" device
			regsub -all "\}" $device "" device
			set cable_words [extract_cable_words $device]

		}

		##### Check that devices were connected
		if { $device == 1 } {

			puts_gui $gui_connect_pipe "connect fail"
			remove_server_credentials
			continue

		} else {

			puts_gui $gui_connect_pipe "connect success"
			puts_gui $gui_connect_pipe $device

		}

		if { $pgm_device } {

			##### Program device with .sof
			puts_gui $gui_connect_pipe "pgm started"
			puts_gui $gui_connect_pipe $device

			if { [attempt_device_pgm $device $sof_path] == "success" } {

				##### Tell GUI/Sys Cons device was successfully programmed
				puts_gui $gui_connect_pipe "pgm success"

				##### Initialize System Console
				set sys_cons_pipe [start_system_console $cons_script_path]

				##### Make sure System Console didn't encounter an error
				if { $sys_cons_pipe == 1 } {

					puts_gui $gui_connect_pipe "System Console failed"
					after 5000
					puts_gui $gui_connect_pipe "finish"
					return 1		

				} else {

					##### System Console doesn't support the following, so make sure
					##### This file is in console.tcl directory
					variable console_location [file normalize [info script]]

					##### Get global variables
					puts_sys_cons $sys_cons_pipe "${console_location}/../../setup.tcl"

					##### Get GUI procedures
					puts_sys_cons $sys_cons_pipe "${console_location}/../console_procs.tcl"

					##### Send credentials
					puts_sys_cons $sys_cons_pipe $sof_path
					puts_sys_cons $sys_cons_pipe $cable_words


					if { [gets $sys_cons_pipe] == "recieved params" } {

						puts_gui $gui_connect_pipe "System Console started"

					} else {

						puts_gui $gui_connect_pipe "System Console failed"
						continue

					}
				}

			} else {

				##### Tell GUI device program failed
				puts_gui $gui_connect_pipe "pgm fail"
				remove_server_credentials
				continue

			}

		} else {

			##### Initialize System Console
			set sys_cons_pipe [start_system_console $cons_script_path]

			##### Make sure System Console didn't encounter an error
			if { $sys_cons_pipe == 1 } {

				puts_gui $gui_connect_pipe "System Console failed"
				after 5000
				puts_gui $gui_connect_pipe "finish"
				return 1		

			} else {

				##### System Console doesn't support the following, so make sure
				##### This file is in console.tcl directory
				variable console_location [file normalize [info script]]

				##### Get global variables
				puts_sys_cons $sys_cons_pipe "${console_location}/../../setup.tcl"

				##### Get GUI procedures
				puts_sys_cons $sys_cons_pipe "${console_location}/../console_procs.tcl"

				##### Send credentials
				puts_sys_cons $sys_cons_pipe $sof_path
				puts_sys_cons $sys_cons_pipe $cable_words


				if { [gets $sys_cons_pipe] == "recieved params" } {

					puts_gui $gui_connect_pipe "System Console started"

				} else {

					puts_gui $gui_connect_pipe "System Console failed"
					continue

				}
			}

		}

		puts_gui $gui_connect_pipe "link started"

		##### Wait until System Console confirms link was successful
		set linked [gets $sys_cons_pipe]

		if { $linked == "link success" } {

			puts_gui $gui_connect_pipe "link success"

		} else {

			puts_gui $gui_connect_pipe "link fail"
			puts "$linked"
			continue

		}
	}

	after 2000
	puts_gui $gui_connect_pipe "finish"
	return [list $sys_cons_pipe $device]

}

proc puts_gui { gui_pipe msg } {

	if { [catch {puts $gui_pipe $msg}] != 0 } {

		puts "Login GUI error! Couldn't send message: $msg."
		after 5000
		exit

	}
}

proc puts_sys_cons { sys_cons_pipe msg } {

	if { [catch {puts $sys_cons_pipe $msg}] != 0 } {

		puts "System Console error! Couldn't send message: $msg."
		after 5000
		exit

	}
}

proc start_system_console { cons_script_path } {

	global env

	set sys_cons_command_0  "$env(QUARTUS_ROOTDIR)/sopc_builder/bin/system-console.exe"
	set sys_cons_command_1  $cons_script_path

	#### Start a system console subprocess to attempt programming and GUI communication
	if { [catch {set sys_cons_pipe [ open |[ list ${sys_cons_command_0} [join "--script=$sys_cons_command_1"] ] r+]} ] != 0 } {
		return 1
	}
	fconfigure $sys_cons_pipe -buffering line -blocking 1;

	set error_detect 0
	set sys_cons_msg [gets $sys_cons_pipe]

	while { ( $sys_cons_msg != "initialized" ) && ( $error_detect < 400 ) } { 

		set sys_cons_msg [gets $sys_cons_pipe]
		##### Uncomment to see System Console startup
		# puts "$sys_cons_msg"
		incr error_detect 

	}

	if { $error_detect == 400 } {

		return 1

	}

	return $sys_cons_pipe
	
}


proc pipe_wait { pipe continue_text {empty_okay 0} } {

	if { [catch {set pipe_msg [gets $pipe]} ] != 0 } {

		return 1

	} elseif { ($pipe_msg == "") && ($empty_okay == 0) } {

		return 1

	} elseif { $pipe_msg == "$continue_text" } {
	
		return 0

	}
}

proc pipe_get { pipe n {empty_okay 0} } {

	set return_msgs ""

	for { set i 0 } { $i < $n } { incr i } {

		if { [catch { set pipe_msg [gets $pipe] } ] != 0 } {

			return 1

		} elseif { ($pipe_msg == "") && ($empty_okay == 0) } {

			return 1

		} else {
		
			lappend return_msgs $pipe_msg

		}
	}

	return $return_msgs

}

proc remove_server_credentials { } {

	global env

	for { set i 0 } { $i < 20 } { incr i } {

		set j [expr " $i + 1 "]
		if { [catch "exec $env(QUARTUS_ROOTDIR)/bin64/jtagconfig --remove $j"] != 0 } {
			if { [catch "exec $env(QUARTUS_ROOTDIR)/linux64/jtagconfig --remove $j"] != 0 } { }
		}
	}
}

proc jtag_server_connect {ip_address port jtag_server_pw} {

	global env

	if { [catch {qexec "$env(QUARTUS_ROOTDIR)/bin64/jtagconfig --addserver ${ip_address}:${port} $jtag_server_pw"}] != 0 } {
		if { [catch {qexec "$env(QUARTUS_ROOTDIR)/linux64/jtagconfig --addserver ${ip_address}:${port} $jtag_server_pw"}] != 0 } {
			return 1
		}
	}

	return 0
}

proc get_available_device { } {

	global env

	if { [catch {qexec "$env(QUARTUS_ROOTDIR)/bin64/quartus_pgm -l > $env(TMP)/quartus_pgm_dev_list.txt"} ] != 0 } {
		if { [catch {qexec "$env(QUARTUS_ROOTDIR)/linux64/quartus_pgm -l > $env(TMP)/quartus_pgm_dev_list.txt"}] != 0 } { }
	}

	##### Execute the programmer with a list option
	##### Open up file to place device list
	set fil [open "$env(TMP)/quartus_pgm_dev_list.txt" r]
	set data [read $fil]
	set data [split $data "\n"]
	close $fil
	##### Look for good connection
	set device {}
	foreach line $data {
		if { ( "[string index $line 1]"==")" ) || ( "[string index $line 2]"==")" ) || ( "[string index $line 3]"==")" ) } {
			set line_cut [lindex [split $line ")\_"] 1];
			set line_cut [string trim $line_cut " "];
			if { [string match *Unable* "$line_cut"] == 1 } {
				continue;
			} elseif {( [string match *USB-Blaster* "$line_cut"] == 1 ) || ( [string match *USB-Blaster* "$line_cut"] == 1 )} {
				lappend device $line_cut;
			}
		}
	}
	##### If there was an error connecting device flag it and keep diagnostic file
	if { [llength $device] < 1} {
		return 1
	} else {
		file delete -force "quartus_pgm_dev_list.txt"
	}

	return $device

}

proc attempt_device_pgm {device_choice sof_file} {

	global env
	##### Format the cable_choice for the pgm command
	set cable_command "-c \"${device_choice}\"";

	##### Command to program the device in Windows
	set sys_cmd_pgm_windows "$env(QUARTUS_ROOTDIR)bin64/quartus_pgm.exe $cable_command -m jtag -o \"P;$sof_file\";"

	puts $sys_cmd_pgm_windows

	##### Command to program the device in Linux
	set sys_cmd_pgm_linux "$env(QUARTUS_ROOTDIR)/linux64/quartus_pgm $cable_command -m jtag -o \"p\;\{$sof_file\}\""

	##### Attempt program, if it fails, return
	if { [catch {qexec "$sys_cmd_pgm_windows"}] == 0 } {
		return "success"
	} else {
		if { [catch {qexec "$sys_cmd_pgm_linux"}] ==0 } {
			return "success"
		} else {
			return "fail"
		}
	}

}

proc attempt_device_link {device sof_file } {

	set cable_words [extract_cable_words $device_name]

}

proc extract_cable_words { device_name } {
	##### Using the device name extract the cable name
	if { [string match {* on *} "$device_name"] } {
		set cable_name [lindex [split $device_name "on"] 2];
		regsub "\\\[" $cable_name "" cable_name
		regsub "\\\]" $cable_name "" cable_name
	} else {
		set cable_name [lindex [split $device_name {[}] 1];
		set cable_name [lindex [split $cable_name  {]}] 0];
	}
	##### Break up the cable name into words
	set cable_name [split $cable_name " "]
	set cable_words {}
	foreach word $cable_name {
		if {$word != ""} {
			lappend cable_words $word
		}
	}
	##### Return cable words
	return $cable_words
}

proc launch_board_gui { gui_board_path sys_cons_pipe device} {

	##### Find gui_board script and start board gui
	set gui_board_pipe [open |[list wish $gui_board_path] r+];
	fconfigure $gui_board_pipe -buffering line -blocking 1;

	set error_detect 0

	set gui_board_msg [gets $gui_board_pipe]

	puts $gui_board_pipe $device

	while { ( $gui_board_msg != "initialized" ) && ( $error_detect < 400 ) } { 

		set gui_board_msg [gets $gui_board_pipe]
		##### Uncomment to see System Console startup
		# puts "$gui_board_msg"
		incr error_detect

	}

	if { $error_detect == 400 } {

		return 1

	} else {

		puts $sys_cons_pipe "launched"

	}

	return $gui_board_pipe

} 

proc run_remote_console { gui_board_pipe sys_cons_pipe} {

	set exit_flag 0

	##### Main loop
	while { $exit_flag != 1 } {

		##### Get System Console directive
		set sys_cons_directive [ gets_sys_cons_board $sys_cons_pipe $gui_board_pipe ]
		##### Pass the directive to the GUI
		puts_gui_board $gui_board_pipe $sys_cons_directive $sys_cons_pipe

		##### If System Console is asking for an update to the input map
		if { ( $sys_cons_directive == "parameters" )  || ( $sys_cons_directive == "switch_inputs" ) } {

			##### Get a response from the GUI
			set gui_response [gets_gui_board $gui_board_pipe $sys_cons_pipe]
			##### If an error isn't encountered, tell System Console transaction was successful
			puts_sys_cons_board $sys_cons_pipe "success" $gui_board_pipe
			##### Pass the response to System Console
			puts_sys_cons_board $sys_cons_pipe $gui_response $gui_board_pipe

		##### If System Console has an update to the output map 
		} elseif { $sys_cons_directive == "output_update" } {

			##### Get the updated outputs from System Console
			set updated_outputs [gets_sys_cons_board $sys_cons_pipe $gui_board_pipe]
			##### Pass the updated outputs to the GUI
			puts_gui_board $gui_board_pipe $updated_outputs $sys_cons_pipe  

		} elseif { $sys_cons_directive == "alt_inputs"  } {

			##### Get the updated outputs from System Console
			set alt_inputs [gets_sys_cons_board $sys_cons_pipe $gui_board_pipe]
			##### Pass the updated outputs to the GUI
			puts_gui_board $gui_board_pipe $alt_inputs $sys_cons_pipe

		}

	}
}

proc puts_gui_board { gui_pipe msg sys_cons_pipe } {

	if { [catch {puts $gui_pipe $msg}] != 0 } {

		puts "Board GUI error! Couldn't send message: $msg."
		after 5000
		if { [catch {puts $sys_cons_pipe "gui exit"}] != 0 } {

		}
		exit
	}

}

proc gets_gui_board { gui_pipe sys_cons_pipe } {

	if { [catch {set msg [gets $gui_pipe]}] != 0 } {

		puts "GUI closed."
		after 5000
		if { [catch {puts $sys_cons_pipe "gui exit"}] != 0 } {

		}
		exit
	} elseif { $msg == "" } {

		puts "GUI closed."
		after 5000
		if { [catch {puts $sys_cons_pipe "gui exit"}] != 0 } {

		}
		exit

	}

	return $msg

}


proc puts_sys_cons_board { sys_cons_pipe msg gui_pipe} {

	if { [catch {puts $sys_cons_pipe $msg}] != 0 } {

		puts "Sys Console error! Couldn't send message: $msg."
		after 5000
		if { [catch {puts $gui_pipe "sys cons exit"}] != 0 } {
		}
		exit

	}
}

proc gets_sys_cons_board { sys_cons_pipe gui_pipe } {

	if { [catch {set msg [gets $sys_cons_pipe]}] != 0 } {

		puts "System Console error! Couldn't get msg."
		after 5000
		if { [catch {puts $gui_pipe "sys cons exit"}] != 0 } {
		}
		exit

	}  elseif { $msg == "" } {

		puts "System Console closed! Couldn't get msg."
		after 5000
		if { [catch {puts $gui_pipe "sys cons exit"}] != 0 } {
		}
		exit

	}

	return $msg

}