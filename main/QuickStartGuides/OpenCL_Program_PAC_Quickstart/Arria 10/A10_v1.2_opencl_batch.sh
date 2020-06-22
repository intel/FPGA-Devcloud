# Copyright 2020 Intel Corporation
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the "Software"), to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions
# of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
# TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

###########################################################################################################
# The following flow assumes A10_OPENCL_AFU directory doesn't exist and sample design hasn't been copied over
# Arria 10 Devstack version 1.2
# **Adjust commands to your own needs.**
###########################################################################################################

# Initial Setup
source /data/intel_fpga/devcloudLoginToolSetup.sh
tools_setup -t A10DS
# Job will exit if directory already exists; no overwrite. No error message.
[ ! -d ~/A10_OPENCL_AFU/v1.2 ] && mkdir -p ~/A10_OPENCL_AFU/v1.2 || exit 0

# Copy Over sample design
cp $OPAE_PLATFORM_ROOT/opencl/exm_opencl_hello_world_x64_linux.tgz A10_OPENCL_AFU/v1.2
cd A10_OPENCL_AFU/v1.2
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
# Run host code for version 1.2
CL_CONTEXT_EMULATOR_DEVICE_INTELFPGA=1 ./bin/host
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
# Programmming PAC Card
aocl program acl0 bin/hello_world.aocx
./bin/host
error_check