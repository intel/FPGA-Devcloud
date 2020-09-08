# stop any simulation that is currently running
quit -sim

# create the default "work" library
vlib work;

# compile the Verilog source code in the parent folder
vlog ../*.v
vlog *.v

# start the Simulator, including some libraries that may be needed
vsim work.testbench
# show waveforms specified in wave.do
do wave.do
# advance the simulation the desired amount of time
run 200ns


set LEDCode "l"
set HEXCode "h"
set KeyboardLEDCode "p"

set val {}
set code {}

# led value
set lights_prev {}
set lights_cur {}

# seven-seg value
set hex_out 0
set h0_prev [examine -hex hex0]
set h1_prev [examine -hex hex1]
set h2_prev [examine -hex hex2]
set h3_prev [examine -hex hex3]
set h4_prev [examine -hex hex4]
set h5_prev [examine -hex hex5]
set h0 {}
set h1 {}
set h2 {}
set h3 {}
set h4 {}
set h5 {}

# keyboard LED value
set lockLED_prev {}
set lockLED_cur  {}


while {$val ne "end"} {

    for {set i 0} {$i < 840} {incr i} {

        set data [gets stdin]
        if {$data eq "end"} {
            set val "end"
            break
        } else {
            # switch
            if {[string index $data 0] eq "s"} {

                # TODO: cases for switch index >=10
                set switchIndex [string index $data 2]
                set switchStatus {}

                if {[string index $data 1] eq "o"} {
                    set switchStatus 1
                } else {
                    set switchStatus 0
                }

                switch $switchIndex {
                    0 {
                        force -freeze {switch[0]} $switchStatus 0ns
                    }
                    1 {
                        force -freeze {switch[1]} $switchStatus 0ns
                    }
                    2 {
                        force -freeze {switch[2]} $switchStatus 0ns
                    }
                    3 {
                        force -freeze {switch[3]} $switchStatus 0ns
                    }
                    4 {
                        force -freeze {switch[4]} $switchStatus 0ns
                    }
                    5 {
                        force -freeze {switch[5]} $switchStatus 0ns
                    }
                    6 {
                        force -freeze {switch[6]} $switchStatus 0ns
                    }
                    7 {
                        force -freeze {switch[7]} $switchStatus 0ns
                    }
                    8 {
                        force -freeze {switch[8]} $switchStatus 0ns
                    }
                    9 {
                        force -freeze {switch[9]} $switchStatus 0ns
                    }
                    default {
                    }
                    #end switch    
                } 
            } else {
                    # key
                    if {[string index $data 0] eq "k"} {
                        set keyIndex [string index $data 1]
                        set keyStatus [string index $data 2]

                        switch $keyIndex {
                            0 {
                                force -freeze {key[0]} $keyStatus 0ns
                            }
                            1 {
                                force -freeze {key[1]} $keyStatus 0ns
                            }
                            2 {
                                force -freeze {key[2]} $keyStatus 0ns
                            }
                            3 {
                                force -freeze {key[3]} $keyStatus 0ns
                            }
                            default {
                            }
                        }
                    } else {
                        # ps2 keyboard scancode
                        if {[string index $data 0] eq "p"} {
                            set code [string range $data 1 end]
                            force {scan_code[7 : 0]} 'h$code 0ns
                            force -freeze {key_action} 1 0ns
                            force -freeze {key_action} 0 30ns
                        }
                    }
            }
        
            run 20000ns

            set lights_cur [examine led]
            if {$lights_prev ne $lights_cur} {
                puts $LEDCode$lights_cur
                set lights_prev $lights_cur
            }


            set hex_out 0

            if {$h0_prev ne "zz"} {
                set h0 [examine -hex hex0]
                if {$h0 ne $h0_prev} {
                    set h0_prev $h0
                    set hex_out 1
                }
            }
            if {$h1_prev ne "zz"} {
                set h1 [examine -hex hex1]
                if {$h1 ne $h1_prev} {
                    set h1_prev $h1
                    set hex_out 1
                }
            }
            if {$h2_prev ne "zz"} {
                set h2 [examine -hex hex2]
                if {$h2 ne $h2_prev} {
                    set h2_prev $h2
                    set hex_out 1
                }
            }
            if {$h3_prev ne "zz"} {
                set h3 [examine -hex hex3]
                if {$h3 ne $h3_prev} {
                    set h3_prev $h3
                    set hex_out 1
                }
            }
            if {$h4_prev ne "zz"} {
                set h4 [examine -hex hex4]
                if {$h4 ne $h4_prev} {
                    set h4_prev $h4
                    set hex_out 1
                }
            }
            if {$h5_prev ne "zz"} {
                set h5 [examine -hex hex5]
                if {$h5 ne $h5_prev} {
                    set h5_prev $h5
                    set hex_out 1
                }
            }

            if {$hex_out eq 1} {
                puts $HEXCode$h0_prev$h1_prev$h2_prev$h3_prev$h4_prev$h5_prev
            }

            
            set lockLED_cur [examine ps2_lock_control]
            if {$lockLED_cur ne $lockLED_prev} {
                set lockLED_prev $lockLED_cur
                puts $KeyboardLEDCode$lockLED_cur
            }

        }
    }
    
    puts "frame updated"
}
