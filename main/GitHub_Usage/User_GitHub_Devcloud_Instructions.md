# GitHub Devcloud User Instructions 

**Git** is the open source distributed version control system that facilitates GitHub activities on your laptop or desktop. This mark down summarizes commonly used Git command line instructions for quick reference to download, edit, and interact with files on the Devcloud GitHub repository. 

## General GitHub Devcloud Rules

1. First, complete the setup steps for installing GitBash and user login. 

2. Then, [git clone]("Clone-Remote-FPGA-Devcloud-Repository") to copy what you want from the remote repository onto your local PC. 

3. Finally, always get the most recent changes on GitHub pulled to your local repository when re-opening GitHub FPGA Devcloud material. 

   - A lot of edits will be made from one user to another. To get the most recent changes on different branches, always [git pull](#Pull-latest-changes-on-GitHub-back-to-your-Computer) from the GitHub before starting to make new changes to your local repository. 

   

## Installing GitBash (Linux)

   **Git** for Windows provides a BASH emulation used to run Git from the command line. *NIX users should feel right at home, as the BASH emulation behaves just like the "git" command in LINUX and UNIX environments. 

   <u>**Git** is compatible with MobaXterm. In fact, it is preferred that GitHub Devcloud developers **use MobaXterm** for issues addressed in firewall access and generating a new SSH key.</u>

   <u>**Click one of the following links to download GitBash to your Local PC:**</u>

   **Git for Windows**: https://git-scm.com/download/win

   **Git for Mac:** https://git-scm.com/download/mac

   - [ ] Open the Git executable file and begin installation. 
     - [ ] Install **Git Bash** **Here**, **Git GUI Here** optional
   - [ ] **Use Git and optional Unix tools from the Windows Command Prompt**
     - [ ] Checkout Windows-style, commit Unix-style line endings
   - [ ] Use MinTTY 
     - [ ] Click **Install**
   - [ ] Once you complete the Git Setup Wizard > **Launch Git Bash**

   

   ## Logging-in to Devcloud Repository in Terminal

   Enter the following user information to gain access to the devcloud repository in MobaXterm. 

   ```
   $ git config --global user.name "username"
   ```

   ```
   $ git config --global user.email "user email address"
   ```

   

## Generating a new SSH Key in MobaXterm

**Note: If you are not connected to the Intel wifi or within the firewall, please disregard this section.**

**If you cannot push or pull to GitHub FPGA Devcloud repository and you are connected to the Intel wifi, you need to setup an SSH key.** 

**1. We need to first generate a new SSH key.**

- Open a new tab in MobaXterm and enter the following: 

```
ssh-keygen -t rsa -C "your_email@example.com"
```

- This creates a new SSH key, using the provided email as a label. 

```
> Generating public/private rsa key pair. 
```

- When you're prompted to "Enter a file in which to save the key," press Enter. This accepts the default file location.

```shell
> Enter a file in which to save the key (/c/Users/you/.ssh/id_rsa):[Press enter]
```

- At the prompt, type a secure passphrase (or you can do without, just press Enter twice). 

```shell
> Enter passphrase (empty for no passphrase): [Type a passphrase]> Enter same passphrase again:
```



**2. Now you need to add this SSH key to your GitHub account.**

- Copy your public key (the contents of the newly-created `id_rsa.pub` file) into your clipboard. Type the following in MobaXterm:

  ```
  $ clip < ~/.ssh/id_rsa.pub
  ```

- Paste your SSHpublic key into your GitHub account settings.

  - Go to your GitHub [Account Settings](https://github.com/settings/profile)
  - Click “[SSH Keys](https://github.com/settings/ssh)” on the left.
  - Click “New SSH Key” on the right.
  - Add a label (like “FPGA-devcloud MobaXterm”) and paste the public key into the big text box. Delete the empty space below the text. 
  - Click "Add SSH Key"



**3. Now you need to edit the .ssh config file.** 

- Change your directory to the .ssh folder and open an editor to change config file:

```
cd ~/.ssh	
vi config	
```

- Append the following to your config: 

```
Host github.com
port 22
User git
IdentityFile ~/.ssh/id_rsa
ProxyCommand socat STDIO SOCKS4:proxy-us.intel.com:%h:%p,socksport=1080
```

**4. Let's test if you completed all the steps correctly and it works!** 

- In a terminal/shell, type the following to test it:

  ```
  $ ssh -T git@github.com
  ```

- If it says something like the following, it worked:

  ```
  Hi username! You've successfully authenticated, but Github does
  not provide shell access.
  ```



## Clone Remote FPGA-Devcloud Repository

**Clone** is used to retrieve a remote repository copy. **Pull**, which is mentioned [here](#Pull-latest-changes-on-GitHub-back-to-your-Computer), is used to retrieve the newest set of updates on the remote repository. Git clone is used for just downloading exactly what is currently working on the remote server repository and saving it in your machine's folder where that project is placed. 



Complete the following command to clone the remote FPGA-Devcloud Repository to your local PC. 

```
git clone git@github.com:intel/FPGA-Devcloud.git
```



## Clone Quickstart Source Packages from FPGA-Devcloud Repository

Complete the following command to clone a single branch from the FPGA-Devcloud Repository. This will copy a folder containing all the necessary source files for a specified quick start guide, such as RTL, Embedded Nios Platform Designer, HLS, OpenCL, OpenVino, etc. 

```
git clone -b <branch> <remote_repo>
git clone -b my-branch git@github.com:intel/FPGA-Devcloud.git
```



## Examples of Cloning a Specific Quickstart Source Package 

### 1.  RTL Quickstart Guide

```
git clone -b RTL-quickstart git@github.com:intel/FPGA-Devcloud.git
```

### 2.  Embedded Nios (Platform Designer) Quickstart Guide

```
git clone -b EmbeddedNios-quickstart git@github.com:intel/FPGA-Devcloud.git
```



## Moving from Branch to Branch

```
git branch -a								# list all remote and local repositories
git checkout branch-you-want-to-move-to		# move to the branch you want
```



## Pull latest changes on GitHub back to your Computer

**Git Pull** is used to retrieve the newest set of updates on the remote repository.

In order to get the most recent changes that you or others have merged on GitHub, execute the following:

```
git pull origin master     # when working on the master branch
git pull				   # entire remote repository
git log					   # see all the new commits
```



## Opening Files from MobaXterm Command Line

**In MobaXterm:** `open <filename>` 

```
open 'README.md'
open 'User_Pull_Directions.md'
```
