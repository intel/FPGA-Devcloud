source /data/intel_fpga/devcloudLoginToolSetup.sh
tools_setup -t A10DS
cd ~/A10_OPENCL_AFU/hello_world
aoc -march=emulator -v device/hello_world.cl -o bin/hello_world.aocx
make
CL_CONTEXT_EMULATOR_DEVICE_INTELFPGA=1 ./bin/host
aoc device/hello_world.cl -o bin/hello_world.aocx -board=pac_a10
aocl program acl0 bin/hello_world.aocx