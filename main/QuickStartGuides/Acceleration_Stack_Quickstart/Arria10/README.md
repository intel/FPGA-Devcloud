

# Acceleration Stack on the Arria 10 Demonstration - programming the green bit stream (.gbs) into 

 

## 1       Introduction

The best resource for learning the acceleration stack applications is the Acceleration Hub Quickstart guide: https://www.intel.com/content/www/us/en/programmable/documentation/iyu1522005567196.html

Note that the sudo commands listed in the above guide will not work due to users not having access to root privilege to run sudo.

This demonstration will step the user through steps to load a .gbs (green bit stream) file to a PAC card and run the host code application that communicates between the CPU and Arria 10 PAC Card on the devcloud.



## 2       Assumptions

This lab assumes the following:

- Basic FPGA knowledge
- Prior terminal command knowledge
- Intel Devcloud registration and SSH key set up
- MobaXterm installed and set up, X2Go optional



## 3       Walkthrough

#### 3.1            Initial Setup

Run the devcloud_login script and connect to an Arria 10 capable node.

Once on this node, run tools_setup. Select the Arria 10 Development Stack + OpenCL option.

Make a directory in our root folder called **DEMO**. To do this type into the terminal:

```bash
mkdir ~/DEMO
```

- We will then copy the example folder into this DEMO folder. Type this into the terminal:

  ```bash
  cp -r $OPAE_PLATFORM_ROOT/hw/samples/hello_intr_afu ~/DEMO
  ```

- We will then move into that folder and begin working inside the folder. First change directory into the bin folder.

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

- This step will take about 15 seconds. We then need to run the code to display onto the terminal screen our final design. To do this we need to first switch directories into the software folder. Do this by typing into the terminal:

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

![image](https://user-images.githubusercontent.com/55601103/72095397-3e1d1800-32cd-11ea-8f63-3d1d70ac13a2.png)

Figure 1: Successful Acceleration Card Programming

   

## 6       Document Revision History

List the revision history for the application note.

| Name         | Date      | Changes                                                      |
| ------------ | --------- | ------------------------------------------------------------ |
| Rony Schutz  | 11/5/2019 | Initial Release of Acceleration   Card QuickStart Guide      |
| Larry Landis | 3/13/2020 | Changed to demo, and added some specific devcloud instructions |

 
