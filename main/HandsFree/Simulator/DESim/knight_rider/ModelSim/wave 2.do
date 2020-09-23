onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group Testbench /testbench/clk
add wave -noupdate -expand -group Testbench /testbench/reset
add wave -noupdate -expand -group Testbench /testbench/switch
add wave -noupdate -expand -group Testbench /testbench/key
add wave -noupdate -expand -group Testbench /testbench/vga_clk
add wave -noupdate -expand -group Testbench -radix hexadecimal /testbench/hsync
add wave -noupdate -expand -group Testbench -radix hexadecimal /testbench/vsync
add wave -noupdate -expand -group Testbench /testbench/led
add wave -noupdate -expand -group Testbench /testbench/key_action
add wave -noupdate -expand -group Testbench /testbench/ps2_lock_control
add wave -noupdate -expand -group Testbench -radix hexadecimal /testbench/scan_code
add wave -noupdate -expand -group Testbench -radix hexadecimal /testbench/hex0
add wave -noupdate -expand -group Testbench -radix hexadecimal /testbench/hex1


TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {203024 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 330
configure wave -valuecolwidth 59
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {638701 ps}
