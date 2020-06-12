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
fpgaconf -B 0x3b dma_afu.gbs
error_check

# Compile host software (this takes approximately 10 minutes)
cd ../sw
make clean
make
./fpga_dma_test 0
error_check