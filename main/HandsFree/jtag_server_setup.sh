#!/bin/bash

# Initialize static variables
home="/usr/local/bin/"
param_fh="${home}jtag_server_params.sh"
output_txt_fh=jtag_start_out.txt
password_fh=jtag_server_passwords.txt

eval "sudo rm -rf /usr/local/bin/*jtag*"
eval "sudo rm -rf /usr/local/bin/*startup*"
eval "sudo rm -rf /usr/local/bin/*device*"
eval "sudo rm -rf /etc/systemd/system/*jtag*"
eval "sudo rm -rf /etc/systemd/system/*JTAG*"

eval "sudo apt-get install libudev1:i386"
eval "sudo ln -sf /lib/x86_64-linux-gnu/libudev.so.1 /lib/x86_64-linux-gnu/libudev.so.0"

eval "sudo rm -rf /etc/udev/rules.d/*altera*"

# Write and load the Pre-JTAGd systemd service
sudo cat > "/etc/udev/rules.d/51-altera-usbblaster.rules" <<- EOM

SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6001", MODE="0666"
SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6002", MODE="0666"
SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6003", MODE="0666"
SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6010", MODE="0666"
SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6810", MODE="0666"

EOM

eval "sudo udevadm control --reload-rules && udevadm trigger"

# Initialize dynamic variables
JTAG_pw=""
qp_install_directory=""
startup_service_idx=1
port=0
num_kits=0
port_array=()
bus_array=()

# Initialize output file
eval "echo \"Standard out and error of program:\" > ${output_txt_fh} 2>&1"

# Get ipV4 to distribute to users and initialize password file
eval "echo \"IPv4 Login Credential:\" > ${password_fh} 2>&1"
eval "ip addr show | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' >> ${password_fh} 2>&1"

function get_jtag_server_params {

 # If parameters exist, use them as suggestions
 if [[ -e "${param_fh}" ]]; then
   source "${param_fh}"
 fi

 eval "echo \" \""

 read -p "Enter the Quartus Programmer and Tools install directory: " -i $qp_install_directory -e qp_install_directory
 eval "echo \"qp_install_directory=\\\"$qp_install_directory\\\"\" >  $param_fh"

 read -p "Enter the JTAG server password: " -i $JTAG_pw -e  JTAG_pw
 eval "echo \"JTAG_pw=\\\"$JTAG_pw\\\"\" >> $param_fh "
 eval "echo \" \""

}

function get_and_check_params {

 while true; do

  # If it is inform user, else initialize
  if [[ -e "${param_fh}" ]]; then

   eval "echo \"Found params file.\""
   eval "echo \" \""

  else

   eval "echo \"JTAG server params file missing!\""
   eval "echo \" \""
   get_jtag_server_params

  fi

  source ${param_fh}

  # Check that all necessary variables are defined
  if { [ -z ${JTAG_pw+x} ] || [ -z ${qp_install_directory+x} ]; }; then

   eval "echo \"Couldn't find setup variables!\""
   eval "echo \" \""
   get_jtag_server_params

  else

   eval "echo \"All setup variables defined.\""
   break

  fi

 done
}

function clear_jtagd_cache {

 # Stop all jtagconfig and jtag daemon processes
 eval "sudo killall -9 jtagd >> ${output_txt_fh} 2>&1"
 eval "sleep 2"

 # Double check
 eval "sudo killall -9 jtagd >> ${output_txt_fh} 2>&1"
 eval "sleep 2"

 # Remove all data from previous jtagd
 eval "sudo rm -rf /etc/jtagd/ >> ${output_txt_fh} 2>&1"

 # Create new directory for jtagd and update priveledges
 eval "sudo mkdir /etc/jtagd/ >> ${output_txt_fh} 2>&1"
 eval "sudo touch /etc/jtagd/jtagd.config >> ${output_txt_fh} 2>&1"
 eval "sudo chmod +rwx /etc/jtagd/ >> ${output_txt_fh} 2>&1"

}

function run_initial_jtagd {

 # Runs a JTAG daemon at port 1309, but doesn't open it's port
 eval "sleep 5"
 eval "echo \" \""
 eval "echo \"Starting initial JTAG daemon...\""
 eval "${qp_install_directory}qprogrammer/bin/jtagd --port 1309 --foreground & >> ${output_txt_fh} 2>&1"
 eval "sleep 5"

}

function run_random_port_jtagd {

  # Runs a JTAG daemon on a random port, and saves random port to a file
  eval "${qp_install_directory}qprogrammer/bin/jtagd --port 0 --port-file /tmp/jtag_n.port --foreground & >> ${output_txt_fh} 2>&1"
  eval "echo \" \""
  eval "echo \"Setting up daemon and startup service on random port...\""
  eval "sleep 2"
  # Set the port variable to random port
  port=$(eval "cat /tmp/jtag_n.port")
  # Allow this port through the firewall
  eval "sudo ufw disable >> ${output_txt_fh} 2>&1"
  eval "sudo ufw allow $port >> ${output_txt_fh} 2>&1"
  eval "sudo ufw enable >> ${output_txt_fh} 2>&1"
  # Create a JTAGd startup service on this port
  write_startup_service_jtagd
  startup_service_idx=$((startup_service_idx + 1))

}

