<img width="1000" alt="intel-fpga-devcloud" src="https://user-images.githubusercontent.com/56968566/68611681-86f05600-046f-11ea-8d12-f5259d60e7da.png">

<div align="center">
<strong>FPGA DESIGN DEVELOPMENT AND WORKLOADS FOR HARDWARE ACCELERATION</strong>
</div>
<div align="center">
 Develop programmable solutions and validate your workloads on leading FPGA hardware with tools optimized for Intel technology. Use this cloud solution in the classroom to support acceleration engineering curriculum. 
</div>


<div align="center">
  <h3>
    <a href="https://software.intel.com/en-us/devcloud/FPGA">
      Website
    </a>
    <span> | </span>
    <a href="https://github.com/intel/FPGA-Devcloud/tree/master/main/Devcloud_Access_Instructions#devcloud-access-instructions">
      Devcloud Access Instructions
    </a>
    <span> | </span>
    <a href="https://github.com/intel/FPGA-Devcloud/tree/master/main/QuickStartGuides#Contents">
      Quickstart Guides
    </a>
    <span> | </span>
    <!-- <a href="https://github.com/intel/FPGA-Devcloud/tree/master/main/FAQ#FAQ"> -->
    <!--   CLI -->
    <!-- </a> -->
    <!-- <span> | </span> -->
    <a href="https://github.com/intel/FPGA-Devcloud/tree/master/main/FAQ#faq">
      FAQ
    </a>
    <span> | </span>
    <a href="https://forums.intel.com/s/">
      Contact Us
    </a>
  </h3>
</div>
------

# Devcloud Access Instructions

