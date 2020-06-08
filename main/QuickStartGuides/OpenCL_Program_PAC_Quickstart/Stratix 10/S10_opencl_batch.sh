#date
#hostname
source /data/intel_fpga/devcloudLoginToolSetup.sh
tools_setup -t S10DS
cd ~/S10_OPENCL_AFU/hello_world
#Make sure board working properly with proper drivers
aocl diagnose
error_check

#Compile for emulation
aoc -march=emulator -legacy-emulator device/hello_world.cl -o bin/hello_world_emulation.aocx
echo "Creating symbolic link to emulation bin/hello_world_emulation.aocx file"
ln -sf hello_world_emulation.aocx bin/hello_world.aocx
# Compile host software
make
# Run in emulation mode
CL_CONTEXT_EMULATOR_DEVICE_INTELFPGA=1 ./bin/host
error_check

# Clean up directory
if [ -d bin/hello_world_fpga ]; then
  echo "Removing bin/hello_world_fpga"
  rm -rf bin/hello_world_fpga
fi

# Compile for FPGA hardware this takes a long time
aoc device/hello_world.cl -o bin/hello_world_fpga.aocx -board=pac_s10_dc
# Relink hardware .aocx
ln -sf hello_world_fpga.aocx bin/hello_world.aocx
aocl program acl0 bin/hello_world.aocx
# Run host code
./bin/host
error_check