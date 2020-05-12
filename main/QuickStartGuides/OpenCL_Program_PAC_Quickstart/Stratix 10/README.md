

# Stratix 10 PAC: OpenCL Compilation and Programming on the FPGA devcloud using Stratix 10 Devstack version 2.0.1

 

## 1       Introduction

If you are new to the Stratix 10 PAC card with OpenCL, check out this quick start guide:

https://www.intel.com/content/www/us/en/programmable/documentation/qgu1548972652523.html

This demonstration will step the user through the following steps:

1. Select appropriate compute node machine on the FPGA devcloud
2. Load the appropriate tools
3. Copy over the sample OpenCL design
4. Take the sample design and compile for emulation mode (kernels will run on the CPU)
5. Compile the application software using the gcc C compiler
6. Execute in emulation mode
7. Convert the OpenCL code to RTL and into an FPGA executable 
8. Download the OpenCL FPGA bitstream to the PAC card
9. Run the application software on the host and show that the host CPU  and FPGA interact to solve heterogenous workloads. Results should be comparable to emulation mode, with improved throughput.



## 2       Assumptions

This lab assumes the following:

- Basic FPGA knowledge
- Basic OpenCL knowledge
- Intel Devcloud registration and SSH key set up
- MobaXterm installed and set up, X2Go optional



## 3       Walkthrough

#### 3.1            Initial Setup

Run the devcloud_login function and connect to a Stratix 10 capable node. This function is available in the script: /data/intel_fpga/devcloudLoginToolSetup.sh .

![image](https://user-images.githubusercontent.com/22804500/78614057-5a741680-7822-11ea-90de-39ce2a9a94dd.png)

Select option 3 or option 5 and connect to a Stratix 10 ready compute node.

Once on this node, run tools_setup. 

```
tools_setup
```

Select the Stratix 10 PAC Compilation and Programming - RTL AFU, OpenCL option.

Make  working directory

```bash
mkdir S10_OPENCL_AFU
```

We will then copy the example folder into this project folder. Type this into the terminal:

```bash
cp $OPAE_PLATFORM_ROOT/opencl/exm_opencl_hello_world_x64_linux.tgz S10_OPENCL_AFU
cd S10_OPENCL_AFU
tar xvf exm_opencl_hello_world_x64_linux.tgz
```

Check to make sure connectivity to the Stratix 10 PAC card looks ok:

```
aocl diagnose
```

Look for DIAGNOSTIC_PASSED. For the specific test on the installed board, use:

```
aocl diagnose acl0
```

Note that this shows a board name is pac_s10_dc. You will need this for a subsequent step.

#### 3.2 Running OpenCL in emulation mode

The first step of the OpenCL flow is to compile and execute the design for emulation mode. This step allows you to quickly verify the functionality of your code on the CPU without performing the conversion from OpenCL to RTL and from RTL to an FPGA executable, which takes up to an hour.

```
cd hello_world
aoc -march=emulator -legacy-emulator device/hello_world.cl -o bin/hello_world_emulation.aocx
```

The next step is to compile the host code. 

```
make
```

Now run emulation with the host code binary. Note that the with the environment setting shown, the host code runs the .aocx file for emulation execution on the CPU and not on the FPGA card.

```
CL_CONTEXT_EMULATOR_DEVICE_INTELFPGA=1 ./bin/host
```

You should see a list of parameters and Kernel execution is complete.

#### 3. 3 Compiling OpenCL code into an FPGA executable

Now that you have emulated your design, you can run the steps to convert OpenCL to RTL, which will subsequently be compiled in Quartus to produce an FPGA executable .aocx file. This step will take approximately one hour.

```
aoc device/hello_world.cl -o bin/hello_world_fpga.aocx -board=pac_s10_dc
```

#### 3.4 Downloading the bit stream into the PAC card and running the host code

Similar to the prior step of running bin/host, but without the environment variable setting.

Run the following:

```
./bin/host
```

## 4       Batch Submission

The follow commands can be included in a batch script (in this case S10_opencl_batch.sh) to launch the OpenCL emulation flow, followed by the compilation and FPGA board programming flow using aoc commands. Adjust commands to your own needs.

```
source /data/intel_fpga/devcloudLoginToolSetup.sh
tools_setup -t S10DS
cd ~/S10_OPENCL_AFU/hello_world
aocl diagnose

aoc -march=emulator -legacy-emulator device/hello_world.cl -o bin/hello_world_emulation.aocx
make
CL_CONTEXT_EMULATOR_DEVICE_INTELFPGA=1 ./bin/host

aoc device/hello_world.cl -o bin/hello_world_fpga.aocx -board=pac_s10_dc
./bin/host
```

From the headnode login-2, run this command:

```
devcloud_login -b S10PAC S10_opencl_batch.sh
```

To see the resulting terminal output, consult the files:

S10_opencl_batch.sh.exxxxxx
S10_opencl_batch.sh.oxxxxxx

xxxxxxx is a unique job ID. The .exxxxxx file is the error log and the .oxxxxxx file is the terminal log where success or failure of the commands can be determined.

## 5       Document Revision History

List the revision history for the application note.

| Name             | Date      | Changes            |
| ---------------- | --------- | ------------------ |
| Larry Landis     | 4/4/2020  | Initial Release    |
| Damaris Renteria | 5/11/2020 | Batch Command flow |



 
