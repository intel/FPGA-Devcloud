

# Arria 10 PAC: OpenCL Compilation and Programming on the FPGA devcloud using Arria 10 Devstack version 1.2 / 1.2.1

 

## 1       Introduction

If you are new to the Arria 10 GX PAC card with OpenCL, check out this quick start guide:

https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/ug/ug-qs-ias-opencl-a10.pdf

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

Run the devcloud_login function and connect to an Arria 10 capable node. This function is available in the script: /data/intel_fpga/devcloudLoginToolSetup.sh .

![image](https://user-images.githubusercontent.com/22804500/78613373-8d1d0f80-7820-11ea-80a0-6cc3194ded2d.png)

Select option 1 or option 5 and connect to an Arria 10 ready compute node.

Once on this node, run tools_setup. 

```
tools_setup
```

Select the Arria 10 PAC Compilation and Programming - RTL AFU, OpenCL option.

Make working directory

```bash
mkdir A10_OPENCL_AFU
```

We will then copy the example folder into this project folder. Type this into the terminal:

```bash
cp $OPAE_PLATFORM_ROOT/opencl/exm_opencl_hello_world_x64_linux.tgz A10_OPENCL_AFU
cd A10_OPENCL_AFU
tar xvf exm_opencl_hello_world_x64_linux.tgz
```

Check to make sure connectivity to the Arria 10 PAC card looks ok:

```
aocl diagnose
```

Look for DIAGNOSTIC_PASSED.

#### 3.2 Running OpenCL in emulation mode

The first step of the OpenCL flow is to compile and execute the design for emulation mode. This step allows you to quickly verify the functionality of your code on the CPU without performing the conversion from OpenCL to RTL and from RTL to an FPGA executable, which takes up to an hour.

```
cd hello_world
aoc -march=emulator -v device/hello_world.cl -o bin/hello_world_emulation.aocx
```

The next step is to compile the host code. 

```
make
```

Now run for the host code binary. Note that the with the environment setting shown, the host code knows the .aocx file is for emulation execution on the CPU and not on the FPGA card.\

For version 1.2, you need to run emulation with this command:

```
CL_CONTEXT_EMULATOR_DEVICE_INTELFPGA=1 ./bin/host
```

For version 1.2.1, you need to run emulation with this command:

```
./bin/host -emulator
```

You should see a list of parameters and Kernel execution is complete.

#### 3. 3 Compiling OpenCL code into an FPGA executable

Now that you have emulated your design, you can run the steps to convert OpenCL to RTL, which will subsequently get compiled in Quartus to produce an FPGA executable .aocx file using the following command. This step will take approximately one hour.

```
aoc device/hello_world.cl -o bin/hello_world_fpga.aocx -board=pac_a10
```

#### 3.4 Downloading the bit stream into the PAC card

Next we will be looking for an available acceleration card, convert .aocx to unsigned (v1.2.1), program it, compile the host C code, and run the software program to display on the terminal.

To see what FPGA accelerator cards are available, we type the following into the terminal. 

```bash
aoc --list-boards
```

You will observe the pac_10 board is available. Next, as you did during the initial step, run the aocl diagnose command so that you can get the device name.

```
aocl diagnose
```

Observe that the device name is acl0.

For version **1.2.1 only**, you need to create the unsigned version of the .aocx file. If you use version 1.2, skip this next step.

#### 3.4.1 Converting the 1.2.1 version to an unsigned .aocx file

```
cd bin
```

```
source $AOCL_BOARD_PACKAGE_ROOT/linux64/libexec/sign_aocx.sh -H openssl_manager -i hello_world_fpga.aocx -r NULL -k NULL -o hello_world_fpga_unsigned.aocx
```

Because no root key or code signing key is provided, the script asks if you would like to create an unsigned bitstream, as shown below. Type Y to accept an unsigned bitstream.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;No root key specified.  Generate unsigned bitstream? Y = yes, N = no: **Y**\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;No CSK specified.  Generate unsigned bitstream? Y = yes, N = no: **Y**

#### 3.4.2 Programming the Arria 10 GX PAC Card

Next, you will program the PAC card with hello_world_fpga.aocx (version 1.2) or hello_world_fpga_unsigned.aocx (version 1.2.1) FPGA executable with one of the following commands:

```
aocl program acl0 bin/hello_world_fpga.aocx
```

```
aocl program acl0 hello_world_fpga_unsigned.aocx
```

#### 3.5 Running the host code 

You have run make to build the CPU host executable in the prior section, so its not necessary to run again. Simply run the following command to run a heterogeneous workload that combines CPU and FPGA execution to utilizing the CPU and FPGA working in tandem.

```bash
./bin/host					#version 1.2
```

```bash
./host						#version 1.2.1
```

Note the differences in results from: CL_CONTEXT_EMULATOR_DEVICE_INTELFPGA=1 ./bin/host vs ./bin/host (for version 1.2)\
Note the differences in results from: ./bin/host -emulator vs ./host (for version 1.2.1)

## 4       Document Revision History

List the revision history for the application note.

| Name         | Date      | Changes                                  |
| ------------ | --------- | ---------------------------------------- |
| Larry Landis | 4/2/2020  | Initial Release                          |
| Larry Landis | 4/28/2020 | Added sign_aocx.sh for v1.2.1            |
| Larry Landis | 5/8/2020  | ./bin/host -emulator argument for v1.2.1 |