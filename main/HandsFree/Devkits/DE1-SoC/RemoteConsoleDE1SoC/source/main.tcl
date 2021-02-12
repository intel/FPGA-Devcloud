##### Figure out path to this script's location
variable main_location [file normalize [info script]]

set exit_flag 0
set console_script 				"${main_location}/../console.tcl"
set gui_server_connect_script 	"${main_location}/../gui_server.tcl"
set gui_board_path 				"${main_location}/../gui_board.tcl"

##### Source global variables
source "${main_location}/../../setup.tcl"

##### Source main procedures
source "${main_location}/../main_procs.tcl"

##### Connect, program and link device, and return pipe name
lassign [connect_pgm_link $main_location $console_script $gui_server_connect_script $cfg_part $ign_part $prog_regex ] sys_cons_pipe device

if { $sys_cons_pipe == 1 } {

	exit

}

##### Launch board GUI and tell system console to begin sending transactions
set gui_board_pipe [launch_board_gui $gui_board_path $sys_cons_pipe $device]
if { $gui_board_pipe == 1 } {

	exit

}

##### Enter run loop
run_remote_console $gui_board_pipe $sys_cons_pipe