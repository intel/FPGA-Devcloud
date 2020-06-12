#############################################################################################################
# The following flow assumes A10_OPENCL_AFU directory doesn't exist and sample design hasn't been copied over
# Arria 10 Devstack version 1.2.1
# **Adjust commands to your own needs.**
#############################################################################################################

# Initial Setup
source /data/intel_fpga/devcloudLoginToolSetup.sh
tools_setup -t A10DS
# Job will exit if directory already exists; no overwrite. No error message.
[ ! -d ~/A10_OPENCL_AFU/v1.2.1 ] && mkdir -p ~/A10_OPENCL_AFU/v1.2.1 || exit 0

# Copy Over sample design
cp $OPAE_PLATFORM_ROOT/opencl/exm_opencl_hello_world_x64_linux.tgz A10_OPENCL_AFU/v1.2.1
cd A10_OPENCL_AFU/v1.2.1
tar xvf exm_opencl_hello_world_x64_linux.tgz

# Check Arria 10 PAC card connectivity
aocl diagnose
error_check

# Running project in Emulation mode
cd hello_world
aoc -march=emulator -v device/hello_world.cl -o bin/hello_world_emulation.aocx
# Creating symbolic link to emulation .aocx
ln -sf hello_world_emulation.aocx bin/hello_world.aocx
make
# Run host code for version 1.2.1
./bin/host -emulator
error_check

# Running project in FPGA Hardware Mode (this takes approximately 1 hour)
aoc device/hello_world.cl -o bin/hello_world_fpga.aocx -board=pac_a10
# Relink to hardware .aocx
ln -sf hello_world_fpga.aocx bin/hello_world.aocx
# Availavility of Acceleration cards
aoc -list-boards
error_check
# Get device name
aocl diagnose
error_check
# Converting to an unsigned .aocx file
cd bin
printf "Y\nY\n" | source $AOCL_BOARD_PACKAGE_ROOT/linux64/libexec/sign_aocx.sh -H openssl_manager -i hello_world_fpga.aocx -r NULL -k NULL -o hello_world_fpga_unsigned.aocx
error_check
# Programmming PAC Card
aocl program acl0 hello_world_fpga_unsigned.aocx
./host
error_check