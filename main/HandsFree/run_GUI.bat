set path_to_launch=<extract_path>/RemoteConsole<devkit>/Source/main.tcl
set quartus_bin=<quartus_install_dir>/intelFPGA_lite/<version number>/quartus/bin64
START /min /WAIT  C:/Windows/System32/taskkill /IM "system-console.exe" /F
START /min /WAIT C:/Windows/System32/taskkill /IM "quartus_sh.exe" /F
START /min %quartus_bin%/quartus_sh --script "%path_to_launch%"