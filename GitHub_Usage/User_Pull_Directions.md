# GitHub Devcloud User Instructions 

**Git** is the open source distributed version control system that facilitates GitHub activities on your laptop or desktop. This mark down summarizes commonly used Git command line instructions for quick reference to download, edit, and interact with files on the Devcloud GitHub repository. 

## General GitHub Devcloud Rules

1. Always get the most recent changes on GitHub pulled to your local repository 

   - A lot of edits will be made from one user to another. To get the most recent changes on different branches, always pull from the GitHub before starting to make new changes to your local repository. 

   

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

## Clone Entire Remote FPGA-Devcloud Repository

Complete the following command to clone the entire remote FPGA-Devcloud Repository to your local PC. 

```
git clone git@github.com:intel/FPGA-Devcloud.git
```



## Clone Single Branch (Single Care Package) from FPGA-Devcloud Repository

Complete the following command to clone a single branch from the FPGA-Devcloud Repository. 

```
git clone -b <branch> <remote_repo>
git clone -b my-branch git@github.com:intel/FPGA-Devcloud.git
```

### 1.  RTL Quickstart Guide Package

```
git clone -b RTL-quickstartgit@github.com:intel/FPGA-Devcloud.git
```



## Moving from Branch to Branch

```
git checkout branch-you-want-to-move-to		# move to the branch you want
```



## Get latest changes on GitHub back to your Computer

In order to get the most recent changes that you or others have merged on GitHub, execute the following:

```
git pull origin master     # when working on the master branch
git log					   # see all the new commits
```



## Opening Files from MobaXterm Command Line

**In MobaXterm:** `open <filename>` 

```
open 'README.md'
open 'User_Pull_Directions.md'
```



### Setting up Typora for Open Command

If Typora is set as the default markdown editor, then in cmd.exe, input `.md` file path directly would open target markdown file. 



To set Typora as the default markdown editor you have to do following:

1. Select one of your markdown files
2. Open context menu and choose
   - *Properties* and then click on *Change* buttong, as shown in **Figure 1**
   - *Open with -> Choose another app*, as shown in **Figure 2**
3. Choose *Typora* or *Typora Launcher* in **How do you want to open this file?** and set a checkmark for *Always use this app to open .md files.*

**Figure 1 - File properties window**
![Figure 1 - Open Properties of Markdown file](https://support.typora.io/media/use-from-shell/Snip20180704_1.png)

**Figure 2 - Application chooser window**
![Figure 2 - Applicaiton chooser](https://support.typora.io/media/use-from-shell/Snip20180704_2.png)