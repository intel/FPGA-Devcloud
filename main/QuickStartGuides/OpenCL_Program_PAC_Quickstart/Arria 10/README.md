

# Arria 10 PAC: OpenCL Compilation and Programming on the FPGA devcloud using Arria 10 Devstack version 1.2.1

 <br/>

## 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Introduction

If you are new to the Arria 10 GX PAC card with OpenCL, check out this quick start guide:\
https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/ug/ug-qs-ias-opencl-a10.pdf

Note: As of March 30, 2021, the prior version of Arria 10 PAC v1.2 is no longer supported.

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

<br/>

## 2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Assumptions

This lab assumes the following:

- Basic FPGA knowledge
- Basic OpenCL knowledge
- Intel Devcloud registration and SSH key set up
- MobaXterm installed and set up, X2Go optional

<br/>

## 3&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Walkthrough

#### 3.1 Initial Setup

Run the devcloud_login function and connect to an Arria 10 capable node. This function is available in the script: /data/intel_fpga/devcloudLoginToolSetup.sh .

<img src="https://user-images.githubusercontent.com/59750149/83576210-129e0280-a4e6-11ea-8f32-46af9ff40a4d.png" alt="image" width=70% />

Select option 1 or option 5 and connect to an Arria 10 ready compute node.

Once on this node, run tools_setup. 

```
tools_setup
```

Select the Arria 10 PAC Compilation and Programming - RTL AFU, OpenCL option version 1.2.1.

Make working directory

```bash
mkdir A10_OPENCL_AFU
```

We will then copy the example folder into this project folder. 

Type this into the terminal:

```bash
cp -r /opt/intelFPGA_pro/quartus_19.2.0b57/hld/examples_aoc/hello_world A10_OPENCL_AFU
cp -r /opt/intelFPGA_pro/quartus_19.2.0b57/hld/examples_aoc/common A10_OPENCL_AFU
cd A10_OPENCL_AFU
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
ln -sf hello_world_emulation.aocx bin/hello_world.aocx
```

The next step is to compile the host code. Note: use make clean followed by make to force a recompile.

```
make
```

Now run for the host code binary.
Note that the with the environment setting shown, the host code knows the .aocx file is for emulation execution on the CPU and not on the FPGA card.

For version 1.2.1, you need to run emulation with this command:

```
./bin/host -emulator
```

You should see a list of parameters and Kernel execution is complete.

#### 3.3 Compiling OpenCL code into an FPGA executable

Now that you have emulated your design, you can run the steps to convert OpenCL to RTL, which will subsequently get compiled in Quartus to produce an FPGA executable .aocx file using the following command. This step will take approximately one hour.

```
aoc device/hello_world.cl -o bin/hello_world_fpga.aocx -board=pac_a10
ln -sf hello_world_fpga.aocx bin/hello_world.aocx
```

#### 3.4 Downloading the bit stream into the PAC card

The executable that you run on the FPGA on the PAC card is called an .aocx file (Altera OpenCL executable).

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

Next, you need to create the unsigned version of the .aocx file. 

#### 3.4.1 Converting the 1.2.1 version of .aocx to an unsigned .aocx file

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

Next, you will program the PAC card with hello_world_fpga_unsigned.aocx (version 1.2.1) FPGA executable with one of the following commands:

```
aocl program acl0 hello_world_fpga_unsigned.aocx
```



#### 3.5 Running the host code 

You have already run `make` to build the CPU host executable in the prior section, so it's not necessary to compile the host code again. Simply run the following command to run a heterogeneous workload that combines CPU and FPGA execution to utilizing the CPU and FPGA working in tandem.

```bash
./host
```



## 4&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Batch Submission

The batch script attached above  can be use to launch the OpenCL emulation flow, followed by the compilation and FPGA board programming flow using aocl commands. **Adjust commands within the script to your own needs.**

From the headnode login-2, run this command:

```
devcloud_login -b A10PAC 1.2.1 A10_v1.2.1_opencl_batch.sh
```

To see the resulting terminal output, consult the files:

A10_v1.2[.1] _opencl_batch.sh.exxxxxx\
A10_v1.2[.1] _opencl_batch.sh.oxxxxxx

xxxxxxx is a unique job ID. The .exxxxxx file is the error log and the .oxxxxxx file is the terminal log where success or failure of the commands can be determined.

<br/>

## 5&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Document Revision History

List the revision history for the application note.

| Name             | Date      | Changes                                      |
| ---------------- | --------- | -------------------------------------------- |
| Larry Landis     | 4/2/2020  | Initial Release                              |
| Larry Landis     | 4/28/2020 | Added sign_aocx.sh for v1.2.1                |
| Larry Landis     | 5/8/2020  | ./bin/host -emulator argument for v1.2.1     |
| Damaris Renteria | 5/29/2020 | Added batch script                           |
| Larry Landis     | 8/5/2020  | Misc edits per Ruben feedback                |
| Larry Landis     | 4/6/2021  | Remove 1.2 commands as we only support 1.2.1 |





