set -x
THIS_TUTORIAL_PATH="$( cd "$(dirname $(realpath "$BASH_SOURCE") )" >/dev/null 2>&1 ; pwd -P )" # The path to this script

# Purge any previously generated files
rm -rf $CODE_STORE_DIR/a.* $CODE_STORE_DIR/a

# Compile and run
if [ $1 = "emulator" ]; then
  g++ $THIS_TUTORIAL_PATH/main.cpp $CXX_FLAGS -o $CODE_STORE_DIR/a.out
  env  INTEL_FPGA_OCL_PLATFORM_NAME="$EMULATOR_PLATFORM_NAME"  CL_CONTEXT_EMULATOR_DEVICE_INTELFPGA=1 CL_CONFIG_CHANNEL_DEPTH_EMULATION_MODE=strict BITSTREAM=$CODE_STORE_DIR/a.aocx  AOC_OPTION="-march=emulator  -board=$FPGA_BOARD" $CODE_STORE_DIR/a.out
else
  g++ $THIS_TUTORIAL_PATH/../host.cpp -g -DSIZE=8 -DBB=1 -DB=1 -DLINUX -DALTERA_CL -fPIC -I$INTELFPGAOCLSDKROOT/examples_aoc/common/inc  $INTELFPGAOCLSDKROOT/examples_aoc/common/src/AOCLUtils/opencl.cpp $INTELFPGAOCLSDKROOT/examples_aoc/common/src/AOCLUtils/options.cpp -I$INTELFPGAOCLSDKROOT/host/include $AOCL_LIBS -lelf -o host.out
  env BITSTREAM="bitstream/lu-io.aocx" ./host.out
fi
