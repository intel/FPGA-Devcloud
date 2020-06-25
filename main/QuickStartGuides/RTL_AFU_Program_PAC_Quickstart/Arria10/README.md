

# Arria 10 PAC: RTL AFU Compilation and Programming on the FPGA devcloud using Arria 10 Devstack version 1.2 / 1.2.1

  <br/>

## 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Introduction

If you are new to the Arria 10 PAC card, check out this quick start guide:\
https://www.intel.com/content/www/us/en/programmable/documentation/iyu1522005567196.html

The best resource for learning about the RTL and driver functionality is from this document: \
https://www.intel.com/content/www/us/en/programmable/documentation/tmv1511227122034.html

The RTL function is a DMA engine that moves data between the host CPU and FPGA over the CCIP (cache coherent interface) .

This demonstration will step the user through the following steps:

1. Select appropriate compute node machine on the FPGA devcloud
2. Load the appropriate tools
3. Copy over the sample design
4. Compile the sample design - this runs the Quartus compiler "under the hood"
5. Download the FPGA bitstream to the PAC card
6. Compile the application software using the gcc C compiler
7. Run the application software on the host and show that the host and FPGA interact to solve heterogenous workloads.

 <br/>

## 2&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Assumptions

This lab assumes the following:

- Basic FPGA knowledge
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

Select the Arria 10 PAC Compilation and Programming - RTL AFU, OpenCL option.

Make a directory in your root folder called DMA_AFU. To do this change directory to the appropriate location and type into the terminal:

```bash
mkdir A10_RTL_AFU
```

We will then copy the example folder into this DEMO folder. Type this into the terminal:

```bash
cp -r $OPAE_PLATFORM_ROOT/hw/samples/dma_afu A10_RTL_AFU
```

#### 3.2 Compiling RTL code into an FPGA bitstream

Prior to compilation, you typically simulate your design. This is accomplished using the Modelsim-SE simulator which is not currently supported on the FPGA devcloud. Should you need to simulate the design, please export to your own enterprise.\
We will then first cd into the dma_afu folder and begin working inside this folder. Then change directory into the build_synth folder. Finally, run the compilation command.

```bash
cd A10_RTL_AFU/dma_afu
afu_synth_setup --source hw/rtl/filelist.txt build_synth
cd build_synth
$OPAE_PLATFORM_ROOT/bin/run.sh
```

This step will take approximately 40 minutes to complete. Should you want to skip this step, you can skip since the sample includes a precompiled "green bit stream," which is the FPGA programming file found in bin/dma_afu_unsigned.gbs .

For version **1.2.1 only**, you need to create the unsigned version of the .gbs file. If you use version 1.2, skip this next step.

#### 3.2.1 Converting the 1.2.1 .gbs file to an unsigned version

```
PACSign PR -t UPDATE -H openssl_manager -i dma_afu.gbs -o dma_afu_compile_unsigned.gbs
```

Because no root key or code signing key is provided, the script asks if you would like to create an unsigned bitstream, as shown below. Type Y to accept an unsigned bitstream.

No root key specified.  Generate unsigned bitstream? Y = yes, N = no: **Y**\
No CSK specified.  Generate unsigned bitstream? Y = yes, N = no: **Y**

#### 3.3 Downloading the bit stream into the PAC card

Next we will be looking for an available acceleration card, program it, compile the host C code and run the software program to display on the terminal.

To see what PCI accelerator cards are available, we type the following into the terminal:

```bash
lspci | grep accel
```

We will then download the green bit stream on to the acceleration card, in this case we are running it on acceleration card **0x3b** using the following command for version 1.2 of the devstack tools. Do not use this command if you are accessing the 1.2.1 version of the Arria 10 devstack tools.\
Note if you did not compile your own gbs, then the precompiled gbs will be located in the bin directory ( ../bin/dma_afu.gbs ). 

For version 1.2:

```bash
fpgaconf -B 0x3b dma_afu.gbs
```

For version 1.2.1:

```
fpgasupdate dma_afu_compile_unsigned.gbs
```

Programming takes about 15 seconds.

#### 3.4 Compiling the host software

We then need to compile and run the C host code to display on to the terminal screen. This will demonstrate the interaction of CPU host and FPGA PAC card. To do this, we need to first switch directories into the software folder. Do this by typing into the terminal:

```bash
cd ../sw
```

We then need to **make clean** to remove old files and start fresh. And make the code to build the program.

```bash
make clean
```

```bash
make
```

To run the host program, we launch the executable

```bash
./fpga_dma_test 0
```

If successful, you should see an output as shown below.

![image-20200316183648648](https://user-images.githubusercontent.com/59750149/77005112-82f0ab00-691d-11ea-9334-52c6ab8414af.png)

 <br/>

This last step can take up to 10 minutes to complete. If you go to the directory: $OPAE_PLATFORM_ROOT/hw/samples you will find other samples that you can try out using similar steps.

 <br/>

## 4&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Batch Submission

The batch script attached above (in this case A10_v1.2[.1]_rtl_batch.sh) can be used to compile RTL code into an FPGA bitstream and then downloading the bit stream into the PAC card. **Adjust commands within the script to your own needs.**

From the headnode login-2, run one of the following two commands:

```
devcloud_login -b A10PAC 1.2 A10_v1.2_rtl_batch.sh
	or
devcloud_login -b A10PAC 1.2.1 A10_v1.2.1_rtl_batch.sh
```

To see the resulting terminal output, consult the files:

A10_v1.2[.1] _rtl_batch.sh.exxxxxx\
A10_v1.2[.1] _rtl_batch.sh.oxxxxxx

xxxxxxx is a unique job ID. The .exxxxxx file is the error log and the .oxxxxxx file is the terminal log where success or failure of the commands can be determined.

<br/>

## 5&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Document Revision History

List the revision history for the application note.

| Name             | Date      | Changes                                                   |
| ---------------- | --------- | --------------------------------------------------------- |
| Rony Schutz      | 11/5/2019 | Initial Release of Acceleration   Card QuickStart Guide   |
| Larry Landis     | 3/13/2020 | Changed to demo, and added specific devcloud instructions |
| Larry Landis     | 3/16/2020 | Switched to using the dma_afu as it is better documented  |
| Larry Landis     | 4/28/2020 | Add PACSign and fpgasupdate per v1.2.1 instructions       |
| Damaris Renteria | 6/8/2020  | Added Batch Script                                        |


