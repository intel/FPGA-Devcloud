

# Stratix 10 PAC: RTL AFU Compilation and Programming on the FPGA devcloud using the Stratix 10 Devstack version 2.0.1

 <br/>

## 1&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Introduction

If you have not used the D5005 Stratix 10  PAC card refer to this Quickstart Guide.\
https://www.intel.com/content/www/us/en/programmable/documentation/edj1542148561811.html#cxu1542149035471

The best resource for learning about the sample DMA RTL and driver functionality is from this document: \
https://www.intel.com/content/www/us/en/programmable/documentation/iwl1547157036746.html

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

Run the devcloud_login function and connect to an Stratix 10 capable node. This function is available in the script: /data/intel_fpga/devcloudLoginToolSetup.sh .

<img src="https://user-images.githubusercontent.com/59750149/83576210-129e0280-a4e6-11ea-8f32-46af9ff40a4d.png" alt="image" width=70% />

Select option 3 or option 5 and connect to a Stratix 10 ready compute node.

Once on this node, run tools_setup. 

```
tools_setup
```

Select the Stratix 10 PAC Compilation and Programming - RTL AFU, OpenCL option.

Make a directory in your root folder called DMA_AFU. To do this change directory to the appropriate location and type into the terminal:

```bash
mkdir S10_RTL_AFU
```

We will then copy the example folder into this DEMO folder. Type this into the terminal:

```bash
cp -r $OPAE_PLATFORM_ROOT/hw/samples/dma_afu S10_RTL_AFU
```

#### 3.2 Compiling RTL code into an FPGA bitstream

Prior to compilation, you typically simulate your design. This is accomplished using the Modelsim-SE simulator which is not currently supported on the FPGA devcloud. Should you need to simulate the design, please export to your own enterprise.\
We will then cd into the project folder and begin working inside the folder. Then, run the compilation command.

```bash
cd S10_RTL_AFU/dma_afu
afu_synth_setup --source hw/rtl/filelist.txt build_synth
cd build_synth
$OPAE_PLATFORM_ROOT/bin/run.sh
```

These steps will take approximately 60 minutes to complete. Should you want to skip this step, you can skip since the sample includes a precompiled "green bit stream," which is the FPGA programming file found in bin/dma_afu_unsigned.gbs .

#### 3.3 Downloading the green bit stream into the PAC card

Next we will be looking for an available acceleration card, program it, compile the host C code and run the software program to display on the terminal.

To see what PCI accelerator cards are available, we type the following into the terminal:

```bash
lspci | grep accel
```

We will then download the green bit stream on to the acceleration card, in this case we are running it on acceleration card **0x3b** using the following command for version 2.0.1 of the devstack tools. If you have a machine with only a single PAC card, the address can be left off.\
Note if you did not compile your own gbs, then the precompiled gbs will be located in the bin directory ( ../bin/dma_afu_unsigned.gbs ). 

```bash
fpgasupdate dma_afu.gbs 3b:00.0
```

This step will take about 15 seconds. 

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
./fpga_dma_test -s 104857600 -p 1048576 -r mtom
```

If successful, you should see an output as shown below.

![image-20200317153013460](https://user-images.githubusercontent.com/59750149/77005409-fb576c00-691d-11ea-9ac3-68ef69067bc1.png)

<br/>

This last step completes very quickly. If you go to the directory: $OPAE_PLATFORM_ROOT/hw/samples you will find other samples that you can try out using similar steps.

<br/>

## 4&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Batch Submission

The batch script attached above (in this case S10_rtl_batch.sh) can be used to compile RTL code into an FPGA bitstream and then downloading the bit stream into the PAC card. **Adjust commands within the script to your own needs.**

From the headnode login-2, run the following command:

```
devcloud_login -b S10PAC S10_rtl_batch.sh
```

To see the resulting terminal output, consult the files:

S10_rtl_batch.sh.exxxxxx\
S10_rtl_batch.sh.oxxxxxx

xxxxxxx is a unique job ID. The .exxxxxx file is the error log and the .oxxxxxx file is the terminal log where success or failure of the commands can be determined.

<br/>

## 5&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Document Revision History

List the revision history for the application note.

| Name             | Date      | Changes                                                   |
| ---------------- | --------- | --------------------------------------------------------- |
| Rony Schutz      | 11/5/2019 | Initial Release of Acceleration   Card QuickStart Guide   |
| Larry Landis     | 3/13/2020 | Changed to demo, and added specific devcloud instructions |
| Larry Landis     | 3/17/2020 | Fixed Stratix 10 specific steps                           |
| Larry Landis     | 4/1/2020  | New pic for devcloud_login, typos.                        |
| Damaris Renteria | 6/8/2020  | Added Batch script                                        |

