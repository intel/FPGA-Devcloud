onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix decimal /tb/sqrt_inst/sqrt_internal_inst/clock
add wave -noupdate -radix decimal /tb/sqrt_inst/sqrt_internal_inst/resetn
add wave -noupdate -radix decimal /tb/component_dpi_controller_sqrt_inst/component_enabled
add wave -noupdate -radix decimal /tb/component_dpi_controller_sqrt_inst/component_done
add wave -noupdate -radix decimal /tb/component_dpi_controller_sqrt_inst/start
add wave -noupdate -radix decimal /tb/sqrt_inst/sqrt_internal_inst/avs_cra_read
add wave -noupdate -radix decimal /tb/sqrt_inst/sqrt_internal_inst/avs_cra_write
add wave -noupdate -radix decimal /tb/sqrt_inst/sqrt_internal_inst/avs_cra_writedata
add wave -noupdate -radix decimal /tb/sqrt_inst/sqrt_internal_inst/avs_cra_readdata
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {671643 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 159
configure wave -valuecolwidth 43
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {24001 ps}
