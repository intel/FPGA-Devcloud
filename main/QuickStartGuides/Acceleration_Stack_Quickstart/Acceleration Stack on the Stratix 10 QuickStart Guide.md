

# Acceleration Stack on the Stratix 10 QuickStart Guide

 

## 1       Introduction

This lab is a QuickStart reference on using the acceleration stack with the Stratix 10 on the Intel Devcloud. The Devcloud is equipped with multiple acceleration cards, that users can use by logging into the Devcloud and running the commands inside this QuickStart guide.



## 2       Assumptions

This lab assumes the following:

- Prior FPGA knowledge
- Prior terminal command knowledge
- Intel Devcloud registration and SSH key set up
- MobaXterm installed and set up

If any of the above assumptions are incorrect, please refer to the relevant set up guides



## 3       Requirements

#### 3.1            Hardware Requirements

When logged in to the head node, you must log into the correct compute node to use the Stratix 10 Acceleration cards. The nodes that allow Stratix 10 usage thus far is node 189. Please assure you are in the correct node if you encounter any issues.

There is only a certain amount of acceleration cards per compute node, so if one node is full, please use another node, or wait for the current job on the node to be completed. 

#### 3.2            Software Requirements

Please make sure you have all relevant software set up including MobaXterm and have successfully been able to login to a compute node. This QuickStart guide is terminal command heavy, so if you do not understand what a terminal command does, please refer to a prior guide, or look at the “man” page for that specific terminal 



## 4       Walkthrough

#### 4.1            Initial Setup

The first step is locating the environment setup script, and the folder containing the demo of the acceleration card in use. We will be running the script, and copying the folder containing the demo to a more workable directory.

- Open MobaXterm, and login to the appropriate compute node. In this case choose the Stratix 10 PAC Card programming.

- To run the environment setup script, we are going to source the file.

- Type into the terminal:

  ```bash
  source /opt/intel/inteldevstack/init_env.sh
  ```

  This will set up the environment variables we need.

- Next we will look for the folder containing the demo. Type into the terminal:

  ```bash
  cd /opt/intel/inteldevstack/d5005_ias_2_0_b339/hw/samples
  ```

  This folder contains multiple examples. In this case we will be using the example **hello_intr_afu**.

- We will make a directory in our root folder called **DEMO**. To do this type into the terminal:

  ```bash
  mkdir ~/DEMO
  ```

- We will then copy the example folder into this DEMO folder. Type this into the terminal:

  ```bash
  cp -r hello_intr_afu ~/DEMO
  ```

- We will then move into that folder and begin working inside the folder. First we move into the bin folder. To do this type into the terminal:

  ```bash
  cd ~/DEMO/hello_intr_afu/bin
  ```

#### 4.2            Running the Program

The example folder has been copied into the DEMO folder, allowing us a more workable directory. Inside this folder, we will be looking for an available acceleration card, programming it, and running the software program to display into the terminal.

- To see what pci accelerator cards are available we type the following into the terminal:

  ```bash
  lspci | grep accel
  ```

- We will then run the code onto the acceleration card, in this case we are running it on acceleration card **0x3b** using the following command:

  ```bash
  fpgaconf -B 0x3b hello_intr_afu.gbs
  ```

- We then need to run the code to display onto the terminal screen our final design. To do this we need to first switch directories into the software folder. Do this by typing into the terminal:

  ```bash
  cd ../sw
  ```

- We then need to **make clean** to remove old files and start fresh. And make the code to build the program.

  ```bash
  make clean
  ```

  ```bash
  make
  ```

- To run the final program, we jut run the script

  ```bash
  ./hello_intr_afu
  ```

If successful you should get an output like below. It should show **success**.



Figure 1: Successful Acceleration Card Programming

   

## 6       Document Revision History

List the revision history for the application note.

| Name        | Date      | Changes                                               |
| ----------- | --------- | ----------------------------------------------------- |
| Rony Schutz | 11/4/2019 | Initial Release of Acceleration Card QuickStart Guide |

 