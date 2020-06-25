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

##########################################################################################################
# The following flow assumes A10_RTL_AFU directory doesn't exist and sample design hasn't been copied over
# Arria 10 Devstack version 1.2
# **Adjust commands to your own needs.**
##########################################################################################################

# Initial Setup
source /data/intel_fpga/devcloudLoginToolSetup.sh
tools_setup -t A10DS
# Job will exit if directory already exists; no overwrite. No error message.
[ ! -d ~/A10_RTL_AFU/v1.2 ] && mkdir -p ~/A10_RTL_AFU/v1.2 || exit 0

# Copy Over sample design
cp -r $OPAE_PLATFORM_ROOT/hw/samples/dma_afu A10_RTL_AFU/v1.2

# Compile RTL code into FPGA bitstream
cd A10_RTL_AFU/v1.2/dma_afu
printf "\n%s" "Compiling FPGA bitstream:"
afu_synth_setup --source hw/rtl/filelist.txt build_synth
error_check
# Run compilation command (this takes approximately 40 minutes)
cd build_synth
$OPAE_PLATFORM_ROOT/bin/run.sh
error_check

# Availavility of PCI Accelerator cards
lspci | grep accel
error_check

# Download bitstream into PAC Card
printf "\n%s" "Downloading bitstream:"
fpgaconf -B 0x3b dma_afu.gbs
error_check
# Compile host software (this takes approximately 10 minutes)
cd ../sw
make clean
make
./fpga_dma_test 0
error_check
