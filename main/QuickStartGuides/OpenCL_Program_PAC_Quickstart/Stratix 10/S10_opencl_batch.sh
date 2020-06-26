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
# The following flow assumes S10_OPENCL_AFU directory doesn't exist and sample design hasn't been copied over
# **Adjust commands to your own needs.**
###########################################################################################################

# Initial Setup
source /data/intel_fpga/devcloudLoginToolSetup.sh
tools_setup -t S10DS
# Job will exit if directory already exists; no overwrite. No error message.
[ ! -d ~/S10_OPENCL_AFU ] && mkdir -p ~/S10_OPENCL_AFU || exit 0

# Copy Over sample design
cp $OPAE_PLATFORM_ROOT/opencl/exm_opencl_hello_world_x64_linux.tgz S10_OPENCL_AFU
cd S10_OPENCL_AFU
printf "\\n%s\\n" "Extracting tarfiles:"
tar xvf exm_opencl_hello_world_x64_linux.tgz

# Check Stratix 10 PAC card connectivity
aocl diagnose
error_check

#Compile for emulation
cd hello_world
printf "\\n%s\\n" "Running in Emulation Mode:"
aoc -march=emulator -legacy-emulator device/hello_world.cl -o bin/hello_world_emulation.aocx
# Creating symbolic link to emulation .aocx
ln -sf hello_world_emulation.aocx bin/hello_world.aocx
# Compile host software
make
# Run in emulation mode
CL_CONTEXT_EMULATOR_DEVICE_INTELFPGA=1 ./bin/host
error_check

# Compile for FPGA hardware (this takes approximately 1 hour)
printf "\\n%s\\n" "Running in FPGA Hardware Mode:"
aoc device/hello_world.cl -o bin/hello_world_fpga.aocx -board=pac_s10_dc
# Relink to hardware .aocx
ln -sf hello_world_fpga.aocx bin/hello_world.aocx
# Program PAC Card
aocl program acl0 bin/hello_world.aocx
# Run host code
./bin/host
error_check
