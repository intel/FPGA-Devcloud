# Arria10 PAC: OpenCL Programming on the FPGA devcloud using Arria 10 Devstack version 1.2

 

## 1       Introduction

This lab is a Quick Start reference on using OpenCL on the Intel Devcloud. The Devcloud is equipped with multiple acceleration cards, that users can use by logging into the Devcloud and running the commands inside this Quick Start guide along with OpenCL.

If you are new to the Arria 10 PAC card, check out this quick start guide:

https://www.intel.com/content/www/us/en/programmable/documentation/iyu1522005567196.html



## 2       Assumptions

This lab assumes the following:

- Prior FPGA knowledge
- Prior terminal command knowledge
- Intel Devcloud registration and SSH key set up
- MobaXterm installed and set up

If any of the above assumptions are incorrect, please refer to the relevant set up guides



## 3       Walkthrough

#### 3.1            Initial Setup

Run the devcloud_login function and connect to an Arria 10 capable node. This function is available in the script: /data/intel_fpga/devcloudLoginToolSetup.sh .

![image-20200316172635297](https://user-images.githubusercontent.com/59750149/77004891-17a6d900-691d-11ea-8b3f-433673cc4962.png)

Select option 1 or option 4 and connect to an Arria 10 ready compute node.



Once on this node, run tools_setup. Select the Arria 10 Development Stack + OpenCL option.

Make a directory in your root folder called ~~DMA_AFU~~. To do this change directory to the appropriate location and type into the terminal:

```bash
mkdir A10_RTL_AFU
```

- We will then copy the example folder into this DEMO folder. Type this into the terminal:

  ```bash
  cp -r $OPAE_PLATFORM_ROOT/hw/samples/dma_afu A10_RTL_AFU
  ```

The first step is locating the environment setup script, and the folder containing the demo of the acceleration card in use. We will be running the script, and copying the folder containing the demo to a more workable directory.

- Open MobaXterm, and login to the appropriate compute node. In this case choose the Arria 10 PAC Card programming.

- To run the environment setup script, we are going to source the files.

- First we initialize the initial environment script. Type into the terminal:

  ```bash
  source /opt/a10/intelrtestack/init_env.sh
  ```

- Then we source the quartus script to properly load the quartus software. Please make sure to update the script to allow for Quartus Pro and allow OpenCL. Type into the terminal:

  ```bash
  source ~/quartus_setup.sh
  ```

- To specify the correct board support package, we need to give the correct absolute path. Type into the terminal:

  ```bash
  AOCL_BOARD_PACKAGE_ROOT=/opt/a10/inteldevstack/a10_gx_pac_ias_1_2_pv/opencl/opencl_bsp
  ```

- We need to source the environment script for OpenCL. Type into the terminal:

  ```bash
  source $INTELFPGAOCLSDKROOT/init_opencl.sh
  ```

- We need to direct the OpenCL Root to the correct root. To do this type into the terminal:

  ```bash
  export ALTERAOCLSDKROOT=$INTELFPGAOCLSDKROOT/
  ```

  

#### 3.2            Running a Hello World Sample

Now that the environment variables and paths have been set up, we can now run a sample and begin to utilize OpenCL. 

- First lets copy the folder where the sample is stored into a better more workable spot. Type into the terminal:

  ```bash
  cp -r /opt/a10/inteldevstack/a10_gx_pac_ias_1_2_pv/opencl/ ~/DEMO/opencl/
  ```

- Then move into that folder by typing into the terminal:

  ```bash
  cd ~/DEMO/opencl/
  ```

- Then we can start running the example. To load the kernel onto the device run the following in the terminal:

  ```bash
  aocl program acl0 hello_world.aocx
  ```

- We then need to create a new directory to unpack the example into. Type into the terminal:

  ```bash
  mkdir exm_opencl_hello_world_x64_linux
  ```

- Then we move into that directory by typing the following command:

  ```bash
  cd exm_opencl_hello_world_x64_linux
  ```

- Now we unpack the the example by typing into the terminal:

  ```bash
  tar xf ../exm_opencl_hello_world_x64_linux.tgz
  ```

- Now we move into the unpacked hello_world example.

  ```bash
  cd hello_world
  ```

- Now we want to build the example.

  ```bash
  make
  ```

- Now we need to copy the aocx file into the bin folder. 

  ```bash
  cp ~/DEMO/opencl/hello_world.aocx ./bin/
  ```

- To run the hello_world OpenCL example we type the following:

  ```bash
  ./bin/host
  ```

  

   

## 4       Document Revision History

List the revision history for the application note.

| Name        | Date       | Changes                                    |
| ----------- | ---------- | ------------------------------------------ |
| Rony Schutz | 01/29/2020 | Initial Release of OpenCL Quickstart Guide |
|             | 3/24/2020  |                                            |

 