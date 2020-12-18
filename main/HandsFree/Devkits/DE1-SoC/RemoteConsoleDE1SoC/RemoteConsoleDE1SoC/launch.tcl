variable launch_location [file normalize [info script]]
open "|$env(QUARTUS_ROOTDIR)bin64/quartus_sh --script ${launch_location}/../source/main.tcl"