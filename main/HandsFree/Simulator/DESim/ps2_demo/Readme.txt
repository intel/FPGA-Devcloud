Push buttons:
KEY[0]: reset
KEY[1]: send command from host(FPGA) to device(PS/2 keyboard)

Switches:
SW[7:0]: the command from host to device (in binary), e.g. echo command: 8'hEE, set status LEDs command: 8'hED


Seven-seg:
HEX[1:0]: display the scancode received by host

PS/2 Keyboard:
Type in "Type Here" text box, the keyboard will send command to host