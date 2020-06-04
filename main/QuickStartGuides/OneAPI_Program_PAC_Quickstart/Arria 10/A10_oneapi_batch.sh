###########################################################################################################
# The following flow assumes A10_ONEAPI directory doesn't exist and sample design hasn't been copied over
# **Adjust commands to your own needs.**
###########################################################################################################

# Initial Setup
source /data/intel_fpga/devcloudLoginToolSetup.sh
tools_setup -t A10OAPI
# Job will exit if directory already exists; no overwrite.
[ ! -d ~/A10_ONEAPI/vector-add ] && mkdir -p ~/A10_ONEAPI/vector-add || echo "Directory ~/A10_ONEAPI/vector-add exists." && exit

# Copy Over sample design
cd ~/A10_ONEAPI/vector-add
wget -N https://raw.githubusercontent.com/intel/FPGA-Devcloud/feature/main/QuickStartGuides/OneAPI_Program_PAC_Quickstart/Arria%2010/download-file-list.txt
wget -i download-file-list.txt

# Running project in Emulation mode
make run_emu -f Makefile.fpga
error_check

# Running project in FPGA Hardware Mode
make run_hw -f Makefile.fpga
error_check