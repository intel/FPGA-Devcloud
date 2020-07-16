if {[catch {set a [open |[list quartus_sh --script ../tcl/main.tcl] r+]}] != 0 } {
	if {[catch {cd ../; set a [open |[list quartus_sh --script ../../tcl/main.tcl] r+]}] != 0 }
		post_message "Could not find main.tcl using relative path!"
}
