# Arria10 PAC: OpenCL Programming on the FPGA devcloud using Arria 10 Devstack version 1.2.1

 

## 1       Introduction

This lab is a Quick Start reference on using OpenCL on the Intel Devcloud. The Devcloud is equipped with multiple acceleration cards, that users can use by logging into the Devcloud and running the commands inside this Quick Start guide along with OpenCL.

If you are new to the Arria 10 PAC card, check out this quick start guide:

https://www.intel.com/content/www/us/en/programmable/documentation/iyu1522005567196.html



## 2       Assumptions

This lab assumes the following:

- Prior FPGA knowledge
- Prior terminal command knowledge
- Intel Devcloud registration and SSH key set up
- MobaXterm installed and set up, X2Go optional



## 3       Walkthrough

#### 3.1            Initial Setup

Run the devcloud_login function and connect to an Arria 10 capable node. This function is available in the script: /data/intel_fpga/devcloudLoginToolSetup.sh .

![image-20200316172635297](https://user-images.githubusercontent.com/59750149/77004891-17a6d900-691d-11ea-8b3f-433673cc4962.png)

Select option 1 or option 4 and connect to an Arria 10 ready compute node.



Once on this node, run tools_setup. Select the Arria 10 Development Stack + OpenCL option.

Make a directory in your root folder called OPENCL. To do this change directory to the appropriate location and type into the terminal:

```bash
mkdir DEMO
```

- We will then copy the example folder into this DEMO folder. Type this into the terminal:

  ```bash
  cp -r /opt/a10/inteldevstack/a10_gx_pac_ias_1_2_pv/opencl DEMO
  ```



#### 3.2            Running Emulation flow

We need to direct the OpenCL Root to the correct root. To do this type into the terminal:

```bash
export ALTERAOCLSDKROOT=$INTELFPGAOCLSDKROOT/
```

Prior to running the emulation compile, first we need to unpack the project copied and then cd into the unpacked hello_world folder. Finally, create the bin folder, then run the compilation command.

- Now we unpack the the example by typing into the terminal:

  ```bash
  tar xf ../exm_opencl_hello_world_x64_linux.tgz
  ```

- Now we move into the unpacked hello_world example.

  ```bash
  cd hello_world
  ```

- Now we build bin folder; used to save emulation compile output file.

  ```bash
  make
  ```

* Run the emulation compile command by executing the following:

  ```bash
  aoc -march=emulator -v device/hello_world.cl -o bin/hello_world.aocx
  ```

To run the emulation flow:

```bash
env CL_CONTEXT_EMULATOR_DEVICE_INTELFPGA=1 bin/host
```

To run the compilation flow:

```bash
aoc --list-boards
aoc -v --board pac_a10 device/hello_world.cl -o bin/hello_world.aocx
```

Note this can run on a A10 machine or compile only machine.



#### 3.3            Running a Hello World Sample

Now that the environment variables and paths have been set up, we can now run a sample and begin to utilize OpenCL. 

- First lets cd into bin and run:

  ```
  cd bin;aocl diagnose
  ```

  Note this can only be  run exclusively on an A10 PAC enabled machine.

- Then we can start running the example. To load the kernel onto the device run the following in the terminal:

  ```bash
  aocl program acl0 hello_world.aocx
  ```

- Check if everything is good on that card

  ```bash
  aocl diagnose ac10
  ```

- To run the hello_world OpenCL host code example on the CPU that interacts with the OpenCL kernel we type the following:

  ```bash
  ./host
  ```

  

   

## 4       Document Revision History

List the revision history for the application note.

| Name        | Date       | Changes                                    |
| ----------- | ---------- | ------------------------------------------ |
| Rony Schutz | 01/29/2020 | Initial Release of OpenCL Quickstart Guide |
|             | 3/24/2020  |                                            |

 