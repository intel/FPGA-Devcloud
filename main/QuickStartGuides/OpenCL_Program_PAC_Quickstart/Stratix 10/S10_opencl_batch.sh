###########################################################################################################
# The following flow assumes S10_OPENCL_AFU directory doesn't exist and sample design hasn't been copied over
# **Adjust commands to your own needs.**
###########################################################################################################

# Initial Setup
#date
#hostname
source /data/intel_fpga/devcloudLoginToolSetup.sh
tools_setup -t S10DS
# Job will exit if directory already exists; no overwrite. No error message.
[ ! -d ~/S10_OPENCL_AFU] && mkdir -p ~/S10_OPENCL_AFU || exit 0

# Copy Over sample design
cp $OPAE_PLATFORM_ROOT/opencl/exm_opencl_hello_world_x64_linux.tgz S10_OPENCL_AFU
cd S10_OPENCL_AFU
tar xvf exm_opencl_hello_world_x64_linux.tgz

# Check Stratix 10 PAC card connectivity
aocl diagnose
error_check

#Compile for emulation
cd hello_world
aoc -march=emulator -legacy-emulator device/hello_world.cl -o bin/hello_world_emulation.aocx
# Creating symbolic link to emulation .aocx file
ln -sf hello_world_emulation.aocx bin/hello_world.aocx
# Compile host software
make
# Run in emulation mode
CL_CONTEXT_EMULATOR_DEVICE_INTELFPGA=1 ./bin/host
error_check

# Compile for FPGA hardware (this takes approximately 1 hour)
aoc device/hello_world.cl -o bin/hello_world_fpga.aocx -board=pac_s10_dc
# Relink hardware .aocx
ln -sf hello_world_fpga.aocx bin/hello_world.aocx
aocl program acl0 bin/hello_world.aocx
# Run host code
./bin/host
error_check