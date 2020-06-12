##########################################################################################################
# The following flow assumes S10_RTL_AFU directory doesn't exist and sample design hasn't been copied over
# **Adjust commands to your own needs.**
##########################################################################################################

# Initial Setup
source /data/intel_fpga/devcloudLoginToolSetup.sh
tools_setup -t S10DS
# Job will exit if directory already exists; no overwrite. No error message.
[ ! -d ~/S10_RTL_AFU ] && mkdir -p ~/S10_RTL_AFU || exit 0

# Copy Over sample design
cp -r $OPAE_PLATFORM_ROOT/hw/samples/dma_afu S10_RTL_AFU

# Compile RTL code into FPGA bitstream
cd S10_RTL_AFU/dma_afu
afu_synth_setup --source hw/rtl/filelist.txt build_synth
error_check

# Run compilation command (this takes approximately 1 hour)
cd build_synth
$OPAE_PLATFORM_ROOT/bin/run.sh
error_check

# Availavility of PCI Accelerator cards
lspci | grep accel
error_check

# Download bitstream into PAC Card
fpgasupdate dma_afu.gbs 3b:00.0
error_check

# Compile host software
cd ../sw
make clean
make
./fpga_dma_test -s 104857600 -p 1048576 -r mtom
error_check