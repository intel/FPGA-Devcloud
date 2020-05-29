# Initial Setup
source /data/intel_fpga/devcloudLoginToolSetup.sh
tools_setup -t A10OAPI
mkdir A10_ONEAPI
# Copy Over sample design
cd A10_ONEAPI
mkdir vector-add

# Running project in Emulation mode
cd ~/A10_ONEAPI/vector-add
make run_emu -f Makefile.fpga
# Running project in FPGA Hardware Mode
make run_hw -f Makefile.fpga