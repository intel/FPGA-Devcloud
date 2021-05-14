set -x
THIS_TUTORIAL_PATH="$( cd "$(dirname $(realpath "$BASH_SOURCE") )" >/dev/null 2>&1 ; pwd -P )" # The path to this script

# Purge any previously generated files
rm -rf $CODE_STORE_DIR/a.* $CODE_STORE_DIR/a

# Compile and run
if [ $1 = "emulator" ]; then
  g++ -DVERBOSE_DEBUG $THIS_TUTORIAL_PATH/main.cpp $CXX_FLAGS -o $CODE_STORE_DIR/a.out
  env  INTEL_FPGA_OCL_PLATFORM_NAME="$EMULATOR_PLATFORM_NAME"  CL_CONTEXT_EMULATOR_DEVICE_INTELFPGA=1 CL_CONFIG_CHANNEL_DEPTH_EMULATION_MODE=strict BITSTREAM=$CODE_STORE_DIR/a.aocx  AOC_OPTION="-march=emulator  -board=$FPGA_BOARD" $CODE_STORE_DIR/a.out
else
  g++ -DVERBOSE_DEBUG $THIS_TUTORIAL_PATH/main.cpp $CXX_FLAGS $AOCL_LIBS -o $CODE_STORE_DIR/a.out
  env INTEL_FPGA_OCL_PLATFORM_NAME="$HW_RUN_PLATFORM_NAME" BITSTREAM=$CODE_STORE_DIR/a.aocx AOC_OPTION="-board=$FPGA_BOARD" $CODE_STORE_DIR/a.out
fi