function start_jtag_server {

 # Start JTAG server with JTAG_pw password
 eval "sleep 5"
 eval "sudo ${qp_install_directory}qprogrammer/bin/jtagconfig --enableremote $JTAG_pw >> ${output_txt_fh} 2>&1"
 eval "sleep 2"
 eval "sudo ${qp_install_directory}qprogrammer/bin/jtagconfig >> ${home}device_log.txt 2>&1"
 eval "sleep 2"
 num_kits=$(eval "cat ${home}device_log.txt | grep -o -i \") USB-Blaster\" | wc -l")
 eval "echo \"${num_kits} JTAG server connected devices.\"  >> ${output_txt_fh} 2>&1"
 eval "echo \" \""
 eval "echo \"${num_kits} JTAG server connected devices.\""
 eval "echo \" \""
 bus_array=($(eval "cat /usr/local/bin/device_log.txt|grep -oP '(?<=\[).*(?=\])'"))
 
}

function reset_firewall {

 eval "echo \"Resetting firewall rules (to remove previously opened ports): \""
 eval "echo \" \""

 eval "sudo ufw disable >> ${output_txt_fh} 2>&1"
 eval "sudo ufw reset"
 eval "sudo ufw allow ssh >> ${output_txt_fh} 2>&1"
 eval "sudo ufw enable >> ${output_txt_fh} 2>&1"

 eval "sleep 2"

}

function write_startup_service_prejtagd {

# Write the script that the pre-JTAGd service will call to clear the JTAG cache
sudo cat > "${home}prejtagd_service_script.sh" <<- EOM
#!/bin/bash

eval "sudo killall -9 jtagd >> ${home}startup_log.txt 2>&1"
eval "sudo sleep 2"

eval "sudo killall -9 jtagd >> ${home}startup_log.txt 2>&1"
eval "sudo sleep 2"

eval "sudo rm -rf /etc/jtagd/ >> ${home}startup_log.txt 2>&1"

eval "sudo mkdir /etc/jtagd/ >> ${home}startup_log.txt 2>&1"
eval "sudo touch /etc/jtagd/jtagd.config >> ${home}startup_log.txt 2>&1"
eval "sudo chmod +rwx /etc/jtagd/ >> ${home}startup_log.txt 2>&1"

eval "sudo sleep 5"

EOM

eval "sudo chmod +rwx ${home}prejtagd_service_script.sh"

# Write and load the Pre-JTAGd systemd service
sudo cat > "/etc/systemd/system/preprejtagd.service" <<- EOM
[Unit]
Description=Pre-Pre-JTAG Daemon Service
After=network-online.target 
Wants=network-online.target

[Service]
ExecStartPre=${home}prejtagd_service_script.sh
ExecStart=${qp_install_directory}qprogrammer/bin/jtagd --port 1309 --foreground
Type=simple
RemainAfterExit=yes
RestartSec=120
 
[Install]
WantedBy=multi-user.target
EOM

eval "sudo systemctl disable prejtagd >> ${output_txt_fh} 2>&1"
eval "sleep 1"

eval "sudo systemctl daemon-reload >> ${output_txt_fh} 2>&1"
eval "sleep 1"

eval "sudo systemctl enable prejtagd >> ${output_txt_fh} 2>&1"

# Write and load the Pre-JTAGd systemd service
sudo cat > "/etc/systemd/system/preprejtagd.service" <<- EOM
[Unit]
Description=Pre-JTAG Daemon Service
After=network-online.target preprejtagd.service
Wants=network-online.target preprejtagd.service

[Service]
ExecStartPre=/bin/sleep 10
ExecStart=${qp_install_directory}qprogrammer/bin/jtagconfig --enableremote $JTAG_pw
Type=simple
RemainAfterExit=yes
RestartSec=120
 
[Install]
WantedBy=multi-user.target
EOM

eval "sudo systemctl disable preprejtagd >> ${output_txt_fh} 2>&1"
eval "sleep 1"

eval "sudo systemctl daemon-reload >> ${output_txt_fh} 2>&1"
eval "sleep 1"

eval "sudo systemctl enable preprejtagd >> ${output_txt_fh} 2>&1"

}

function write_startup_service_jtagd {

# Write and load the systemd JTAGd service
cat > "/etc/systemd/system/jtagd_service_${startup_service_idx}.service" <<- EOM
[Unit]
Description=Jtag Daemon ${startup_service_idx}
After=network-online.target prejtagd.service
Wants=network-online.target prejtagd.service
 
[Service]
ExecStartPre=/bin/sleep 10
ExecStart=${qp_install_directory}qprogrammer/bin/jtagd --port ${port} --foreground
Type=simple
RemainAfterExit=yes
RestartSec=120
 
[Install]
WantedBy=multi-user.target
EOM

eval "sudo systemctl disable jtagd_service_${startup_service_idx} >> ${output_txt_fh} 2>&1"
eval "sleep 1"

eval "sudo systemctl daemon-reload"
eval "sleep 1"

eval "sudo systemctl enable jtagd_service_${startup_service_idx} >> ${output_txt_fh} 2>&1"

}

function startup {

 # Source the jtag server startup parameters
 get_and_check_params 

 # Start the jtag server daemon
 clear_jtagd_cache

 # Start the 1309 JTAG daemon and startup service
 run_initial_jtagd

 # Start the JTAG server
 start_jtag_server

}

# Get the cached qprogrammer parent directory & JTAG server password
get_jtag_server_params

source $param_fh

# Reset the firewall to only allow SSH through (removes old opened ports)
reset_firewall

# Clear JTAGd cache folders, and start jtag server w/ remote enabled
startup

# Create a startup service to clear the cache, start the JTAG server and run the initial 1309 JTAGd
write_startup_service_prejtagd

# Start a JTAG daemon and startup service for every bus attatched to the JTAG server
# Additionally, generate the passwords to access each devkit
for bus in ${bus_array[*]}
do

eval "echo \"Password for Devkit ${startup_service_idx}:\" >> $password_fh "
run_random_port_jtagd
eval "echo \"$JTAG_pw|${bus}|${port}\" >> $password_fh "

done

exit 0

