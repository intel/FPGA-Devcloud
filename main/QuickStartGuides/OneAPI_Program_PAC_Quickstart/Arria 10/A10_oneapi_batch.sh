# Initial Setup
source /data/intel_fpga/devcloudLoginToolSetup.sh
tools_setup -t A10OAPI
#mkdir A10_ONEAPI
mkdir -r A10_ONEAPI/vector-add

# Copy Over sample design
cd ~/A10_ONEAPI/vector-add
wget -N https://raw.githubusercontent.com/intel/FPGA-Devcloud/feature/main/QuickStartGuides/OneAPI_Program_PAC_Quickstart/Arria%2010/download-file-list.txt
wget -i download-file-list.txt

# Running project in Emulation mode
#cd ~/A10_ONEAPI/vector-add
make run_emu -f Makefile.fpga
error_check

# Running project in FPGA Hardware Mode
make run_hw -f Makefile.fpga
error_check