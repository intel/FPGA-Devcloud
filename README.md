# Public Devcloud Access Instructions

Last updated: 10/28/2019 8:45AM- [Public Devcloud Access Instructions](#public-devcloud-access-instructions)
  * [1.0 Introduction](#10-introduction)
  * [2.0 Getting an Account](#20-getting-an-account)
  * [3.0 Access from your PC using Putty](#30-access-from-your-pc-using-putty)
  * [4.0 Access from your PC via MobaXterm or from Linux Terminal](#40-access-from-your-pc-via-mobaxterm-or-from-linux-terminal)
    + [4.1 Install MobaXterm](#41-install-mobaxterm)
    + [4.2 Open Local Terminal](#42-open-local-terminal)
    + [4.3 Downloading an SSH key](#43-downloading-an-ssh-key)
  * [5.0 Access to the Devcloud from within the Intel firewall](#50-access-to-the-devcloud-from-within-the-intel-firewall)
    + [5.1 Add SOcket CAT Package](#51-add-socket-cat-package)
    + [5.2  Preparing Configuration file](#52--preparing-configuration-file)
    + [5.3 Add Tunnel for Display](#53-add-tunnel-for-display)
  * [6.0 Accessing high powered servers running FPGA development software](#60-accessing-high-powered-servers-running-fpga-development-software)
    + [6.1 Understanding available resources](#61-understanding-available-resources)
  * [7.0 Loading and launching X2Go](#70-loading-and-launching-x2go)
  * [8.0 Quartus Access and Setup](#80-quartus-access-and-setup)
  * [9.0 Transferring Files to the Devcloud](#90-transferring-files-to-the-devcloud)
    + [9.1 Transferring Files to the Devcloud with SCP](#91-transferring-files-to-the-devcloud-with-scp)
    + [9.2 Using MobaXterm to Transfer Files](#92-using-mobaxterm-to-transfer-files)
    + [9.3 Using WinSCP to Transfer Files](#93-using-winscp-to-transfer-files)
  * [10.0 Job Control on the X2GO Window](#100-job-control-on-the-x2go-window)
    + [10.1 Searching for Free Nodes](#101-searching-for-free-nodes)
    + [10.2 Submitting Jobs for a Specified Walltime](#102-submitting-jobs-for-a-specified-walltime)
    + [10.3 Report Status for Jobs Running on the Devcloud](#103-report-status-for-jobs-running-on-the-devcloud)
    + [10.4 Deleting Jobs on the Devcloud](#104-deleting-jobs-on-the-devcloud)
  * [11.0 Launching Quartus](#110-launching-quartus)
  * [12.0 Launching the HLS compiler](#120-launching-the-hls-compiler)
  * [13.0 Launching the OpenCL compiler](#130-launching-the-opencl-compiler)
  * [14.0 Communicating to the PAC card](#140-communicating-to-the-pac-card)
  * [15.0 Downloading an .sof to the Devcloud connected DE10-Lite Board](#150-downloading-an-sof-to-the-devcloud-connected-de10-lite-board)
  * [16.0 Compiling on the Devcloud and Downloading to a Local PC connected DE10-Lite board](#160-compiling-on-the-devcloud-and-downloading-to-a-local-pc-connected-de10-lite-board)
    + [16.1 Setting up USB Tunneling from Devcloud to Local PC USB Blaster](#161-setting-up-usb-tunneling-from-devcloud-to-local-pc-usb-blaster)
    + [16.2 Programming a Design from the Devcloud to a Local PC Connected FPGA](#162-programming-a-design-from-the-devcloud-to-a-local-pc-connected-fpga)
  * [17.0 Timeouts and Disk Space](#170-timeouts-and-disk-space)
  * [18.0 Revision Table](#180-revision-table)




## 1.0 Introduction

Welcome to the FPGA Devcloud. This cloud is an Intel hosted cloud service with Intel XEON processors and FPGA acceleration cards. The FPGA Cloud has a number of development tools installed including Jupyter notebook, and Quartus Prime Lite / Prime Pro development tools. The FPGA Cloud hosts high end FPGA accelerator cards to allow users to experiment with accelerated workloads running on FPGAs.

**Assumptions on cloud access:** This user guide assumes you have a basic understanding of the UNIX operating system and can use an editor such as vi or emacs. The guide assumes you know what Quartus development tools are. You don't necessarily need to be an expert on the Quartus toolset to follow these instructions. Once up and running on the FPGA Cloud you will be able to learn more about Quartus FPGA development flows.

This process, while not difficult, it will take time to execute through all the steps. Please allow at least 60-90 mins of time to complete this process. To allow you to move through quicker, our suggestion is to print out these instructions for ease of reference. Note that in several sections of this document, the instructions differ whether you are inside the Intel firewall, or outside. Please be cognizant of whether you are logging in from within Intel or outside Intel and the appropriate instruction method to use.

## 2.0 Getting an Account

**To get account access, please go to this link: **

**https://software.intel.com/en-us/devcloud/FPGA/sign-up**

Please use this cloud website landing page to submit a request to access the FPGA Cloud.

Once signed up,  look for an email from Intel AI devcloud which can take **24 to 48 hrs** to respond.  Info for all configuration and license acquisition methods are in the instruction link provided. This is an example of the resulting email which will be sent to you:

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

1. [From a PC using Putty](#30-access-from-your-pc-using-putty)
2. [From a PC using Mobaxterm (which mimics the behavior of Linux)](#40-access-from-your-pc-via-mobaxterm-or-from-linux-terminal)
3. From a Linux console (either a native Linux machine or client Linux machine)



## 3.0 Access from your PC using Putty

This is a work in progress and not documented yet.



## 4.0 Access from your PC via MobaXterm or from Linux Terminal

**MobaXterm** is an enhanced terminal for Windows with an X11 server, a tabbed SSH client and several other network tools for remote computing (VNC, RDP, telnet, rlogin). **MobaXterm** brings all the essential Unix commands to Windows desktop, in a single portable exe file which works out of the box. It makes your Windows PC look like a UNIX environment. If you are already running a native Linux or client running Linux, you don't need to load Mobaxterm.

### 4.1 Install MobaXterm

1. Download the MobaXterm free edition: https://mobaxterm.mobatek.net/download-home-edition.html Note: get the installer edition, not the portable edition. (The installer edition will enable you to save login profiles.) . Download zipfile, open it and click on the msi file to install Mobaxterm.

   ![mobaxterm_edition](https://user-images.githubusercontent.com/56968566/67715527-3fee6500-f987-11e9-8961-6c0a38163bfc.png)

### 4.2 Open Local Terminal 

1. Launch MobaXterm using the installer. You should see the following:

![mobaxterm_window](https://user-images.githubusercontent.com/56968566/67715801-c5721500-f987-11e9-95e0-bdf9f76b7f43.png)

2. Left click: **"Start local terminal"**. Within this console you can see your local PC based files using standard Linux operating system commands (ls, cd, vi and etc.). 

   If you are on the Intel network and can't login, be sure to disable your VPN and use connectivity outside Intel's firewall (for example using Employee Hotspot at an Intel campus). The welcome email link will only work outside of Intel firewall. Separate instructions for login inside the Intel firewall are below. Navigate around with cd (change directory) and ls (list) you will recognize your Windows folders and files accessible through a UNIX interface. 
   
   Return to home by typing cd.

![mobaxterm_terminal](https://user-images.githubusercontent.com/56968566/67715875-e76b9780-f987-11e9-9c4a-9eb48fb06915.png)

### 4.3 Downloading an SSH key

**For the MobaXterm flow, native LINUX flow or macOS, click on the link Linux or macOS and follow the steps as stated in the welcome email.**

To start the process:

1. Click on the first link in the welcome email (might need to use an incognito window if you have issues launching or clear cookies).
2.  If you are a first time user, you will see a "Terms and Conditions" page come up. Please click "accept" on the T&C's to proceed.
3. You will then come to a new screen asking to select "Learn" or "Connect", please select "Connect".
4. The following page will then be displayed. Click on “Linux* or MAC OS” under the "Connect with a Terminal" button.

![ssh_key_access](https://user-images.githubusercontent.com/56968566/67715899-f3eff000-f987-11e9-9b1c-5ad2ba2a96ea.png)

6. After clicking “**SSH key for Linux/macOS**”, you will get instructions on accessing a UNIX key file. 

7. Click the button "SSH Key for Linux/macOS."

8. In your mobaxterm terminal, check if you have a .ssh directory. cd; ls -a; Look for the .ssh directory. If it doesn't exist, mkdir .ssh; Copy the devcloud-access-key to your .ssh directory: 

   For example: ![preparation](https://user-images.githubusercontent.com/56968566/67715925-01a57580-f988-11e9-8d12-4d73dc29c9de.png)


Should mobaxterm fail to launch after working for a period of time, we have seen a few cases requiring a reinstall. Prior to removal and re-install, copy the folder Mobaxterm from your Documents directory to a new name. Under the directory Mobaxterm/home you will have the .ssh folder and .bashrc file. Reinstall Mobaxterm and copy these files over to the new install if you have customized these files.

<u>**If you are within the Intel firewall, skip the following section and continue to "5.0 Access to the devcloud from within the Intel firewall.**</u>

![connection](https://user-images.githubusercontent.com/56968566/67715963-14b84580-f988-11e9-9a8e-9d81c32abccf.png)
![transferring_files](https://user-images.githubusercontent.com/56968566/67715967-16820900-f988-11e9-9319-e409e893b81e.png)

Note that in the above instructions, if you don't have a .ssh folder, type 

```
mkdir ~/.ssh 
```

UNIX will not show the hidden .ssh folder leading dot folder naming with the standard ls command, you will need to type ls -a.

After typing ssh c009, continue to follow these instructions:

## 5.0 Access to the Devcloud from within the Intel firewall

### 5.1 Add SOcket CAT Package

1. You will need to modify your Mobaxterm setup. Go to the packages icon and left-click.

   ![packages_icon](https://user-images.githubusercontent.com/56968566/67716101-6234b280-f988-11e9-972a-7c13370e1adc.png)

   Your next step you will see the MobApt package manager for MobaXterm:

   ![socat](https://user-images.githubusercontent.com/56968566/67716113-6b258400-f988-11e9-828a-83c74b051b91.png)

3. Install the **socat package**. This will take approximately 9 minutes to install.

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

![step1](https://user-images.githubusercontent.com/56968566/67716160-885a5280-f988-11e9-8e8e-bee5b0bf2a21.png)

### 5.3 Add Tunnel for Display

1. Refer to section 6 of the instructions to login to a high power compute node. Then return to this section.
2. ***Note: n137 can be replaced with other available nodes. Adjust names and paths according to your own setup.*** Open a second tab on Mobaxterm and type:

```
ssh -L 4002:s001-n137:22 colfax-intel
```

![step2](https://user-images.githubusercontent.com/56968566/67716181-9314e780-f988-11e9-9bb3-2954946864c0.png)

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
pbsnodes -l free 	# lists all free nodes (only nodes 130-139 run x2go)
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

Grab the **MS Windows version** – click where the cursor is in the screenshot below <u>**(mswin)**</u>:

![launching_x2go](https://user-images.githubusercontent.com/56968566/67716221-a6c04e00-f988-11e9-97a6-bae636d8732b.png)

Go through the install steps for the mswin X2Go Client and accept all.

On your MobaXterm window, open a second session tab by clicking on the "+" as shown below:![extra_tab](https://user-images.githubusercontent.com/56968566/67716260-b2ac1000-f988-11e9-8e44-945391aa8555.png)

This tab will a launch terminal running UNIX commands on your local machine.

To open the port for graphics usage, in the new terminal with your PC host name prompt type. Note that you will need to match or replace the hostname n137 listed below with the machine name that was allocated to you. If you are on the Intel firewall, replace c009 with colfax-intel.

![graphics_usage](https://user-images.githubusercontent.com/56968566/67716435-0a4a7b80-f989-11e9-82bd-456aec75cb6b.png)

Launch the x2go application on your PC. Set up the new session with the following settings substituting the Login field <uxxxx> with your own assigned user name and the path to the RSA/DSA key for ssh connection. Note this is the same key referenced for Mobaxterm connection that enables ssh c009.

![x2go_session_preferences](https://user-images.githubusercontent.com/56968566/67716674-8218a600-f989-11e9-8303-2dffc22f09b5.png)

The input/output screen has a setting for the display size which can be adjusted depending on your screen size. If you desire a different screen size adjust the parameters on this panel accordingly.![x2go_session_size](https://user-images.githubusercontent.com/56968566/67716702-8c3aa480-f989-11e9-9575-d28c218bc225.png)

To launch the application, hit **OK** to save the settings and then click on the puffy icon New session to launch a graphics session.

![x2go_launch_puffy](https://user-images.githubusercontent.com/56968566/67716724-95c40c80-f989-11e9-94a8-8b1029e5e70f.png)

After a minute or so, you should see the X2GO screen, be patient. While waiting for X2GO to launch you will see a screen that looks like this:

![x2go_loading](https://user-images.githubusercontent.com/56968566/67716770-a5435580-f989-11e9-987a-07b0ff0f3808.png)

You might get the following message If you previously logged into a different machine:

![host_key_verification_terminate](https://user-images.githubusercontent.com/56968566/67716812-b55b3500-f989-11e9-8c60-9c0eaaee2172.png)

Enter **No**

![host_key_verification_update](https://user-images.githubusercontent.com/56968566/67716830-bee49d00-f989-11e9-86b4-5aee8f792b5e.png)

Then another dialog box will appear, enter **Yes**,

You will see a window that looks like the following.

![x2go_desktop](https://user-images.githubusercontent.com/56968566/67716843-c60bab00-f989-11e9-9d99-2fbbdcfce6d9.png)

Should X2GO fail to launch, check that you ran the tunneling command on Mobaxterm on your local host. Make sure that the firewall is turned off per steps described above.

Upon gaining access to the windowing system,  right click within in the desktop and select “Open Terminal Here”.

![open_terminal](https://user-images.githubusercontent.com/56968566/67716892-dfacf280-f989-11e9-9d36-6e6c895c363e.png)

Your GUI ready environment should  be similar to the following image:![x2go_terminal_window](https://user-images.githubusercontent.com/56968566/67716915-efc4d200-f989-11e9-93ee-1726923a0a93.png)

To change the font sizing of the Desktop files in **Desktop Settings** under the **Icons** tab. Select “**Use custom font size**” and change it to 5 or to your font size preference.

<img src="https://user-images.githubusercontent.com/56968566/67716947-03703880-f98a-11e9-9b5f-e3b2b7eb79ad.png" alt="x2go_change_font" style="zoom: 80%;" />![x2go_fontsize](https://user-images.githubusercontent.com/56968566/67717026-27cc1500-f98a-11e9-9b01-f98c9a1a2d83.png)

## 8.0 Quartus Access and Setup

From a terminal that is logged in to the devcloud, type the following: 

```
cp /glob/development-tools/versions/intelFPGA_lite/quartus_setup.sh ~
```

This setup script has everything you need to setup environment variables and paths to the Intel FPGA development tools. There are some variables that need to be edited inside the script to give you access to either Quartus Prime Pro or Quartus Prime Lite, HLS, OpenCL, or Acceleration Stack.

Set those variables according to you desired setup, and source quartus_setup.sh (note: ~/quartus_setup.sh as an executable does not work, you must source this file) . Feel free to adjust your .bashrc and other associated scripts to source quartus_setup.sh inside those startup scripts. **Append the "source ~/quartus_setup.sh" command to the end of the .bashrc file.** 

If the Quartus font appears too zoomed in, as shown below, complete the following:

Under the Tools tab on the Main Bar, select Options. In the General Category, select “Fonts” and change the text size to 6.

![quartus_options](https://user-images.githubusercontent.com/56968566/67717114-55b15980-f98a-11e9-857e-8c8f5d572d51.png)
![quartus_fontsize](https://user-images.githubusercontent.com/56968566/67717117-5649f000-f98a-11e9-92fe-2864e3d9b155.png)

## 9.0 Transferring Files to the Devcloud 

**There are three different ways to Tranfer Files to the DevCloud:** 

1. [From a Local PC to DevCloud Server in X2Go Terminal (9.1)](#91-transferring-files-to-the-devcloud-with-scp)
2. [MobaXterm User Session (9.2)](#92-Using-MobaXterm-to-Transfer-Files)
3. [WinSCP Application (9.3)](#93-Using-WinSCP-to-Transfer-Files)

### 9.1 Transferring Files to the Devcloud with SCP 

Refer to the login instructions welcome page on file transfer to/from c009. **Use the local terminal on your PC to transfer files. Note: If on Intel firewall, replace c009 with colfax-intel.**

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

### 9.2 Using MobaXterm to Transfer Files

MobaXterm can be used to transfer files to and from your local PC to the Devcloud server.

<u>**To setup this feature, make sure that you have completed all the steps to connect to the DevCloud.**</u>

1. In the main toolbar of MobaXterm, click the **Session** button. ![mobaxterm_new_session](https://user-images.githubusercontent.com/56968566/67717144-65c93900-f98a-11e9-870b-784e76806a7f.png)
2. Select **SSH**. ![mobaxterm_ssh](https://user-images.githubusercontent.com/56968566/67717168-6d88dd80-f98a-11e9-987a-3d226b109886.png)
3. Enter the following information:
   1. Remote host: **localhost**
   2. Specify username: **u<number>**
   3. Port: **4002**
      ![basic_ssh_settings](https://user-images.githubusercontent.com/56968566/67717191-7a0d3600-f98a-11e9-9326-0a25d0354e99.png)
4. Under **Advanced SSH settings** > Select **Use Private Key** and search for the private key you used when you setup your DevCloud log-in. 
5. Click **OK**. 
6. If a new tab does not open, double-click on the side window **localhost (u#)**
   ![localhost_user_session](https://user-images.githubusercontent.com/56968566/67717217-82657100-f98a-11e9-8e15-30a98a73741e.png)

The localhost user directory tool can be re-opened and closed as necessary to transfer files. Files can be transferred by dragging and dropping into the side-bar that displays the contents of the user saved in the DevCloud directory. 

![mobaxterm_filemanagment](https://user-images.githubusercontent.com/56968566/67717267-9b6e2200-f98a-11e9-8c2c-64e8376fd2da.png)



### 9.3 Using WinSCP to Transfer Files

Download WinSCP: https://winscp.net/eng/download.php

Click on the “Download WinSCP” Button and Install onto PC. Download with default setup: **Typical installation (recommended)** and **Commander User Interface Style**.

![winscp_download](https://user-images.githubusercontent.com/56968566/67717718-7ded8800-f98b-11e9-8bfa-ef0ea0d71070.png)



When you open WinSCP you should get a screen like this:

![winscp_open_window](https://user-images.githubusercontent.com/56968566/67717741-8a71e080-f98b-11e9-9ccb-ecc7ba91e9cf.png)

Click on the button “**Advanced…**”

![winscp_advanced](https://user-images.githubusercontent.com/56968566/67717752-8f369480-f98b-11e9-913e-965213997e4d.png)

Open the “**Authentication**” Tab under “**SSH**”

![authentication_ssh](https://user-images.githubusercontent.com/56968566/67717764-965da280-f98b-11e9-8623-3692b5509b8e.png)

Click on the **“…”** box top open a dialog box

![browse_for_sshkey](https://user-images.githubusercontent.com/56968566/67717776-9c538380-f98b-11e9-90a4-3cbf01043f88.png)

Navigate to where your devcloud access key is located. Select the options box on the bottom right that says, “Putty Private Key Files” and switch it to “All Files”. Select your devcloud key .txt file.

![putty_private_key_files](https://user-images.githubusercontent.com/56968566/67717790-a37a9180-f98b-11e9-8bed-4af4fbb5df50.png)

This new window should open asking if you would like to convert the SSH private key to PuTTY format. Press OK to this. Then press Save in the new window that opens. Then OK once more.

![convert-to-private-key](https://user-images.githubusercontent.com/56968566/67717841-bab97f00-f98b-11e9-8614-b2c897606bd5.png)

Press **OK** and return to the original screen.

![type-in-localhost-information](https://user-images.githubusercontent.com/56968566/67717855-be4d0600-f98b-11e9-97cc-ba3044551548.png)

Fill in the following information:

Host name: Type in “localhost”

Port number: Type in 4002

User name: Type in the user name that was assigned to you

![devcloud_information](https://user-images.githubusercontent.com/56968566/67717896-d3c23000-f98b-11e9-8a7a-3f3bc28a6223.png)

Press **Save** to save all the information you just inputted for next time, and then press **OK**

Press **Login**



Note: When re-using WinSCP to transfer files, re-open the application and **Login**. A new window will pop-up. Click **Update** and you should be able to access and transfer your DevCloud files on the server again. 



## 10.0 Job Control on the X2GO Window

This section provides information on how to terminate jobs on the DevCloud. 

### 10.1 Searching for Free Nodes

You might need to terminate jobs on the devcloud.  To see what nodes are tied up, from the headnode, type the following: 

```
psbnodes -s v-qsvr-fpga | grep -B 4 fpga
```

### 10.2 Submitting Jobs for a Specified Walltime

A user will be kicked off a node if they have been using it for longer than 6 hours. To submit a job with a specified walltime longer than 6 hours (for compilations longer than 6 hours), type the following after qsub-ing into a specified node:

```
qsub -l walltime=<insert-time> 'command/bash file to be executed'
qsub -l walltime=12:00:00 walltime.sh		# example of a file to be executed
-------------------------------= walltime.sh ------------------------------
# begin walltime.sh
sleep 11h											# sleep command equivalent to a quartus compilation file requiring 11 hours of compilation
													# alternatively, sleep 11h would be quartus_sh commands (i.e. quartus_sh --flow main.v) 	
echo job success > ~/Documents/walltime_log.txt		# exit sleep at 11:00:00, output "job success" to walltime_log.txt
```

### 10.3 Report Status for Jobs Running on the Devcloud

To report the status of your jobs running on the DevCloud is to type the following:

```
qstat -s batch@v-qsvr-fpga
qstat -u u30330 		#change the username according to your id	
qstat -f <job id> 		# 390965 is an example of a job id - (qstat -f 390965)
```

### 10.4 Deleting Jobs on the Devcloud

Jobs can be terminated with the following command: 

```
qdel -s batch@v-qsvr-fpga <job-id>
```

**This is not recommended** but it is a another technique to delete a job from the headnode. Type the following and look for the qsub commands:

```
ps -auxw 
```

Free up the node with the following command: 

```
kill <job-id>
```



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

Note when running the Acceleration Stack Commands that communicate with the PAC Card, you will need python 2 in your search path. When initially creating your account, the /etc/skel/.bash_profile file is copied from the headnode to your account. This file specifies python3 first in the path. Switch your ~/.bash_profile to select python2 in your path within this file.

**Another method to see available cards:**

```
lspci | grep accel
```

View the various available cards and select a free one.

![lspci_grep](https://user-images.githubusercontent.com/56968566/67717938-ee94a480-f98b-11e9-9209-5acf76a3ec9b.png)

**To download a green bit stream (.gbs):**

```
fpgaconf -B 0x3b hello.gbs
```

This link to the acceleration hub is an excellent resource for further information: https://www.intel.com/content/www/us/en/programmable/solutions/acceleration-hub/acceleration-stack.html .

## 15.0 Downloading an .sof to the Devcloud connected DE10-Lite Board

Node **n138** has a DE10-Lite development board connected to the USB port. Login to this machine and you will see a programmer connection USB Blaster 1-13 to the board. Note there is only one DE10-Lite on the network.![devcloud_to_local_board](https://user-images.githubusercontent.com/56968566/67718023-26035100-f98c-11e9-81b2-63e24a51ef3c.png)

If the USB Blaster is not configured, complete the following steps: 

- [ ] To download your completed FPGA design into the local device, connect the USB Blaster cable between your PC USB port and the USB Blaster port on your development kit. If you are not using the DE10-Lite, you may have to plug the kit into power using a wall adapter. Upon plugging in your device, you should see flashing LEDs and 7-segment displays counting in hexadecimal, or other lit up LEDs and 7-segments depending on previous projects that have been downloaded to the development kit. 

*<u>**Note: The lights and switches controlled on the DevCloud connected server kit cannot be controlled unless system console or another form of instrumentation is used.*</u>**

- [ ] To use the USB Blaster to program your device, you need to install the USB Blaster driver. To begin, open your Device Manager by hitting the Windows Key and typing Device Manager. Click the appropriate tile labeled Device Manager that appears.

- [ ] Navigate to the Other Devices section of the Device Manager and expand the section below. 

  ![device_manager](https://user-images.githubusercontent.com/56968566/67718301-be99d100-f98c-11e9-8e24-a04edfa7f1ea.png)

- [ ] Right click the USB Blaster device and select **Update Driver Software**.

- [ ] Choose to browse your computer for driver software and navigate to the path shown below.

  ![browse_driver_software](https://user-images.githubusercontent.com/56968566/67718364-da9d7280-f98c-11e9-9677-ed7d9a3a39b9.png)

- [ ] Click on **Next** and the driver for the USB Blaster should be installed.



## 16.0 Compiling on the Devcloud and Downloading to a Local PC connected DE10-Lite board

[16.1 Setting up USB Tunneling from Devcloud to Local PC USB Blaster](#161-setting-up-usb-tunneling-from-devcloud-to-local-pc-usb-blaster)

[16.2 Programming a Design from the Devcloud to a Local PC Connected FPGA](#162-programming-a-design-from-the-devcloud-to-a-local-pc-connected-fpga)

### 16.1 Setting up USB Tunneling from Devcloud to Local PC USB Blaster

- [ ] On your PC, launch the Quartus Programmer. Search **Programmer** in the File Explorer. 

  ![programmer](https://user-images.githubusercontent.com/56968566/67718453-01f43f80-f98d-11e9-9745-3f596993ced4.png)

- [ ] If you don’t have the Programmer on your PC, download it from this link: http://fpgasoftware.intel.com/18.1/?edition=lite&download_manager=dlm3&platform=windows

- [ ] Select **Additional Software** and download the **Quartus Prime Programmer** and **Tools**.

  ![download_programmer_intel](https://user-images.githubusercontent.com/56968566/67718603-55ff2400-f98d-11e9-9343-0e499609f487.png) 

- [ ] Follow the login prompts, download, and install the Programmer. 

- [ ] For Intel Employees within the Firewall, in the File Explorer Search window, search ''**Programmer**'', and select **Run as administrator**. For other users, you can open the Programmer (Quartus Prime 18.1) normally. 

  ![programmer](https://user-images.githubusercontent.com/56968566/67718645-64e5d680-f98d-11e9-9987-ea2d1ea6344c.png)

- [ ] Select **Yes** if a yellow window will pop-up asking if you to allow app changes from an unknown publisher. 

- [ ] The Programmer window should then pop-up.  

- [ ] Left click on **Hardware Setup…** and then select the **JTAG Settings** tab.

  ![download_programmer](https://user-images.githubusercontent.com/56968566/67718852-dde52e00-f98d-11e9-9c06-39ac5c61aa5d.png)![run_admin](https://user-images.githubusercontent.com/56968566/67718870-eccbe080-f98d-11e9-83b8-1a7738f3f018.png)

- [ ] Click on **Configure Local JTAG Server...**

- [ ] **Enable remote clients to connect to the local JTAG** server and **enter a password** in the prompt box and **<u>remember this password</u>**. It will be used to connect later.![hardware_setup](https://user-images.githubusercontent.com/56968566/67718930-0f5df980-f98e-11e9-92ce-21c5476c11b2.png)

- [ ] On your local PC terminal, type in the following command to tunnel from the DevCloud to your local USB: **Note: the last parameter points to the node 138. For server consistency, you need to adjust this to the node number you are currently using to connect to the Devcloud.**

  ```
  ssh -tR 13090:localhost:1309 colfax-intel "ssh -t -R 13090:localhost:13090 s001-n138"
  ```

- [ ] Ignore the messages: 

  ```
  stty: standard input: Inappropriate ioctl for device
  X11 forwarding request failed on channel 0
  ```

- [ ] On the X2Go app and Quartus Prime Lite window, launch the programmer by selecting **Tools** > **Programmer**. 

  ![configure_JTAG](https://user-images.githubusercontent.com/56968566/67718964-20a70600-f98e-11e9-99ac-d897ffa295cd.png)

- [ ] Left click on **Hardware Setup,** select the **JTAG Settings** tab, and **Add Server**.

  ![JTAG_password](https://user-images.githubusercontent.com/56968566/67718986-2a306e00-f98e-11e9-9d06-24ccc2173801.png)

- [ ] Enter in the following information: 

  Server name: **localhost:13090**

  Server password: (password you set up for your PC local JTAG server)

- [ ] Select **OK**, and you should see the localhost on the list of JTAG servers.

  ![add_server_JTAG](https://user-images.githubusercontent.com/56968566/67719028-3d433e00-f98e-11e9-8c3d-fcaf6cec4aba.png)

- [ ] Click on the **Hardware settings tab,** double click on the **localhost:13090**, and that should now be your selected USB blaster download connection. 

- [ ] Make sure localhost:13090 shows up as your currently selected hardware and that the connection status is OK.

  ### 16.2 Programming a Design from the Devcloud to a Local PC Connected FPGA

  - [ ] Select the .sof file to be downloaded to the FPGA. 
  
  - [ ] Click **OK** and click **Start**. The progress bar should show 100% (Successful) and turn green. If it fails the first time, click **Start** a second time. 
  
    ![100_succesful](https://user-images.githubusercontent.com/56968566/67719042-446a4c00-f98e-11e9-994f-2bcb55469fd0.png)



## 17.0 Timeouts and Disk Space

Your session will timeout after four hours since login. Batch submissions must complete within 24 hours or the job will terminated. Each user has access to 200 GB of disk space on the Devcloud.

If you find that you are kicked off the Devcloud due to short bursts of inactivity, this can be attributed to your PC display going to sleep. Complete the following steps to avoid session time-out:

1. In the Windows search bar, search "**Display settings**." 
2. Select in the side-bar **Power & Sleep**. 
3. Under **Screen**, change both settings to **Never**. 

## 18.0 Determining Memory Availability and CPU Count and Speed

Enter the following in a Devcloud Terminal to determine memory availability: 

```
dmesg | grep Memory
```

Enter the following in a Devcloud Terminal to determine CPU Count and Speed:

```
lscpu
```



## 19.0 Revision Table

| Rev  | Owner            | Date       | Notes                                                        |
| :--- | :--------------- | :--------- | :----------------------------------------------------------- |
| 1.0  | Larry Landis     | 4/30/2019  | Initial Release                                              |
| 1.1  | Larry Landis     | 6/4/2019   | Edits based on more info                                     |
| 1.2  | Ray Schouten     | 6/6/2019   | Added Host Key Verification Error messages                   |
| 1.3  | Ray Schouten     | 6/11/2019  | Added all screenshots and SCP command info                   |
| 1.4  | Larry Landis     | 6/12/2019  | Intro and some changes to query available machines           |
| 1.5  | Ray Schouten     | 6/13/2019  | Added more screenshots, corrected cmds, changed font to be clear |
| 1.6  | Terry Barrette   | 6/14/2019  | Updated Instructions with more compete steps and format      |
| 1.7  | Larry Landis     | 6/18/2019  | Add instructions for login within Intel firewall             |
| 1.8  | Ray Schouten     | 7/1/2019   | Change formats for consistency                               |
| 1.9  | Dustin Henderson | 8/19/2019  | Minor formatting changes                                     |
| 1.10 | Larry Landis     | 8/26/2019  | Details of compute nodes                                     |
| 1.11 | Larry Landis     | 9/4/2019   | Time and Space, python paths                                 |
| 1.12 | Larry Landis     | 9/12/2019  | Clarify Intel login versus outside firewall login            |
| 1.13 | Rony Schutz      | 10/1/2019  | Added WinSCP instructions to 9.1                             |
| 1.14 | Shawnna Cabanday | 10/2/2019  | Added X2GO Instructions on font size settings to 7.0 and Quartus Prime font size settings to 8.0 |
| 1.15 | Larry Landis     | 10/5/2019  | Find PCIe cards with lspci                                   |
| 1.16 | Shawnna Cabanday | 10/9/2019  | Added additional information in Section 9.1: WinSCP instructions |
| 1.17 | Shawnna Cabanday | 10/16/2019 | Added Section 9.2: MobaXterm SCP instructions, updated SCP command from PC to Devcloud, updating qsub job control information, added table of contents, updated .bashrc sourcing information |
| 1.18 | Shawnna Cabanday | 10/22/2019 | Updated USB blaster and tunneling sections, converted Intel Wiki Page to GitHub md file (Typora) |