[Devcloud Access Instructions](#devcloud-access-instructions)

* [1.0 Introduction](#10-introduction)

* [2.0 Getting an Account](#20-getting-an-account)
  
  + [Connection Methods](#connection-methods)
  
* [3.0 Access from your PC via MobaXterm or from Linux Terminal](#30-access-from-your-pc-via-mobaxterm-or-from-linux-terminal)
  + [3.1 Install MobaXterm](#31-install-mobaxterm)
  + [3.2 Open Local Terminal](#32-open-local-terminal)
  + [3.3 Downloading an SSH key](#33-downloading-an-ssh-key)
  
* [4.0 Connection to Devcloud](#40-connection-to-devcloud)
  + [Public User](#public-user)
  + [User Inside Intel Firewall](#user-inside-intel-firewall)
  + [4.1 Add SOcket CAT Package](#41-add-socket-cat-package)
  + [4.2  Preparing Configuration file for Intel firewall users](#42--preparing-configuration-file-for-intel-firewall-users)
  
* [5.0 Connecting to Servers Running FPGA Development Software](#50-connecting-to-servers-running-fpga-development-software)
  
  + [5.1 Understanding available resources](#51-understanding-available-resources)
  + [5.2 Login Script](#52-login-script)
  + [5.3 Development Tool Access and Setup](#53-development-tool-access-and-setup)
  + [5.4 Querying Device Availability](#54-querying-device-availability)
  
  * [5.5 Submitting Batch Jobs](#55-submitting-batch-jobs)
  * [5.6 Submitting Jobs for a Specified Walltime](#56-submitting-jobs-for-a-specified-walltime)
  * [5.7 Report Status for Jobs Running on the Devcloud](#57-report-status-for-jobs-running-on-the-devcloud)
  * [5.8 Deleting Jobs on the Devcloud](#58-deleting-jobs-on-the-devcloud)
  
* [6.0 Graphics Usage on the FPGA Devcloud](#60-graphics-usage-on-the-fpga-devcloud)

  + [6.1 Opening Port for Graphics Usage in X2Go](#61-opening-port-for-graphics-usage-in-x2go)

  + [6.2 Quartus Font Setup](#62-quartus-font-setup)

* [7.0 Transferring Files to and from the Devcloud](#70-transferring-files-to-and-from-the-devcloud)
  
  + [7.1 Transferring Files to and from the Devcloud with SCP](#71-transferring-files-to-and-from-the-devcloud-with-scp)
  + [7.2 Using MobaXterm to Transfer Files](#72-using-mobaxterm-to-transfer-files)
  + [7.3 Using WinSCP to Transfer Files](#73-using-winscp-to-transfer-files)
  + [7.4 Using MobaXterm Command Line to Transfer URLs (Github)](#74-using-mobaxterm-command-line-to-transfer-urls-github)
    + [1. WGET Command](#1-wget-command)
    + [2. CURL Command](#2-curl-command)
  
* [8.0 Launching Development Tools](#80-launching-development-tools)

* [9.0 Downloading an .sof to the Devcloud connected DE10-Lite Board](#90-downloading-an-sof-to-the-devcloud-connected-de10-lite-board)

* [10.0 Compiling on the Devcloud and Downloading to a Local PC connected DE10-Lite board](#100-compiling-on-the-devcloud-and-downloading-to-a-local-pc-connected-de10-lite-board)

  + [10.1 Setting up USB Tunneling from Devcloud to Local PC USB Blaster](#101-setting-up-usb-tunneling-from-devcloud-to-local-pc-usb-blaster)
  + [10.2 Programming a Design from the Devcloud to a Local PC Connected FPGA](#102-programming-a-design-from-the-devcloud-to-a-local-pc-connected-fpga)

* [11.0 Timeouts and Disk Space](#110-timeouts-and-disk-space)

* [12.0 Determining and Allocating Memory Availability and CPU Count and Speed](#120-determining-and-allocating-memory-availability-and-cpu-count-and-speed)

* [13.0 Devcloud Text Editors](#130-devcloud-text-editors)

* [14.0 Determining which version of the OS is running on a Node](#140-determining-which-version-of-the-os-is-running-on-a-node)



## 1.0 Introduction

Welcome to the FPGA Devcloud. This cloud is an Intel hosted cloud service with Intel XEON processors and FPGA acceleration cards. The FPGA Cloud has a number of development tools installed including Jupyter notebook, and Quartus Prime Lite / Prime Pro development tools. The FPGA Cloud hosts high end FPGA accelerator cards to allow users to experiment with accelerated workloads running on FPGAs.

**Note:** Please allow 60-90 mins to complete the entire setup. For ease of reference, it is recommended you print these instructions out. 

## 2.0 Getting an Account

If you already have a Devcloud account, click [here](#connection-methods) to skip to the next step. 

**Please use this cloud website landing page to submit a request to access the FPGA Cloud:**

**https://software.intel.com/en-us/devcloud/FPGA/sign-up**

Once signed up,  look for an email from Intel AI Devcloud which can take **24 to 48 hrs** to respond.  Info for all configuration and license acquisition methods are in the instruction link provided. This is an example of the resulting email which will be sent to you:

```
Dear "user name",

Welcome to the Intel® AI Devcloud!

This computing resource is equipped with Intel processors and software optimized for Intel architecture for your high-performance computing and machine learning needs.

Please find the instructions to access the DevCloud at:

https://access.colfaxresearch.com/?uuid=2953c785-0ce5-40bd-8eda-86d6a80ab6ff

User name: u12345 - (you will be assigned a new User name)

Node name: c009 - (you will be assigned a new Node name)

Your account has been activated, and it will expire on May 20 2020 23:01:32 UTC. If you or your project requires an extended access to the DevCloud, please submit your project and relevant details to Intel DevMesh at https://devmesh.intel.com/. Once verified, your account will be extended an additional 90 days from the above expiration date. Please note that your account and data will be deleted on the expiration date, so transfer any data you wish to preserve before that date.

If you have technical questions about the Intel optimized frameworks and tools available in the DevCloud please post them to the Intel discussion forum at https://communities.intel.com/community/tech/intel-ai-academy

Sincerely,

Intel AI DevCloud Team
```



### Connection Methods

Once you have an account / email received you are ready to start the process to setup your account within the cloud. 

There are different methods of terminal connections. Listed below are a few options you can select in choosing which Terminal application tool you would like to use:

1. [Windows with Mobaxterm (SSH client)](#30-access-from-your-pc-via-mobaxterm-or-from-linux-terminal) (recommended)
2. [Windows with Cygwin](https://devcloud.intel.com/datacenter/learn/connect-with-ssh-windows-cygwin/)
3. [Windows with PuTTy](https://devcloud.intel.com/datacenter/learn/connect-with-ssh-windows/)
4. [Linux or macOS (SSH client)](#30-access-from-your-pc-via-mobaxterm-or-from-linux-terminal)



## 3.0 Access from your PC via MobaXterm or from Linux Terminal

**MobaXterm** is an enhanced terminal for Windows with an X11 server, a tabbed SSH client and several other network tools for remote computing (VNC, RDP, telnet, rlogin). **MobaXterm** brings all the essential Unix commands to Windows desktop, in a single portable exe file which works out of the box and makes your Windows PC look like a UNIX environment. 

If you are already running a native Linux or client running Linux, you don't need to load MobaXterm. To skip  the MobaXterm installation process click [here](#33-downloading-an-ssh-key).

### 3.1 Install MobaXterm

1. Download the MobaXterm free edition: https://mobaxterm.mobatek.net/download-home-edition.html Note: Get the **installer edition**, not the portable edition. (The installer edition will enable you to save login profiles.) . Download zipfile, open it and click on the msi file to install Mobaxterm.

   ![mobaxterm_edition](https://user-images.githubusercontent.com/56968566/67715527-3fee6500-f987-11e9-8961-6c0a38163bfc.png)

### 3.2 Open Local Terminal 

1. Launch MobaXterm using the installer. You should see the following:

<img src="https://user-images.githubusercontent.com/56968566/67715801-c5721500-f987-11e9-95e0-bdf9f76b7f43.png" alt="mobaxterm_window" width=80% />

2. Click: **"Start local terminal"**. Within this console you can see your local PC based files using standard Linux operating system commands (ls, cd, vi and etc.). 

3. Navigate around with ```cd``` (change directory) and ```ls``` (list) you will recognize your Windows folders and files accessible through a UNIX interface. 

   Return to home by typing: ``` cd ```

![image](https://user-images.githubusercontent.com/56968566/69997123-4c2a8c80-1508-11ea-89d0-547a8a40515f.png)

If MobaXterm fails to launch after working for a period of time, try reinstalling the software. Prior to removal and re-install, copy the folder MobaXterm from your Documents directory to a new name. Under the directory Mobaxterm/home you will have the .ssh folder and .bashrc file. Reinstall Mobaxterm and copy these files over to the new install if you have customized these files.

### 3.3 Downloading an SSH key

**For the MobaXterm flow, native LINUX flow or macOS, click on the link Linux or macOS and follow the steps as stated in the welcome email.**

To start the process:

1. Click on the first link in the welcome email (might need to use an incognito window if you have issues launching or clear cookies).
2. If you are a first time user, you will see a "Terms and Conditions" page come up. Please click "accept" on the T&C's to proceed.
3. You will then come to a new screen asking to select "Learn" or "Connect", please select "Connect".
4. The following page will then be displayed. Click on “Linux* or MAC OS” under the "Connect with a Terminal" button.

![ssh_key_access](https://user-images.githubusercontent.com/56968566/67715899-f3eff000-f987-11e9-9b1c-5ad2ba2a96ea.png)

6. After clicking “**SSH key for Linux/macOS**”, you will get instructions on accessing a UNIX key file. 

7. Click the button "SSH Key for Linux/macOS". 

8. Create the directory ~/. ssh, unless it already exists and move the private SSH key into permanent storage in ~/.ssh:

   ```bash
   mkdir -p ~/.ssh
   mv ~/Downloads/devcloud-access-key-12345.txt ~/.ssh/
   ```

9. Add the following lines to files ~/.ssh/config:

   ```bash
   Host devcloud 
   #replace with your own user name
   User u12345
   IdentityFile ~/.ssh/devcloud-access-key-12345.txt
   ProxyCommand ssh -T -i ~/.ssh/devcloud-access-key-12345.txt guest@devcloud.intel.com
   ```

   If you saved your key in a location other than ~/Downloads/, insert the correct path and the correct user number that was provided to you in the email. 

10. Set the correct restrictive permissions on the private SSH. Run the following commands in terminal: 

    ```bash
    chmod 600 ~/.ssh/devcloud-access-key-u12345.txt
    chmod 600 ~/.ssh/config
    ```



**The next steps to connect to the Intel Devcloud are different for usage inside and outside the Intel Firewall. Select the correct usage option below:** 

[Public User](#public-user)

[User Inside Intel Firewall](#user-inside-intel-firewall)



## 4.0 Connection to Devcloud

### Public User

After the preparation steps above, you should be able to log in to your login node in the Intel Devcloud without a password. 

1. Enter the following: 

   ```
   ssh devcloud
   ```

Upon the first login, you will be asked to add the host devcloud to the list of known hosts. Answer **yes**.

```bash
The authenticity of host 'devcloud' (<no hostip for proxy command>)' can't be established.
ECDSA key fingerprint is SHA256:...
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'devcloud' (ECDSA) to the list of known hosts.
# We are in!
logout
Connection to login-1 closed.
```

Next time you log in, you will only need to type ```ssh devcloud ```

Click [here](#50-Connecting-to-Servers-Running-FPGA-Development-Software) to skip to the next step. 

### User Inside Intel Firewall

You cannot log into the Intel Devcloud through the above steps if you are within the Intel firewall. This section contains the tunneling commands and MobaXterm modifications needed to bypass the firewall to connect to the Devcloud. 

### 4.1 Add SOcket CAT Package

1. Go to the packages icon and left-click.

   ![packages_icon](https://user-images.githubusercontent.com/56968566/67716101-6234b280-f988-11e9-972a-7c13370e1adc.png)

   Your next step you will see the MobApt package manager for MobaXterm:

   ![socat](https://user-images.githubusercontent.com/56968566/67716113-6b258400-f988-11e9-828a-83c74b051b91.png)

2. Install the **socat package**. This will take approximately 9 minutes to install.

### 4.2  Preparing Configuration file for Intel firewall users

1. Replace additional entries into your config file: 

```
Host colfax-intel-proxy
User guest
hostname cluster.colfaxresearch.com
IdentityFile ~/.ssh/devcloud-access-key-12345.txt
ProxyCommand socat STDIO SOCKS4:proxy-us.intel.com:%h:%p,socksport=1080

Host colfax-intel-proxy-shell colfax-intel
#replace with your own user name
User u12345 
hostname devcloud
IdentityFile ~/.ssh/devcloud-access-key-12345.txt
ProxyCommand ssh -T colfax-intel-proxy
```

2. At your local machine prompt type: 

```
ssh colfax-intel
```

You will now be logged in:

![image](https://user-images.githubusercontent.com/56968566/69987680-e54fa800-14f4-11ea-8b03-9da4de9381c7.png)

Note that the following response:

tty: standard input: Inappropriate ioctl for device
X11 forwarding request <span style="color:red">failed </span>on channel 0 

​	 is expected behavior.

## 5.0 Connecting to Servers Running FPGA Development Software

### 5.1 Understanding available resources

You are now logged into machine called login-2 (headnode). You cannot run compute jobs here. You need to run compute jobs on a powerful compute node server.  

Some nodes can run Quartus, OpenCL emulation and compile and HLS emulation, simulation and compile. The node capacity grows with additional servers periodically added.

Some nodes can connect to machines with the above capabilities and also are directly connected to Arria 10 and Stratix 10 PAC cards.

There are a series of detailed Linux commands shown below should you want to know the intricate details of how to connect to available compute nodes. 

1. [Login Script](#52-login-script)  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;5. [Submitting Jobs for a Specified Walltime](#56-submitting-jobs-for-a-specified-walltime)
2. [Development Setup Tool](#53-development-tool-access-and-setup)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;6. [Batch Jobs Report Status](#57-report-status-for-jobs-running-on-the-devcloud)
3. [Querying Device Availability](#54-querying-device-availability) &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;7. [Deleting Batch Jobs](#58-deleting-jobs-on-the-devcloud)
4. [Submitting Batch Jobs](#55-submitting-batch-jobs)

### 5.2 Login Script

To facilitate connectivity without understanding some of the details on the Linux OS, we offer a script that simplifies connectivity called devcloudLoginToolSetup.sh located under /data/intel_fpga/devcloudLoginToolSetup.sh . Source the script in your ~/.bashrc by including these two lines inside the .bashrc:

```
if [ -f /data/intel_fpga/devcloudLoginToolSetup.sh ]; then
    source /data/intel_fpga/devcloudLoginToolSetup.sh
fi
```

Now you can run devcloud_login and follow the Devcloud login script instructions to connect to the appropriate compute node. The picture below shows what the current script appears as. When you type the command “devcloud_login”, the following output is shown. It separates the available nodes and what machines are capable of running.

![](LoginScriptGif.gif)

 Figure 1: Login Script Running

<img src="https://user-images.githubusercontent.com/59750149/80539447-5a1bf680-895c-11ea-923d-8bd150eb4779.png" alt="ArriaLogin" width=60% /> 

Figure 2: Arria10 Node Login Script Selection

<img src="https://user-images.githubusercontent.com/59750149/80540030-5fc60c00-895d-11ea-80ac-77f8c1dda845.png" alt="ArriaOapiLogin" width=60% />

Figure 3: Arria10 OneAPI Node Login Script Selection

<img src="https://user-images.githubusercontent.com/59750149/80540587-74ef6a80-895e-11ea-939a-089b2f147ba4.png" alt="StratixLogin" width=60% /> 

Figure 4: Stratix10 Node Login Script Selection

<img src="https://user-images.githubusercontent.com/59750149/80540856-f3e4a300-895e-11ea-957e-e5c9cf44a373.png" alt="StratixLogin" width=60% />

Figure 5: Compilation Node Login Script Selection

<img src="https://user-images.githubusercontent.com/59750149/80254531-3725d580-8630-11ea-8f25-9987132616c6.png" alt="LoginScript" width=53% />

Figure 6: Specific Node Login Script Selection

Once you select a node to start an interactive login, it will also output the command required to set up the x2go window. Just copy and paste into a new mobaxterm terminal. 

 <img src="https://user-images.githubusercontent.com/59750149/80255690-4b6ad200-8632-11ea-83ea-39df83ab5852.png" alt="x2go" width=77% />

Figure 7: x2go Command

Other features to the Devcloud login script are the ability to submit batch jobs from the homenode as well as to speed the user's interaction when wanting to log into a compute node interactively.

Instead of answering "What are you trying to use the Devcloud for? ..." every time to login to a node interactively, you can type the following:

```
devcloud_login -I [<argument options>]
-----------------------------------Argument-Options-------------------------------------
A10PAC
A10OAPI
S10PAC
CO
SNN <compute node name>
```

To  submit a batch job when logged into the login-2 machine (aka. homenode) , type the following:

```
devcloud_login -b [<argument options>] <job>.sh
-----------------------------------Argument-Options-------------------------------------
A10PAC <job>.sh
A10OAPI <job>.sh
S10PAC <job>.sh
CO <job>.sh
SNN <compute node name> <job>.sh
```

When you submit your job, you will be prompted with a job ID for your submission. With this ID you are able to query for job status and delete the job if desired. Once the job is completed, two files will be generated; </ job.sh.**e**XXXXX /> and </ job.sh.**o**XXXXX />. The </ job.sh.**e**XXXXX /> file will contain any error messages that occurred while running your batch job (if any). The </ job.sh.**o**XXXXX /> file will contain the output to your batch job submission.

For more information, try "devcloud_login --help" on a terminal that is logged into the devcloud.

![dev_help](https://user-images.githubusercontent.com/59750149/80256309-668a1180-8633-11ea-8b32-555a0c4bcc8c.png)

Figure 8: Login Script Help Message

### 5.3 Development Tool Access and Setup

From a terminal that is logged into the devcloud, to get Quartus Access and Quartus Setup you can source the bash scripts manually however its highly recommended to use the **tools_setup** function. This function will guide you through query of what compile workload you want to run.

Should you want to source setup scripts manually, view the file: /data/intel_fpga/devcloudLoginToolSetup.sh and manually copy and paste the paths and environment variable settings for your desired tool flow.

To source the tools_setup function, include these two lines inside your ~/.bashrc script:

    if [ -f /data/intel_fpga/devcloudLoginToolSetup.sh ]; then
    	source /data/intel_fpga/devcloudLoginToolSetup.sh
    fi

Follow the instructions after invoking the tools_setup function.

Another feature to the tools-setup function is the ability to speed the user's interaction when wanting to source the paths and environment variable settings for a desired tool flow into a compute node. Instead of answering "Which tool would you like to source? ..." every time, you can type the following:

```
tools_setup -t [<argument options>]
-----------------------------------Argument-Options-------------------------------------
QL <Version Number>
QS <Version Number>
QP <Version Number>
HLS <Quartus Edition> <Version Number>
A10DS <Version Number>
A10OAPI
S10DS
```



For more information, try "tools_setup --help" on a terminal that is logged into the devcloud.

![image](https://user-images.githubusercontent.com/59750149/80544165-488b1c80-8965-11ea-8cc4-1174ebbe325a.png)

Figure 1: Tool_Setup Help Message

Should you want more details on available compute resources and query what is available, continue with the instructions below.

### 5.4 Querying Device Availability

To query if free nodes are available run the below command on the login server (headnode). The terminology that we will use is localnode (your PC), headnode (login node) and compute node. The compute node is a high power machine for running compilations. 

```
pbsnodes -s v-qsvr-fpga | grep -B 4 fpga
pbsnodes -l free -s v-qsvr-fpga	# lists all free nodes that host PAC cards
```

You will get a listing of free and busy nodes that connect to PAC cards. 

If there is a free node, when you execute this command you will be logged in to a new machine within a minute or so. If no machine is available, you will be placed in a queue.

To login to a specific machine in interactive mode ( -I ), execute one of the following commands:

We will also show how to launch a batch job, which launches from the head node and executes on the compute node, and creates associated log files to allow you to view the results.

```
qsub -q batch@v-qsvr-fpga -I -l nodes=s00X-nXXX:ppn=2 # (for nodes with attached PAC cards, substitute with appropriate server numbers). Compute only nodes do not require -s v-qsvr-fpga
```

When launching the qsub command, you can request additional memory with the following command. Note: Each job takes 2 slots, so when you request 10G, it's actually 10G*2 = 20GB.

```
-l h_vmem=10G
```

Now you have a high power machine available for powerful computing jobs. You only have an **interactive**  console available but no graphics available. Note: MobaXterm has multiple tabs and three possibilities of where to be logged in: 

- Local Machine, your PC (eg. llandis-MOBL)
- devcloud eg login-2 login server
- compute server eg s001-n137

Be cognizant of which Mobaxterm tab and machine you are typing in.

At this point you will want to run a PC based product called [**X2Go client**](#60-graphics-usage-on-the-fpga-devcloud) that will allow you to have a Linux based GUI Intel Quartus and multiple terminal usage. In order to run GUI based applications such as Quartus and Modelsim, you will need to download an application on your PC called X2Go. X2Go is the remedy for slow graphics response from Mobaxterm running X11 or VNC windowing systems.

### 5.5 Submitting Batch Jobs

This section provides information on how to submit and terminate batch jobs on the Devcloud. 

To launch a batch job, user must be logged in to the machine called login-2 (headnode) since the qsub command launches the batch job from the head node. The user must also specify the name of the wanted powerful compute node server </ sxxx-nxxx/ > that will execute their submitted batch job. 

Type the following after knowing specified node; where *example.sh* represents user's batch file:

```bash
qsub -q batch@v-qsvr-fpga -l nodes=s00X-nXXX:ppn=2 -d . example.sh
```

Once the submitted job finishes running, two log files are created; *.sh.oxxxx and *.sh.exxxxx. The *.sh.oxxxxx file allows you to view the output results of the commands within the batch file. And *.sh.exxxxx file allows you to view any error results, if any, while the submitted batch file was running.

Example of a file to be executed, and the obtained outcomes once the job is done executing:

```bash
qsub -q batch@v-qsvr-fpga -l nodes=s001-n139:ppn=2 -d . job.sh
----------------------------------job.sh--------------------------------------------
  1 date
  2 hostname
  3 source ~/JOB_DEMO/HelpToolSetup.sh
  4 tools_setup -t QL 18.1
  5 which quartus
  6 cd unknown_directory
```

Error logfile obtained:

![errorimage](https://user-images.githubusercontent.com/59750149/79778493-a8425180-82ed-11ea-9f3a-c29f5d7cf945.png)

Output logfile obtained:

![outputimage](https://user-images.githubusercontent.com/59750149/79783143-0f173900-82f5-11ea-85d1-ce51ec62bd60.png)

### 5.6 Submitting Jobs for a Specified Walltime

A user will be logged off a node if they have been using it for longer than 6 hours. To submit a job with a specified walltime longer than 6 hours (for compilations longer than 6 hours). Nodes n130-n136 can increase walltime up to 24 hours and nodes n137-n139 and 189 can be increased up to a maximum of 48 hours. Type the following after qsub-ing into a specified node:

```
qsub -l walltime=<insert-time> 'command/bash file to be executed'

qsub -l walltime=12:00:00 walltime.sh		# example of a file to be executed
-------------------------------= walltime.sh ------------------------------

# begin walltime.sh

sleep 11h		# sleep command equivalent to a quartus compilation file requiring 11 hours of compilation
# alternatively, sleep 11h would be quartus_sh commands (i.e. quartus_sh --flow main.v) 	

echo job success > ~/Documents/walltime_log.txt		# exit sleep at 11:00:00, output "job success" to walltime_log.txt
```

### 5.7 Report Status for Jobs Running on the Devcloud

To report the status of your jobs running on the DevCloud is to type the following:

```
qstat -s batch@v-qsvr-fpga
```

The result will be of the form:

`v-qsvr-fpga.aidevcloud:`
                                                                                  `Req'd       Req'd       Elap`
`Job ID                  Username    Queue    Jobname          SessID  NDS   TSK   Memory      Time    S   Time`

----------------------- ----------- -------- ---------------- ------ ----- ------ --------- --------- - ---------

`2390.v-qsvr-fpga.aidev  u27224      batch    STDIN             27907     1      2       --   06:00:00 R  01:15:02`

### 5.8 Deleting Jobs on the Devcloud

Jobs can be terminated with the following command when nodes are hanging with stalled jobs: 

```
qdel 2390.v-qsvr-fpga.aidevcloud
```

Note the suffix for the qstat command is .aidev however to kill the job with qdel you need to append .aidevcloud .

This is **not recommended** but it is a another technique to delete a job from the headnode if a node is hanging. Type the following and look for the qsub commands:

```
ps -auxw 
```

Free up the node with the following command: 

```
kill -9 <job-id>
```

## 6.0 Graphics Usage on the FPGA Devcloud

Although you can do graphics in MobaXterm, it is slow thus we decided to use X2GO application for GUI based programs.

To download X2Go, navigate to this link on your PC browser: https://wiki.x2go.org/doku.php/download:start

Grab the **MS Windows version** – click where the cursor is in the screenshot below <u>**(mswin)**</u>:

![launching_x2go](https://user-images.githubusercontent.com/56968566/67716221-a6c04e00-f988-11e9-97a6-bae636d8732b.png)

Go through the install steps for the mswin X2Go Client and accept all.



### 6.1 Opening Port for Graphics Usage in X2Go

Repoen the MobaXterm window, open a second session tab by clicking on the "+" as shown below:![image](https://user-images.githubusercontent.com/56968566/69987433-5b074400-14f4-11ea-9046-eb3d39ca0f69.png)

This tab will a launch terminal running UNIX commands on your local (PC) machine. You should have two tabs open. The first tab should be logged into login-2. The second tab will be logged in to your PC. Recall when you ran devcloud_login you see a message that needs to be pasted into the PC tab as described in the next section. To open the port for graphics usage, use the devcloud_login function (sec 5.1) and copy and paste the appropriate ssh command shown as an output from this function into the tab that is logged into your PC. Examples of this command are shown below based on inside and outside the Intel firewall.

```
ssh -L 4002:s001-n137:22 devcloud			# Public User Example

ssh -L 4002:s001-n137:22 colfax-intel		# Inside Intel Firewall Example
```

![image](https://user-images.githubusercontent.com/56968566/69987632-c7824300-14f4-11ea-84c7-682490dc19f8.png)



Launch the x2go application on your PC. Set up the new session with the following settings substituting the Login field </ uXXXXX /> with your own assigned user name and the path to the RSA/DSA key for ssh connection. This is the same key referenced for MobaXterm connection that enables ssh devcloud.

<img src="https://user-images.githubusercontent.com/56968566/70007979-1943c100-1527-11ea-8cc0-685a5b50cfcb.png" alt="image" width=60% />



The input/output screen has a setting for the display size which can be adjusted depending on your screen size. Adjust the parameters on this panel to change to a different screen size. To determine what DPI to use for your monitor, type the following command in a MobaXterm terminal: 

```
xdpyinfo | grep dot
```

<img src="https://user-images.githubusercontent.com/56968566/70003091-f8736f80-1516-11ea-9b36-666084afee51.png" alt="image" width=60% />


To launch the application, hit **OK** to save the settings and then click on the **New Session** icon to launch a graphics session.

<img src="https://user-images.githubusercontent.com/56968566/69988900-6871fd80-14f7-11ea-8af1-dddc9c0adaad.png" alt="image" width=77% />

After a minute or so, you should see the X2GO screen, be patient. While waiting for X2GO to launch you will see a screen that looks like this:

![image](https://user-images.githubusercontent.com/56968566/69988847-4c6e5c00-14f7-11ea-8804-6394099a3b85.png)

Click **Yes** when the following window pops up. 

![image](https://user-images.githubusercontent.com/56968566/70008081-5314c780-1527-11ea-8c47-ad27b69222d7.png)

You might get the following message if you previously logged into a different machine:

<img src="https://user-images.githubusercontent.com/56968566/67716812-b55b3500-f989-11e9-8c60-9c0eaaee2172.png" alt="host_key_verification_terminate" width=67% />

Enter **No**.

Then another dialog box will appear, enter **Yes**,

<img src="https://user-images.githubusercontent.com/56968566/67716830-bee49d00-f989-11e9-86b4-5aee8f792b5e.png" alt="host_key_verification_update" width=80% />

You will see a window that looks like the following. If a window opens up, click **Default**.

![x2go_desktop](https://user-images.githubusercontent.com/56968566/67716843-c60bab00-f989-11e9-9d99-2fbbdcfce6d9.png)

If X2GO fails to launch, check that you ran the tunneling command on Mobaxterm on your local host. Click [here](#6.1-Opening-Port-for-Graphics-Usage-in-X2Go) to be redirected to the section regarding this tunneling command. 

In X2GO, right click within the desktop and select “Open Terminal Here”.

<img src="https://user-images.githubusercontent.com/56968566/67716892-dfacf280-f989-11e9-9d36-6e6c895c363e.png" alt="open_terminal" width=37% />

Your GUI ready environment should  be similar to the following image:![image](https://user-images.githubusercontent.com/56968566/69988693-ff8a8580-14f6-11ea-8b38-16ab19094b37.png)

To change the font sizing of the Desktop files in **Desktop Settings** under the **Icons** tab. Select “**Use custom font size**” and change it to 5 or to your font size preference.

<img src="https://user-images.githubusercontent.com/56968566/67716947-03703880-f98a-11e9-9b5f-e3b2b7eb79ad.png" alt="x2go_change_font" style="zoom: 80%;" />![x2go_fontsize](https://user-images.githubusercontent.com/56968566/67717026-27cc1500-f98a-11e9-9b01-f98c9a1a2d83.png)



**<u>If you want to make the log-in experience shorter without the need of typing the lengthy qsub and ssh commands for future log-in, complete the following steps outlined here:</u>**

[Setup Devcloud Login Script Instructions](#52-login-script)

Note that X2Go is only available on nodes s001-n13[7-9] and s001-n189 at this time.

### 6.2 Quartus Font Setup

Note, for any GUI based activity you need X2Go running. Based on network activity GUI response could be considerably slower speed than when running on a local PC. Try to structure your project to use batch commands for faster response through the terminal.

If the Quartus font appears too zoomed in, as shown below, complete the following:

Under the Tools tab on the Main Bar, select Options. In the General Category, select “Fonts” and change the text size to 6.

<img src="https://user-images.githubusercontent.com/56968566/67717114-55b15980-f98a-11e9-857e-8c8f5d572d51.png" alt="quartus_options"/>

 ![quartus_fontsize](https://user-images.githubusercontent.com/56968566/67717117-5649f000-f98a-11e9-92fe-2864e3d9b155.png)



## 7.0 Transferring Files to and from the Devcloud 

**There are three different ways to Transfer Files to and from the Devcloud:** 

1. [From/To a Local PC to/from DevCloud Server in X2Go Terminal (7.1)](#71-transferring-files-to-and-from-the-devcloud-with-scp)
2. [MobaXterm User Session (7.2)](#72-Using-MobaXterm-to-Transfer-Files)
3. [WinSCP Application (7.3)](#73-Using-WinSCP-to-Transfer-Files)
4. [MobaXterm Command Line to Transfer URLs (7.4)](#74-Using-mobaxterm-command-line to-transfer-urls-(github))

### 7.1 Transferring Files to and from the Devcloud with SCP 

Refer to the login instructions welcome page on file transfer to/from devcloud. **Use the local terminal on your PC to transfer files. Note: If on Intel firewall, replace devcloud with colfax-intel.**

Transferring Files from your localnode terminal. Your prompt on mobaxterm would be of the form: /home/mobaxterm (localnode)

```
scp /path/to/local/file devcloud:/path/to/remote/directory
```

From headnode or computenode to the localnode. 

```
scp devcloud:/path/to/remote/file /path/to/local/directory
```

If the path to the local directory is simply "." you will find the file on your PC in the following location:

Here is an example:

```
scp /drives/c/User/username/Documents/file.txt devcloud:/home/u12345
```



### 7.2 Using MobaXterm to Transfer Files

MobaXterm can be used to transfer files to and from your local PC to the Devcloud server.

<u>**To setup this feature, make sure that you have completed all the steps to connect to the DevCloud.**</u>

1. In the main toolbar of MobaXterm, click the **Session** button. ![mobaxterm_new_session](https://user-images.githubusercontent.com/56968566/67717144-65c93900-f98a-11e9-870b-784e76806a7f.png)

   

2. Select **SSH**. <img src="https://user-images.githubusercontent.com/56968566/67717168-6d88dd80-f98a-11e9-987a-3d226b109886.png" alt="mobaxterm_ssh" width=20% />

3. Enter the following information:
   1. Remote host: **localhost**
   2. Specify username: u12345 (edit to your username)
   3. Port: **4002**
      ![image](https://user-images.githubusercontent.com/56968566/69988244-1da3b600-14f6-11ea-8276-39ae5e70ef7d.png)

4. Under **Advanced SSH settings** > Select **Use Private Key** and search for the private key you used when you setup your DevCloud log-in. 

5. Click **OK**. 

6. If a new tab does not open, double-click on the side window **localhost (u#)**

   ![localhost_user_session](https://user-images.githubusercontent.com/56968566/67717217-82657100-f98a-11e9-8e15-30a98a73741e.png)

The localhost user directory tool can be re-opened and closed as necessary to transfer files. Files can be transferred by dragging and dropping into the side-bar that displays the contents of the user saved in the DevCloud directory. 

![image](https://user-images.githubusercontent.com/56968566/69988329-52177200-14f6-11ea-8924-da19a9c5a236.png)

### 7.3 Using WinSCP to Transfer Files

To have WinSCP working, please have a tunnel open connected to X2GO. This should be done by having a new mobaxterm tab open and connecting to X2GO through an SSH tunnel to the node selected.

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

Navigate to where your Devcloud access key is located in the folder .ssh. Select the options box on the bottom right that says, “Putty Private Key Files” and switch it to “All Files”. Select your Devcloud key .txt file.

![putty_private_key_files](https://user-images.githubusercontent.com/56968566/67717790-a37a9180-f98b-11e9-8bed-4af4fbb5df50.png)

This new window should open asking if you would like to convert the SSH private key to PuTTY format. Press OK to this. Then press Save in the new window that opens. Then OK once more.

![convert-to-private-key](https://user-images.githubusercontent.com/56968566/67717841-bab97f00-f98b-11e9-8614-b2c897606bd5.png)

Press **OK** and return to the original screen.

![type-in-localhost-information](https://user-images.githubusercontent.com/56968566/67717855-be4d0600-f98b-11e9-97cc-ba3044551548.png)

Fill in the following information:

Host name: Type in “localhost”

Port number: Type in 4002

User name: Type in the user name that was assigned to you

![image](https://user-images.githubusercontent.com/56968566/69988420-7a06d580-14f6-11ea-963d-40a465304dcb.png)

Press **Save** to save all the information you just inputted for next time, and then press **OK**

Press **Login**

Note: When re-using WinSCP to transfer files, re-open the application and **Login**. A new window will pop-up. Click **Update** and you should be able to access and transfer your Devcloud files on the server again. 

### 7.4 Using MobaXterm Command Line to Transfer URLs (Github)

You must be at the directory where you want to download the file from the Github site before running any of the two commands.

First copy the specific file's raw link from GitHub. (Open the file in Github, and on the top right corner click on 'Raw' to open the file in raw mode. Copy the URL).                                                      				                       ![image raw-link](https://user-images.githubusercontent.com/59750149/77709776-58d86200-6f89-11ea-89e5-10049dca22c1.png)

Then, use one of the following:

#### 1. WGET Command

**Wget** command retrieves content from web servers.
Use the wget command in command line providing one or more URLs as arguments to download the file (-s).

```bash
wget http://www.example.com/
```

![Image Wget](https://user-images.githubusercontent.com/59750149/77707156-8a4d2f80-6f81-11ea-982a-5bc970884e83.png)



#### 2. CURL Command

**Curl** command is used to copy a specific file from a public github repository, and it also allows you to rename the file as shown in the figure below. 
Use the curl command in command line to download the file.

```bash
curl -o filename http://raw.githubusercontent.com/example-file
```

![Image curl](https://user-images.githubusercontent.com/59750149/77707877-b36ebf80-6f83-11ea-8f6e-3f36c36d0e51.png)

tr -d '/r' < filename > newfilename



## 8.0 Launching Development Tools

Quickstart Guides are available at the Quickstart Guide section of this git site and updated frequently. Please take a look at these guides for various  topics:

* [RTL AFU](https://github.com/intel/FPGA-Devcloud/tree/master/main/QuickStartGuides/RTL_AFU_Program_PAC_Quickstart)
* [OpenCL](https://github.com/intel/FPGA-Devcloud/tree/master/main/QuickStartGuides/OpenCL_Program_PAC_Quickstart)
* [HLS](https://github.com/intel/FPGA-Devcloud/tree/master/main/QuickStartGuides/HLS_Lab)
* [One API](https://github.com/intel/FPGA-Devcloud/tree/master/main/QuickStartGuides/OneAPI_Program_PAC_Quickstart)
* [OpenVino](https://github.com/intel/FPGA-Devcloud/tree/master/main/QuickStartGuides)
* [Programing DE-Series boards](https://github.com/intel/FPGA-Devcloud/tree/master/main/QuickStartGuides/RTL_DE_board_Quickstart)

## 9.0 Downloading an .sof to the Devcloud connected DE10-Lite Board

Node s001-n138 has a DE10-Lite development board connected to the USB port. Login to this machine and you will see a programmer connection USB Blaster 1-13 to the board. Note there is only one DE10-Lite on the network.![image](https://user-images.githubusercontent.com/56968566/69988508-a1f63900-14f6-11ea-8fd3-cfb688faedc7.png)

If the USB Blaster is not configured, complete the following steps: 

- [ ] To download your completed FPGA design into the local device, connect the USB Blaster cable between your PC USB port and the USB Blaster port on your development kit. If you are not using the DE10-Lite, you may have to plug the kit into power using a wall adapter. Upon plugging in your device, you should see flashing LEDs and 7-segment displays counting in hexadecimal, or other lit up LEDs and 7-segments depending on previous projects that have been downloaded to the development kit. 

***Note: The lights and switches controlled on the Devcloud connected server kit cannot be controlled unless system console or another form of instrumentation is used.***

- [ ] To use the USB Blaster to program your device, you need to install the USB Blaster driver. To begin, open your Device Manager by hitting the Windows Key and typing Device Manager. Click the appropriate tile labeled Device Manager that appears.

- [ ] Navigate to the Other Devices section of the Device Manager and expand the section below. 

  ![device_manager](https://user-images.githubusercontent.com/56968566/67718301-be99d100-f98c-11e9-8e24-a04edfa7f1ea.png)

- [ ] Right click the USB Blaster device and select **Update Driver Software**.

- [ ] Choose to browse your computer for driver software and navigate to the path shown below.

  ![browse_driver_software](https://user-images.githubusercontent.com/56968566/67718364-da9d7280-f98c-11e9-9677-ed7d9a3a39b9.png)

- [ ] Click on **Next** and the driver for the USB Blaster should be installed.



## 10.0 Compiling on the Devcloud and Downloading to a Local PC connected DE10-Lite board

[10.1 Setting up USB Tunneling from Devcloud to Local PC USB Blaster](#101-setting-up-usb-tunneling-from-devcloud-to-local-pc-usb-blaster)

[10.2 Programming a Design from the Devcloud to a Local PC Connected FPGA](#102-programming-a-design-from-the-devcloud-to-a-local-pc-connected-fpga)

### 10.1 Setting up USB Tunneling from Devcloud to Local PC USB Blaster

- [ ] On your PC, launch the Quartus Programmer. Search **Programmer** in the File Explorer. 

  <img src="https://user-images.githubusercontent.com/56968566/67718453-01f43f80-f98d-11e9-9745-3f596993ced4.png" alt="programmer" width=67% />

- [ ] If you don’t have the Programmer on your PC, download it from this link: http://fpgasoftware.intel.com/18.1/?edition=lite&download_manager=dlm3&platform=windows

- [ ] Select **Additional Software** and download the **Quartus Prime Programmer** and **Tools**.

  ![download_programmer_intel](https://user-images.githubusercontent.com/56968566/67718603-55ff2400-f98d-11e9-9343-0e499609f487.png) 

- [ ] Follow the login prompts, download, and install the Programmer. 

- [ ] For Intel Employees within the Firewall, in the File Explorer Search window, search ''**Programmer**'', and select **Run as administrator**. For other users, you can open the Programmer (Quartus Prime 18.1) normally. 

  <img src="https://user-images.githubusercontent.com/56968566/67718645-64e5d680-f98d-11e9-9987-ea2d1ea6344c.png" alt="programmer" width=77% />

- [ ] Select **Yes** if a yellow window will pop-up asking if you to allow app changes from an unknown publisher. 

- [ ] The Programmer window should then pop-up.  

- [ ] Left click on **Hardware Setup…** and then select the **JTAG Settings** tab.

<img src="https://user-images.githubusercontent.com/56968566/67718852-dde52e00-f98d-11e9-9c06-39ac5c61aa5d.png" alt="download_programmer" width=57% /><img src="https://user-images.githubusercontent.com/56968566/67718870-eccbe080-f98d-11e9-83b8-1a7738f3f018.png" alt="run_admin" width=57% />

- [ ] Click on **Configure Local JTAG Server...**

- [ ] **Enable remote clients to connect to the local JTAG** server and **enter a password** in the prompt box and **<u>remember this password</u>**. It will be used to connect later.

  <img src="https://user-images.githubusercontent.com/56968566/67718930-0f5df980-f98e-11e9-92ce-21c5476c11b2.png" alt="hardware_setup" width=47% />

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

  <img src="https://user-images.githubusercontent.com/56968566/67718964-20a70600-f98e-11e9-99ac-d897ffa295cd.png" alt="configure_JTAG" width=70% />

- [ ] Left click on **Hardware Setup,** select the **JTAG Settings** tab, and **Add Server**.

  <img src="https://user-images.githubusercontent.com/56968566/67718986-2a306e00-f98e-11e9-9d06-24ccc2173801.png" alt="JTAG_password" width=67% />

- [ ] Enter in the following information: 

  Server name: **localhost:13090**

  Server password: (password you set up for your PC local JTAG server)

- [ ] Select **OK**, and you should see the localhost on the list of JTAG servers.

  <img src="https://user-images.githubusercontent.com/56968566/67719028-3d433e00-f98e-11e9-8c3d-fcaf6cec4aba.png" alt="add_server_JTAG" width=67% />

- [ ] Click on the **Hardware settings tab,** double click on the **localhost:13090**, and that should now be your selected USB blaster download connection. 

- [ ] Make sure localhost:13090 shows up as your currently selected hardware and that the connection status is OK.

### 10.2 Programming a Design from the Devcloud to a Local PC Connected FPGA

- [ ] Select the .sof file to be downloaded to the FPGA. 

- [ ] Click **OK** and click **Start**. The progress bar should show 100% (Successful) and turn green. If it fails the first time, click **Start** a second time. 

  ![100_succesful](https://user-images.githubusercontent.com/56968566/67719042-446a4c00-f98e-11e9-994f-2bcb55469fd0.png)



## 11.0 Timeouts and Disk Space

Your session will timeout after six hours after login. Batch submissions must complete within 24 hours or the job will terminated. Each user has access to 200 GB of disk space on the Devcloud.

If you find that you are kicked off the Devcloud due to short bursts of inactivity, this can be attributed to your PC display going to sleep. Complete the following steps to avoid session time-out:

1. In the Windows search bar, search "**Display settings**." 
2. Select in the side-bar **Power & Sleep**. 
3. Under **Screen**, change both settings to **Never**. 

## 12.0 Determining and Allocating Memory Availability and CPU Count and Speed

Enter the following in a Devcloud Terminal to determine memory availability: 

```
dmesg | grep Memory:
```

Enter the following in a Devcloud Terminal to determine CPU Count and Speed:

```
lscpu
```

When launching the qsub command, you can request additional memory: 
Note: Each job takes 2 slots, so when you request 10G, it's actually 10G*2 = 20GB.

```
-l h_vmem=10G
```


## 13.0 Devcloud Text Editors 

cat There are three available editors in the Devcloud terminal: 

1. [Gedit](https://help.gnome.org/users/gedit/stable/)
2. [Vi](https://www.washington.edu/computing/unix/vi.html)
3. [Emacs](https://www.digitalocean.com/community/tutorials/how-to-use-the-emacs-editor-in-linux)

For tutorials on how to use the editors listed above, click the hyperlinks to be redirected to a quick read tutorial site. 

## 14.0 Determining which version of the OS is running on a Node

```
cat /etc/os-release
```



------

<a href="#top">Back to top</a>

