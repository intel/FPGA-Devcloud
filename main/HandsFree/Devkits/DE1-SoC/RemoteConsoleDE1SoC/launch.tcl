# Stop all Quartus Shell tasks (protects against zombie processes stacking)
if { [catch { exec taskkill /IM "quartus_sh.exe" /F } ] != 0} {
	# Do nothing
	# Needs to be adapted for Linux
}
# Stop all System Console tasks (protects against zombie processes stacking)
if { [catch { exec taskkill /IM "system-console.exe" /F } ] != 0} {
	# Do nothing
	# Needs to be adapted for Linux
}
# Stop all System Console tasks (protects against zombie processes stacking)
if { [catch { exec taskkill /IM "quartus_pgm.exe" /F } ] != 0} {
	# Do nothing
	# Needs to be adapted for Linux
}
variable launch_location [file normalize [info script]]
open "|$env(QUARTUS_ROOTDIR)bin64/quartus_sh --script ${launch_location}/../source/main.tcl"