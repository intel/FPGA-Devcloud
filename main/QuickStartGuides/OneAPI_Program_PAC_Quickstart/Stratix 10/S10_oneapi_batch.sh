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
# The following flow assumes S10_ONEAPI directory doesn't exist and sample design hasn't been copied over
# **Adjust commands to your own needs.**
###########################################################################################################

# Initial Setup
source /data/intel_fpga/devcloudLoginToolSetup.sh
tools_setup -t S10OAPI
# Job will exit if directory already exists; no overwrite. No error message.
[ ! -d ~/S10_ONEAPI/vector-add ] && mkdir -p ~/S10_ONEAPI/vector-add || exit 0

# Copy Over sample design
cd ~/S10_ONEAPI/vector-add
wget -N https://raw.githubusercontent.com/intel/FPGA-Devcloud/master/main/QuickStartGuides/OneAPI_Program_PAC_Quickstart/Stratix%2010/download-file-list.txt
wget -i download-file-list.txt
mkdir src
mv *.cpp *.hpp src/

# Running project in Emulation mode
printf "\\n%s\\n" "Running in Emulation Mode:"
make run_emu -f Makefile.fpga
error_check

# Running project in FPGA Hardware Mode (this takes approximately 1 hour)
printf "\\n%s\\n" "Running in FPGA Hardware Mode:"
make run_hw -f Makefile.fpga
error_check
