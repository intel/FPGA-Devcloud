

# Arria 10 PAC: RTL AFU Compilation and Programming on the FPGA devcloud using Arria 10 Devstack version 1.2

 

## 1       Introduction

If you are new to the Arria 10 PAC card, check out this quick start guide:

https://www.intel.com/content/www/us/en/programmable/documentation/iyu1522005567196.html

The best resource for learning about the RTL and driver functionality is from this document: 

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



## 2       Assumptions

This lab assumes the following:

- Basic FPGA knowledge
- Intel Devcloud registration and SSH key set up
- MobaXterm installed and set up, X2Go optional



## 3       Walkthrough

#### 3.1            Initial Setup

Run the devcloud_login function and connect to an Arria 10 capable node. This function is available in the script: /data/intel_fpga/devcloudLoginToolSetup.sh .

![image-20200316172635297](C:\Users\llandis\AppData\Roaming\Typora\typora-user-images\image-20200316172635297.png)

Select option 1 or option 4 and connect to an Arria 10 ready compute node.



Once on this node, run tools_setup. Select the Arria 10 Development Stack + OpenCL option.

Make a directory in your root folder called DMA_AFU. To do this change directory to the appropriate location and type into the terminal:

```bash
mkdir A10_RTL_AFU
```

- We will then copy the example folder into his DEMO folder. Type this into the terminal:

  ```bash
  cp -r $OPAE_PLATFORM_ROOT/hw/samples/dma_afu A10_RTL_AFU
  ```

#### 3.2 Compiling RTL code into an FPGA bitstream

Prior to compilation, you typically simulate your design. This is accomplished using the Modelsim-SE simulator which is not currently supported on the FPGA devcloud. Should you need to simulate the design, please export to your own enterprise.We will then cd into that folder and begin working inside the folder. First change directory into the bin folder. Then run the compilation command

```bash
cd A10_RTL_AFU/dma_afu
afu_synth_setup --source hw/rtl/filelist.txt build_synth
```

This step will take approximately 40 minutes to complete. Should you want to skip this step, you can skip, as the sample includes a precompiled "green bit stream" which is the FPGA programming file called bin/dma_afu.gbs .



#### 3.3 Downloading the bit stream into the PAC card

Next we will be looking for an available acceleration card, program it, compile the host C code and run the software program to display on the terminal.

- To see what PCI accelerator cards are available, we type the following into the terminal:

  ```bash
  lspci | grep accel
  ```

- We will then download the green bit stream on to the acceleration card, in this case we are running it on acceleration card **0x3b** using the following command for version 1.2 of the devstack tools. Do not use this command if you are accessing the 1.2.1 version of the Arria 10 devstack tools.

  ```bash
  fpgaconf -B 0x3b bin/dma_afu.gbs
  ```

- This step will take about 15 seconds. 

#### 3.4 Compiling the host software

- We then need to compile and run the C host code to display on to the terminal screen. This will demonstrate the interaction of CPU host and FPGA PAC card. To do this, we need to first switch directories into the software folder. Do this by typing into the terminal:

  ```bash
  cd sw
  ```

- We then need to **make clean** to remove old files and start fresh. And make the code to build the program.

  ```bash
  make clean
  ```

  ```bash
  make
  ```

- To run the host program, we launch the executable

  ```bash
  ./fpga_dma_test 0
  ```

If successful, you should see an output as shown below.

![image-20200316183648648](C:\Users\llandis\AppData\Roaming\Typora\typora-user-images\image-20200316183648648.png)

   

This last step can take up to 10 minutes to complete. If you go to the directory: $OPAE_PLATFORM_ROOT/hw/samples you will find other samples that you can try out using similar steps.

## 6       Document Revision History

List the revision history for the application note.

| Name         | Date      | Changes                                                   |
| ------------ | --------- | --------------------------------------------------------- |
| Rony Schutz  | 11/5/2019 | Initial Release of Acceleration   Card QuickStart Guide   |
| Larry Landis | 3/13/2020 | Changed to demo, and added specific devcloud instructions |
| Larry Landis | 3/16/2020 | Switched to using the dma_afu as it is better documented  |



 
