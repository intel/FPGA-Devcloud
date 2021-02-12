gproc file_search { fn } {
	##### Looks for a file with extension .n in pwd
	##### If not in this directory, looks in pwd/alt_directory

	##### Look for file in pwd, otherwise look in alternate directory
	if { [catch {set file_path [glob $fn]}] != 0} {
		return 0
	}

	##### Generate path to .sof
	return $file_path
}

proc remove_ips { } {

	global gui_server_location
	set credential_fh "${gui_server_location}/../../server_credentials.txt"

	.ip_address configure -values ""

	file delete -force $credential_fh

	return [initial_credentials]

}

proc initial_credentials { } {
##### Get initial credentials from previous session

	global gui_server_location

	set ips {}
	set credential_fh "${gui_server_location}/../../server_credentials.txt"
	set ip_address ""
	set password ""
	set sof_file ""
	set mode "initialize"

	##### Look for server credential file
	set jconfig_file [file_search $credential_fh]

	##### If not found, intialize credentials to empty lists
	if { $jconfig_file == 0 } {
		set ips {}
		set pws {}
		set ip_address "local"
	##### If credential file found parse and extract server credentials
	} else {
		##### Open credential file and get lines
		set login_credentials_fid 		[open $credential_fh "r"]
		set jtag_credentials 			[read $login_credentials_fid]
		set jtag_credentials 			[split $jtag_credentials "\n"]
		close $login_credentials_fid
		##### Line 0 is the IPs
		set ips [lindex $jtag_credentials 0]
		set ip_address "local"

		##### Line 0 is the IPs
		set pws [lindex $jtag_credentials 1]

	}

	return [list $ips $credential_fh $ip_address $password $sof_file $mode $pws]

} 

proc init_top_window { title {background white} {zoom 0} } {
	##### Create a top level tk window
	. configure -background $background;
	##### Optionally, zoom in the window (only works with Windows)
	if { $zoom } {
		if { [catch {wm state . zoomed}] != 0 } {
			#### Do nothing this is to catch full screen fail due to X11
		}
	}
	##### Add title to window
	wm title . $title;
}

proc create_entry {entry_name textvariable} {

	global $textvariable
	pack .${entry_name} -side top -anchor n -padx 10 -pady 10

}

proc link_press { ips credential_fh ip_address password sof_file pws} {

	lappend ips $ip_address
	lappend pws $password

	set ips_saved ""
	set pws_saved ""

	set num_ips [llength $ips]
	set ip_check ""

	for { set i [expr "$num_ips-1"]} { $i >= 0 } { incr i -1 } {

		if { [lsearch $ips_saved [lindex $ips $i]] == -1 && [lindex $ips $i] != "local"  } {
			
			lappend ips_saved [lindex $ips $i]
			lappend pws_saved [lindex $pws $i]

		}

	}

	set login_credentials_fid [open $credential_fh "w"]
	puts $login_credentials_fid $ips_saved
	puts $login_credentials_fid $pws_saved
	close $login_credentials_fid

	puts "connect"
	puts $ip_address
	puts $password
	set  sof_file [file normalize $sof_file]
	puts "${sof_file}"

	return "connecting"

}

proc main_loop { } {

	global mode
	global password
	global password_old
	global pws
	global ips
	global ip_address
	global sof_file
	global ip_address_old

	set main_msg [gets stdin]

	if { $main_msg == "System Console started" } {

		status_message "System Console started."

	} elseif { $main_msg == "System Console failed" } {

		error_message "System Console couldn't start!"
		set mode "wrap_up"

	}

	if { $mode == "initialize" } {

		.link_button configure -state disabled

		if { $ip_address == "local" } {

			.pw_ent configure -state disabled

			if { $sof_file != "" } {

				.link_button configure -state normal

			} else {

				.link_button configure -state disabled

			}

		} else {

			if { $ip_address != $ip_address_old } {

				set ip_idx [lsearch -exact $ips $ip_address]

				if { $ip_idx >= 0} {

					set password [lindex $pws $ip_idx]

				}

			}

			if { $password != $password_old } {

				.pw_ent xview moveto 1.0
				.pw_ent icursor end

			}

			set ip_address_old $ip_address

			.pw_ent configure -state normal

			if { ($sof_file != "") && ($password != "") && ($ip_address != "") } {

				.link_button configure -state normal

			} else {

				.link_button configure -state disabled

			}

		}

	} elseif { $mode == "connecting" } {

		if { $main_msg == "connection started" } {

			.link_button configure -state disabled
			status_message "Connecting to server..."

		} elseif { $main_msg == "connect success" } {

			.link_button configure -state disabled
			status_message "Found device!"
			set mode "programming"

		} elseif { $main_msg == "connect fail" } {

			.link_button configure -state disabled
			error_message "Failed to connect!"
			set mode "initialize"

		} else {

			.link_button configure -state normal

		}

	} elseif { $mode == "programming" } {

		.link_button configure -state disabled

		if { $main_msg == "pgm started" } {

			status_message "Programming device..."
		
		} elseif { $main_msg == "pgm success" } {

			status_message "Programming successful!"
			status_message "System Console starting..."
			set mode "linking"

		} elseif { $main_msg == "pgm fail" } {

			error_message "Failed to program!"
			set mode "initialize"

		}

	} elseif { $mode == "linking" } {

		.link_button configure -state disabled

		if { $main_msg == "link started" } {

			status_message "Linking to design..."

		} elseif { $main_msg == "link success" } {

			status_message "Link successful!"
			status_message "Launching Board GUI..."
			set mode "wrap up"

		} elseif { $main_msg == "link fail" } {

			set mode "initialize"
			error_message "Failed to link!"

		}

	} elseif { $mode == "wrap up" } {

		if { $main_msg == "finish" } {

			exit

		}
	}
}

proc status_message { text } {

	.msg configure -state normal
	.msg configure -foreground blue
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
