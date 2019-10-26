# Public Devcloud Access Instructions

[TOC]

## 1.0 Introduction

Welcome to the FPGA Cloud. This cloud is an Intel hosted cloud service with Intel XEON processors and FPGA acceleration cards. The FPGA Cloud has a number of development tools installed including Jupyter notebook, and Quartus Prime Lite / Prime Pro development tools. The FPGA Cloud hosts high end FPGA accelerator cards to allow users to experiment with accelerated workloads running on FPGAs.

**Assumptions on cloud access:** This user guide assumes you have a basic understanding of the UNIX operating system and can use an editor such as vi or emacs. The guide assumes you know what Quartus development tools are. You don't necessarily need to be an expert on the Quartus toolset to follow these instructions. Once up and running on the FPGA Cloud you will be able to learn more about Quartus FPGA development flows.

This process, while not difficult, it will take time to execute through all the steps. Please allow at least 60-90 mins of time to complete this process. To allow you to move through quicker, our suggestion is to print out these instructions for ease of reference. Note that in several sections of this document, the instructions differ whether you are inside the Intel firewall, or outside. Please be cognizant of whether you are logging in from within Intel or outside Intel and the appropriate instruction method to use.



## 2.0 Getting an Account

**To get account access, please go to this link: https://software.intel.com/en-us/devcloud/FPGA/sign-up**

Please use this cloud website landing page to submit a request to access the FPGA Cloud.

Once signed up,  look for an email from Intel AI devcloud which can take 24 to 48 hrs to respond.  Info for all configuration and license acquisition methods are in the instruction link provided. This is an example of the resulting email which will be sent to you:

```
Dear "user name",

Welcome to the Intel® AI Devcloud!

This computing resource is equipped with Intel processors and software optimized for Intel architecture for your high-performance computing and machine learning needs.

Please find the instructions to access the DevCloud at:

https://access.colfaxresearch.com/?uuid=2953c785-0ce5-40bd-8eda-86d6a80ab6ff

User name: u27224 - (you will be assigned a new User name)

Node name: c009 - (you will be assigned a new Node name)

Your account has been activated, and it will expire on May 20 2020 23:01:32 UTC. If you or your project requires an extended access to the DevCloud, please submit your project and relevant details to Intel DevMesh at https://devmesh.intel.com/. Once verified, your account will be extended an additional 90 days from the above expiration date. Please note that your account and data will be deleted on the expiration date, so transfer any data you wish to preserve before that date.

If you have technical questions about the Intel optimized frameworks and tools available in the DevCloud please post them to the Intel discussion forum at https://communities.intel.com/community/tech/intel-ai-academy

Sincerely,

Intel AI DevCloud Team
```





Once you have an account / email received you are ready to start the process to setup our account within the cloud.

There are different Methods of Terminal connections. There are a few options you can select in choosing which Terminal application tool you would like to use:

1. [From a PC using Putty](#access-from-your-pc-using-putty)
2. [From a PC using Mobaxterm (which mimics the behavior of Linux)](#access-from-your-pc-via-mobaxterm-or-from-linux-terminal) 
3. From a Linux console (either a native Linux machine or client Linux machine)



## 3.0 Access from your PC using Putty

This is a work in progress and not documented yet.



## 4.0 Access from your PC via MobaXterm or from Linux Terminal

**MobaXterm** is an enhanced terminal for Windows with an X11 server, a tabbed SSH client and several other network tools for remote computing (VNC, RDP, telnet, rlogin). **MobaXterm** brings all the essential Unix commands to Windows desktop, in a single portable exe file which works out of the box. It makes your Windows PC look like a UNIX environment. If you are already running a native Linux or client running Linux, you don't need to load Mobaxterm.

### 4.1 Install MobaXterm

1. Download the mobaxterm free edition: https://mobaxterm.mobatek.net/download-home-edition.html Note: get the installer edition, not the portable edition. (The installer edition will enable you to save login profiles.) . Download zipfile, open it and click on the msi file to install Mobaxterm.

   ![image2019-6-13_9-20-11](C:\Users\scabanda\Pictures\Camera Roll\image2019-6-13_9-20-11.png)

### 4.2 Open Local Terminal 

1. Launch MobaXterm using the installer. You should see the following:

![image2019-6-11_10-41-5](C:\Users\scabanda\Pictures\Camera Roll\image2019-6-11_10-41-5.png)

2. Left click: **"Start local terminal"**. Within this console you can see your local PC based files using standard Linux operating system commands (ls, cd, vi and etc.). 

   If you are on the Intel network and can't login, be sure to disable your VPN and use connectivity outside Intel's firewall (for example using Employee Hotspot at an Intel campus). The welcome email link will only work outside of Intel firewall. Separate instructions for login inside the Intel firewall are below. Navigate around with cd (change directory) and ls (list) you will recognize your Windows folders and files accessible through a UNIX interface. Return to home by typing cd.

![image2019-6-11_10-44-6](C:\Users\scabanda\Pictures\Camera Roll\image2019-6-11_10-44-6.png)

### 4.3 Downloading ssh key

**For the MobaXterm flow, native LINUX flow or macOS, click on the link Linux or macOS and follow the steps as stated in the welcome email.**

To start the process:

1. Click on the first link in the welcome email (might need to use an incognito window if you have issues launching or clear cookies).
2.  If you are a first time user, you will see a "Terms and Conditions" page come up. Please click "accept" on the T&C's to proceed.
3. You will then come to a new screen asking to select "Learn" or "Connect", please select "Connect".
4. The following page will then be displayed. Click on “Linux* or MAC OS” under the "Connect with a Terminal" button.

![image2019-6-11_10-25-59](C:\Users\scabanda\Pictures\Camera Roll\image2019-6-11_10-25-59.png)

6. After clicking “SSH key for Linux/macOS”, you will get instructions on accessing a UNIX key file. 

7. Click the button "SSH Key for Linux/macOS.

8. In your mobaxterm terminal, check if you have a .ssh directory. cd; ls -a; Look for the .ssh directory. If it doesn't exist, mkdir .ssh; Copy the devcloud-access-key to your .ssh directory: 

   For example: 

   <u>**If you are within the Intel firewall, skip the following section and resume called: Access to the devcloud from within the Intel firewall.**</u> 

![image2019-7-30_15-24-0](C:\Users\scabanda\Pictures\Camera Roll\image2019-7-30_15-24-0.png)

![image2019-7-30_15-21-4](C:\Users\scabanda\Pictures\Camera Roll\image2019-7-30_15-21-4.png)

![image2019-7-30_15-22-8](C:\Users\scabanda\Pictures\Camera Roll\image2019-7-30_15-22-8.png)

Note that in the above instructions, if you don't have a .ssh folder, type mkdir ~/.ssh . UNIX will not show the hidden .ssh folder leading dot folder naming with the standard ls command, you will need to type ls -a.

After typing ssh c009, continue to follow these instructions:

## 5.0 Access to the Devcloud from within the Intel firewall

### 5.1 Add socat package (SOcket CAT)

1. You will need to modify your Mobaxterm setup. Go to the packages icon and left-click.

   ![image2019-6-20_16-30-32](C:\Users\scabanda\Pictures\Camera Roll\image2019-6-20_16-30-32.png)

2. ![image2019-6-20_16-32-5](C:\Users\scabanda\Pictures\Camera Roll\image2019-6-20_16-32-5.png)

3. Install the socat package. This will take approximately 9 minutes to install.

### 5.2  Preparing Configuration file

1. Back in the LINUX (or Mobaxterm) initial screen, you will need to make additional entries into your config file:

```
Host colfax-intel-proxy
User guest
hostname cluster.colfaxresearch.com
IdentityFile ~/.ssh/colfax-access-key-27224
ProxyCommand socat STDIO SOCKS4:proxy-us.intel.com:%h:%p,socksport=1080

Host colfax-intel-proxy-shell colfax-intel
#replace with your own user name
User u27224 
hostname c009
IdentityFile ~/.ssh/colfax-access-key-27224
ProxyCommand ssh -T colfax-intel-proxy
```

2. At your local machine prompt type: 

```
ssh colfax-intel
```

You will now be logged in:

![image2019-6-20_16-40-32](C:\Users\scabanda\Pictures\Camera Roll\image2019-6-20_16-40-32.png)

### 5.3 Add Tunnel for Display

1. Refer to section 6 of the instructions to login to a high power compute node. Then return to this section.
2. Open a second tab on Mobaxterm and type:

```
ssh -L 4002:s001-n137:22 colfax-intel
```

*Note: n137 can be replaced with other available nodes. Adjust names and paths according to your own setup.* 

![image2019-6-20_16-48-50](C:\Users\scabanda\Pictures\Camera Roll\image2019-6-20_16-48-50.png)

3. Follow the instructions on step 6 to find available compute nodes and on to step 7 to gain access to X2Go and work in a graphics enabled environment.

## 6.0 Accessing high powered servers running FPGA development software

### 6.1 Understanding available resources

1. You will be logged in to machine called login-l (headnode). You cannot run compute jobs here. You need to run compute jobs on a powerful server.  

   The following nodes can run Quartus, OpenCL and HLS: n130-n139.

   In addition, the following nodes can run OPAE connectivity to PAC Cards: n137-n139.

   There are a total of 12 Arria 10 PAC Cards, 4 each on n137, n138 and n139. 

   To query if free nodes are available run the below command on the login server (headnode). The terminology that we will use is localnode (your PC), headnode (login node) and computenode. The computenode is a high power machine for running compilations - a subset host PAC cards: n137, n138 and n139. 

   ```
   pbsnodes -s v-qsvr-fpga | grep -B 4 fpga
   ```

You will get a listing of free and busy nodes that connect to PAC cards. 

```
pbsnodes -l free 
```

If there is a free node, when you execute this command you will be logged in to a new machine within a minute or so. If no machine is available you will be placed in a queue.

```
qsub -q batch@v-qsvr-fpga -I
```

To login to a specific machine:

```
qsub -q batch@v-qsvr-fpga -I -l nodes=s001-n137:ppn=2 (for 137 through 139)
qsub -l nodes=s001-n130:ppn=2 (for 130 through 136)
```

Once you have completed this step, you have a high power machine available for powerful computing jobs. You only have a console available but no graphics available. Note that mobaxterm has multiple tabs has three possibilities of where to be logged in: 

- Local Machine (eg. llandis-MOBL)
- devcloud login-l login server
- compute server (eg n137)

You need to be cognizant of which Mobaxterm tab and machine you are typing in so that you are aware of which commands you type in which Mobaxterm tab.

2. At this point you will want to run a PC based product called **X2Go client** that will allow you to have a Linux based GUI that allows multiple terminals and can run graphics programs such as Intel Quartus. In order to run GUI based applications such as Quartus and Modelsim, you will need to download an application on your PC called X2Go. X2Go is the remedy for slow graphics response from Mobaxterm running X11 or VNC windowing systems.

## 7.0 Loading and launching X2Go

To download X2Go, navigate to this link on your PC browser: https://wiki.x2go.org/doku.php/download:start

Grab the MS version – click where the cursor is in the screenshot below (mswin):

![image2019-6-11_11-36-33](C:\Users\scabanda\Pictures\Camera Roll\image2019-6-11_11-36-33.png)

Go through the install steps for the mswin X2Go Client.

On an Intel provided PC, to allow X2Go to work, you need to temporarily shut off the McAfee security firewall by following this step:

Prior to port remapping, go to the McAfee app which is this icon in the tray ![img](https://wiki.ith.intel.com/download/thumbnails/1307283437/image2019-6-11_11-37-49.png?version=1&modificationDate=1560278269953&api=v2) and Disable Endpoint Security Firewall. This step is unique to Intel supplied PCs.

![image2019-6-11_11-44-43](C:\Users\scabanda\Pictures\Camera Roll\image2019-6-11_11-44-43.png)

On your MobaXterm window, open a second session tab by clicking on the "+" as shown below:![img](https://wiki.ith.intel.com/download/attachments/1307283437/image2019-6-11_11-45-47.png?version=1&modificationDate=1560278748317&api=v2)

This tab will a launch terminal running UNIX commands on your local machine.

To open the port for graphics usage, in the new terminal with your PC host name prompt type. Note that you will need to match or replace the hostname n137 listed below with the machine name that was allocated to you. If you are on the Intel firewall, replace c009 with colfax-intel.

![image2019-6-18_22-51-22](C:\Users\scabanda\Pictures\Camera Roll\image2019-6-18_22-51-22.png)

Launch the x2go application on your PC. Set up the new session with the following settings substituting the Login field <uxxxx> with your own assigned user name and the path to the RSA/DSA key for ssh connection. Note this is the same key referenced for Mobaxterm connection that enables ssh c009.



![image2019-6-11_11-48-57](C:\Users\scabanda\Pictures\Camera Roll\image2019-6-11_11-48-57.png)

The input/output screen has a setting for the display size which can be adjusted depending on your screen size. If you desire a different screen size adjust the parameters on this panel accordingly.![image2019-6-11_11-50-46](C:\Users\scabanda\Pictures\Camera Roll\image2019-6-11_11-50-46.png)

To launch the application, hit **OK** to save the settings and then click on the puffy icon New session to launch a graphics session.

![image2019-6-11_11-55-25](C:\Users\scabanda\Pictures\Camera Roll\image2019-6-11_11-55-25.png)

After a minute or so, you should see the X2GO screen, be patient. While waiting for X2GO to launch you will see a screen that looks like this:

![image2019-6-12_23-29-25](C:\Users\scabanda\Pictures\Camera Roll\image2019-6-12_23-29-25.png)

You might get the following message If you previously logged into a different machine:

![image2019-6-11_14-21-28](C:\Users\scabanda\Pictures\Camera Roll\image2019-6-11_14-21-28.png)

Enter **No**

Then another dialog box will appear, enter **Yes**,

You will see a window that looks like the following.

![image2019-6-13_10-51-13](C:\Users\scabanda\Pictures\Camera Roll\image2019-6-13_10-51-13.png)

Should X2GO fail to launch, check that you ran the tunneling command on Mobaxterm on your local host. Make sure that the firewall is turned off per steps described above.

Upon gaining access to the windowing system,  right click within in the desktop and select “Open Terminal Here”.

![image2019-6-11_11-52-1](C:\Users\scabanda\Pictures\Camera Roll\image2019-6-11_11-52-1.png)

Your GUI ready environment should similar to the following image:![image2019-6-13_10-51-59](C:\Users\scabanda\Pictures\Camera Roll\image2019-6-13_10-51-59.png)

## 8.0 Quartus Access and Setup

From a terminal that is logged in to the devcloud, type cp /glob/development-tools/versions/intelFPGA_lite/quartus_setup.sh ~

This setup script has everything you need to setup environment variables and paths to the Intel FPGA development tools. There are some variables that need to be edited inside the script to give you access to either Quartus Prime Pro or Quartus Prime Lite, HLS, OpenCL, or Acceleration Stack.

Set those variables according to you desired setup, and source quartus_setup.sh (note: ~/quartus_setup.sh as an executable does not work, you must source this file) . Feel free to adjust your .bashrc and other associated scripts to source quartus_setup.sh inside those startup scripts.



## 9.0 Transfer Files to the Devcloud

Refer to the login instructions welcome page on file transfer to/from c009.

Transferring Files from your localnode terminal. Your prompt on mobaxterm would be of the form: /home/mobaxterm (localnode)

```
scp /path/to/local/file c009:/path/to/remote/directory
```

From headnode or computenode to the localnode. 

```
scp c009:/path/to/remote/file /path/to/local/directory
```

Here is an example:

```
scp /drives/c/User/llandis/Documents/file.txt c009:/home/u27224
```

*Note: If on the Intel firewall, replace **c009** with **colfax-intel**.*

## 10.0 Job Control on the X2GO Window

### 10.1 Searching for Free Nodes

You might need to terminate jobs on the devcloud.  To see what nodes are tied up, from the headnode, type the following: 

```
pbsnodes -s v-qsvr-fpga | grep -B 4 fpga
```

### 10.2 Report Status for Jobs Running on the Devcloud

Another technique is to type:

```
qstat -s batch@v-qsvr-fpga
```

This will report status of your jobs running on the devcloud. 

### 10.3 Deleting Jobs on the Devcloud

Jobs can be terminated with:

```
qdel  -s batch@v-qsvr-fpga <jobid>
```

Another technique is from the headnode, type 

```
ps -auxw 
```

and look for the qsub commands. Then use 

```
kill <job ID>
```

to free up the node, however this technique is not recommended.



## 11.0 Launching Quartus

The following command will launch the Quartus GUI: 

```
quartus &
```

The version you launch (Lite vs Pro) is dependent on the environment variables you set and sourced in the quartus_setup.sh script.

## 12.0 Launching the HLS compiler

If you specify HLS=:"TRUE" in the quartus_setup.sh setup script you will be able to access the HLS compiler, i++. The simplest test would be i++ hello_world.cpp .

## 13.0 Launching the OpenCL compiler

If you specify OPENCL=:"TRUE" in the tool setup script you will be able to access the OpenCL compiler, aoc. (Needs update for acceleration stack and connectivity to A10 PAC card)

## 14.0 Communicating to the PAC card 

To list all SYSFS entries in a multi-PAC system (explain)

```
ls -l /sys/class/fpga/intel-fpga-dev.?/device
```

To view serial number for a particular SYSFS entry (what does this mean)

```
hexdump -C /sys/class/fpga/intel-fpga-dev.2/intel-fpga-fme.2/intel-pac-hssi.?.auto/hssi_mgmt/eeprom
```

Note when running the Acceleration Stack Commands that communicate with the PAC Card, you will need python 2 in your search path. 

When initially creating your account, the /etc/skel/.bash_profile file is copied from the headnode to your account. This file specifies python3 first in the path. 

Switch your ~/.bash_profile to select python2 in your path within this file.

This link to the acceleration hub is an excellent resource for further information:

https://www.intel.com/content/www/us/en/programmable/solutions/acceleration-hub/acceleration-stack.html

## 15.0 Compiling on the Devcloud and Downloading to a Local DE10-Lite Board

Node n138 has a DE10-Lite development board connected to the USB port. Login to this machine and you will see a programmer connection USB Blaster 1-13 to the board. Note there is only one DE10-Lite on the network.![image2019-8-27_14-40-46](C:\Users\scabanda\Pictures\Camera Roll\image2019-8-27_14-40-46.png)

## **16.0 Timeouts / Disk Space**

Your session will timeout after four hours since login. Batch submissions must complete within 24 hours or the job will terminated. Each user has access to 200 GB of disk space on the Devcloud.