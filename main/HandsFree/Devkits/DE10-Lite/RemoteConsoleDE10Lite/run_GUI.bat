set path_to_main=C:/Users/tsheaves/Documents/RemoteConsoleDE10Lite/Source/main.tcl
set quartus_bin=C:/intelFPGA_lite/19.1/quartus/bin64
START /min /WAIT  C:/Windows/System32/taskkill /IM "system-console.exe" /F
START /min /WAIT C:/Windows/System32/taskkill /IM "quartus_sh.exe" /F
START /min %quartus_bin%/quartus_sh --script "%path_to_main%"