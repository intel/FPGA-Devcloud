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
# Arria 10 Devstack version 1.2.1
# **Adjust commands to your own needs.**
##########################################################################################################

# Initial Setup
source /data/intel_fpga/devcloudLoginToolSetup.sh
tools_setup -t A10DS
# Job will exit if directory already exists; no overwrite. No error message.
[ ! -d ~/A10_RTL_AFU/v1.2.1 ] && mkdir -p ~/A10_RTL_AFU/v1.2.1 || exit 0

# Copy Over sample design
cp -r $OPAE_PLATFORM_ROOT/hw/samples/dma_afu A10_RTL_AFU/v1.2.1

# Compile RTL code into FPGA bitstream
cd A10_RTL_AFU/v1.2.1/dma_afu
printf "\n%s" "Compiling FPGA bitstream:"
afu_synth_setup --source hw/rtl/filelist.txt build_synth
error_check
# Run compilation command (this takes approximately 40 minutes)
cd build_synth
$OPAE_PLATFORM_ROOT/bin/run.sh
error_check

# Convert .gbs file to an unsigned .gbs
##############################################################################################
##### In development. For now please run the following manually to successfully convert to an
##### unsigned .gbs file, download bitstream into the PAC card, and run the host code.
#devcloud_login -I A10PAC 1.2.1
#tools_setup -t A10DS
#cd A10__RTL_AFU/v1.2.1/dma_afu/build_synth
#PACSign PR -t UPDATE -H openssl_manager -i dma_afu.gbs -o dma_afu_compile_unsigned.gbs
##### Type Y to the following to accept an unsigned bitstream
#       No root key specified. Generate unsigned bitstream? Y = yes, N = no: Y
#       No CSK specified. Generate unsigned bitstream? Y = yes, N = no: Y
##### Availavility of PCI Accelerator cards
#lspci | grep accel
##### Download bitstream into PAC Card
#fpgasupdate dma_afu_compile_unsigned.gbs
##### Compile host software (this takes approximately 10 minutes)
#cd ../sw
#make clean
#make
#./fpga_dma_test 0
