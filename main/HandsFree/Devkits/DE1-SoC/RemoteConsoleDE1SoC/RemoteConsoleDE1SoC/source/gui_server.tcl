##### Figure out path to this script's location
variable gui_server_location [file normalize [info script]]

##### Flush pipe after any stdout puts command
fconfigure stdout -buffering line

##### Do not block pipe when using gets command
fconfigure stdin -blocking 0

##### Get global variables
source "${gui_server_location}/../../setup.tcl"

##### Get GUI procedures
source "${gui_server_location}/../gui_server_procs.tcl"

##### Initialize the board connect window
init_top_window "Board Connect"

##### Initialize the board connect parameters
lassign [initial_credentials] ips credential_fh ip_address password sof_file mode pws cdf_file

set password_old $password
set ip_address_old $ip_address

##### Add widgets and place into a widget grid
grid [label .ip_lab  -text "IPv4" -background white -font {Courier -17} ] -padx 10 -pady 6 -column 1 -row 1 -columnspan 1 -sticky "snew"
grid [ ttk::combobox .ip_address -textvariable ip_address -values $ips -background white \
	-font {Courier -17 } -foreground black -justify left -state normal -width 15] -padx 10 -pady 6 -column 2 -row 1 -columnspan 3 -sticky "snew"
grid [label .pw_lab  -text "Password" -background white -font {Courier -17} -justify right] -padx 10 -pady 6 -column 1 -row 2 -columnspan 1 -sticky "snew"
grid [entry .pw_ent -background white -foreground black  -relief ridge -width 17 \
	-font {Courier -17} -textvariable password -justify left -state normal -state normal ] -padx 10 -pady 6 -column 2 -row 2 -columnspan 3 -sticky "snew"
grid [label .sof_lab  -text "SOF File" -background white -font {Courier -17} ] -padx 10 -pady 6 -column 1 -row 3 -columnspan 1 -sticky "snew"
grid [entry .sof_ent -background white -foreground black  -relief ridge -width 17 \
	-font {Courier -17} -textvariable sof_file -justify left -state disabled ] -padx 10 -pady 6 -column 2 -row 3 -columnspan 3 -sticky "snew"
grid [label .cdf_lab  -text "CDF File" -background white -font {Courier -17} ] -padx 10 -pady 6 -column 1 -row 4 -columnspan 1 -sticky "snew"
grid [entry .cdf_ent -background white -foreground black  -relief ridge -width 17 \
	-font {Courier -17} -textvariable cdf_file -justify left -state disabled ] -padx 10 -pady 6 -column 2 -row 4 -columnspan 3 -sticky "snew"
# grid [ ttk::combobox .sof_entry -textvariable sof_file -values "" -background white \
	-font {Courier -17 } -foreground black -justify left -state disabled -width 15] -padx 10 -pady 6 -column 2 -row 3 -columnspan 2 -sticky "snew"
grid [button .link_button -text "Link"  -height 1 -width 12 \
	-command {set mode [link_press $ips $credential_fh $ip_address $password $sof_file $pws $cdf_file] } -state disabled ] -padx 10 -pady 6 -column 4 -row 6 -columnspan 1
grid [button .rm_ips_button -text "Clear IPv4s"\
	-command {lassign [remove_ips] ips credential_fh ip_address password sof_file mode pws; .ip_address configure -values $ips} -state normal ] -padx 10 -pady 6 -column 1 -row 6 -columnspan 1
grid [button .sof_select_button -text "Select .sof"\
	-command {set sof_file [tk_getOpenFile]; .sof_ent xview moveto 1.0; .sof_ent icursor end} -state normal ] -padx 10 -pady 6 -column 2 -row 6 -columnspan 1
grid [button .cdf_select_button -text "Select .cdf" \
	-command {set cdf_file [tk_getOpenFile]; .cdf_ent xview moveto 1.0; .sof_ent icursor end} -state normal ] -padx 10 -pady 6 -column 3 -row 6 -columnspan 1
grid [text .msg -background white -height 3 -width 40 -foreground green -relief ridge \
	-borderwidth 3 -font {Courier -17} -state disabled -wrap word -yscrollcommand {.scroll set} ] -padx 10 -pady 10 -column 1 -row 5 -columnspan 4	
grid [scrollbar .scroll -command {.msg yview}] -padx 10 -pady 2 -column 5 -row 5 -columnspan 1

##### Initialize the message window
status_message "Initializing..."

##### Spawn the periodic coroutine
spawn "periodic_function 1"
