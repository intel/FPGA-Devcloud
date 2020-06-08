###########################################################################################################
# The following flow assumes A10_OPENCL_AFU directory doesn't exist and sample design hasn't been copied over
# Arria 10 Devstack version 1.2.1
# **Adjust commands to your own needs.**
###########################################################################################################

# Initial Setup
source /data/intel_fpga/devcloudLoginToolSetup.sh
tools_setup -t A10DS
# Job will exit if directory already exists; no overwrite.
[ ! -d ~/A10_OPENCL_AFU] && mkdir -p ~/A10_OPENCL_AFU || echo "Directory ~/A10_OPENCL_AFU exists." && exit

# Copy Over sample design
cp $OPAE_PLATFORM_ROOT/opencl/exm_opencl_hello_world_x64_linux.tgz A10_OPENCL_AFU
cd A10_OPENCL_AFU
tar xvf exm_opencl_hello_world_x64_linux.tgz

# Check Arria 10 PAC card connectivity
aocl diagnose
error_check

# Running project in Emulation mode
cd hello_world
aoc -march=emulator -v device/hello_world.cl -o bin/hello_world_emulation.aocx
error_check
make
# Run host code for version 1.2.1
./bin/host -emulator
error_check

# Running project in FPGA Hardware Mode
aoc device/hello_world.cl -o bin/hello_world_fpga.aocx -board=pac_a10
# Availavility of Acceleration cards
aoc --list-boards
error_check
# Get device name
aocl diagnose
error_check
# Converting to an unsigned .aocx file
cd bin
printf "Y\nY\n" | source $AOCL_BOARD_PACKAGE_ROOT/linux64/libexec/sign_aocx.sh -H openssl_manager -i hello_world_fpga.aocx -r NULL -k NULL -o hello_world_fpga_unsigned.aocx
# Programmming PAC Card
aocl program acl0 hello_world_fpga_unsigned.aocx
./host
error_check