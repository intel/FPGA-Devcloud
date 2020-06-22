# GitHub Devcloud Developer Instructions 

**Git** is the open source distributed version control system that facilitates GitHub activities on your laptop or desktop. This mark down summarizes commonly used Git command line instructions for quick reference to use on the Devcloud GitHub repository. 

**If you are not familiar with Git or GitHub yet, complete this tutorial from HubSpot:**

https://product.hubspot.com/blog/git-and-github-tutorial-for-beginners

**If you don't know what the GitHub Flow is**, click this link: https://guides.github.com/introduction/flow/

[

[TOC]

](#github-pictures)

## General GitHub Devcloud Rules

1. Create a new branch for every new feature
   - Every time you start working on something new (workshop, quickstart guide, read-me tutorial), create a new Git branch that you can push to the main branch
   - **Try not to make edits on the master branch** - This can cause potential merge conflicts if we all edit multiple documents at the same time. 
   - For instance, if you are creating a new instruction section on the Public Devcloud Access Instructions md file, do the following:
     - Create a dedicated branch for this new feature
     - Give it a meaningful name (e.g. *contact-me-section*)
     - Commit all the code to that specific branch
2. Always get the most recent changes on GitHub pulled to your local repository 
   - A lot of edits will be made from one user to another. To get the most recent changes on different branches, always [git pull](#Pull-latest-changes-on-GitHub-back-to-your-Computer) from the GitHub before starting to make new changes to your local repository. 
3. Use Pull Requests to merge code to Master branch
   - Every repository has a master branch by default. **Avoid pushing changes immediately to the master branch. Ensure that no merge conflicts will occur or data will be lost before pushing.**
   - Use feature branches described in step 1 and open a new pull request to merge the feature branch code with the master branch code. 
   - After your code has been reviewed, tested, and approved, your reviewers will give you a thumbs up for you to merge the Pull Request, or they will directly merge your pull request. 

## GitHub Desktop

<u>**Click the following link to download GitHub Desktop to your Local PC:**</u>

**GitHub Desktop Link:** https://desktop.github.com/

- [ ] Go through the installation process
- [ ] Log in to your GitHub, by inputting your username and password

#### Setup the Proxy

To be able to connect to the Intel Wi-Fi and use GitHub Desktop, you need to first set up the proxy links.

- [ ] Go to C:\Users\@username **(Replace @username with your PC username)**
- [ ] There will be a **.gitconfig** file. If there isn't, create one
  - [ ] Right click this file and choose to open it with notepad, or alternative text editor
- [ ] Append the following to the text at the very bottom

```
[http]
        proxy = http://proxy-chain.intel.com:911
[https]
        proxy = https://proxy-chain.intel.com:912
[ftp]
        proxy = ftp://proxy-chain.intel.com:911
```

- [ ] Save and close the file

#### Set Up Repository

- [ ] Now inside GitHub Desktop choose the Intel FPGA-Devcloud Repository, or search for it
- [ ] Click the clone button

You can now use GitHub Desktop to view, edit, and control the GitHub in a more visual method.

## Installing GitBash 

**Git** for Windows provides a BASH emulation used to run Git from the command line. *NIX users should feel right at home, as the BASH emulation behaves just like the "git" command in LINUX and UNIX environments. 

<u>**Git** is compatible with MobaXterm. In fact, it is preferred that GitHub Devcloud developers **use MobaXterm** for issues addressed in firewall access and generating a new SSH key.</u>

<u>**Click one of the following links to download GitBash to your Local PC:**</u>

**Git for Windows**: https://git-scm.com/download/win

**Git for Mac:** https://git-scm.com/download/mac

- [ ] Open the Git executable file and begin installation. 
  - [ ] Install **Git Bash** **Here**, **Git GUI Here** optional
- [ ] **Use Git and optional Unix tools from the Windows Command Prompt**
  - [ ] Checkout Windows-style, commit Unix-style line endings
- [ ] Default on next couple of setting windows.  
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



## Logging-in to Devcloud Repository through GitHub Desktop

- [ ] Sign-in through **File** > **Options** 
- [ ] Enter your log-in information in GitHub.com. If you do not have an Intel GitHub account, you must register a new one using your Intel email. 



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



## Clone Remote FPGA-Devcloud Repository

**Git Clone** is used to duplicate a remote repository copy onto your local PC. **Git Pull**, which is mentioned [here](#Pull-latest-changes-on-GitHub-back-to-your-Computer), is used to retrieve the newest set of updates on the remote repository. Git clone is used for just downloading exactly what is currently working on the remote server repository and saving it in your machine's folder where that project is placed. 



Complete the following command to clone the remote FPGA-Devcloud Repository to your local PC. 

```
git clone git@github.com:intel/FPGA-Devcloud.git
```



## Cloning a Single Branch from the FPGA-Devcloud Repository

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

### 2.  Embedded Nios Quickstart Guide

```
git clone -b EmbeddedNios-quickstart git@github.com:intel/FPGA-Devcloud.git
```



## Moving from Branch to Branch

```
git branch -a					 # list all remote and local repositories
git checkout branch-you-want-to-move-to		# move to the branch you want
```



## Adding a File to a Repository

You can upload an existing file to a GitHub repository using the command line. 

This procedure assumes you've already:

- Created a repository on GitHub (or have an existing repository owned by someone else you'd like to contribute to)
- Cloned the repository locally on your computer

**Quick Reference Guide:** 

1. Move the file you want to upload to GitHub into the local directory that was created when you cloned the repository. (mv or FileExplorer) 
2. In GitBash, change the current working directory to your local repository. You can do this using cd or by opening up the file location in File Explorer, right-clicking, and selecting **Git Bash Here.**
3. Execute the following commands: 

```
git add *						# adds file to local repo and stages for commit
git status 						# check status of added files
git commit -m "message"			# commits tracked changes, prepares to push
git status 						# check status of commits
git push 				# pushes changes in local repo up to remote repo branch
git status						# check status after push
```

See the following link for more information: https://help.github.com/en/articles/adding-a-file-to-a-repository-using-the-command-line



## Creating a New Branch

Branches allow you to move back and forth between different states of a project. 

To create a new branch from an existing branch in a local repository execute the following:

```
git checkout -b new-branch			# move to new branch
git branch						# lists all local branches in the current repo
```



## Pushing a Branch to Master GitHub Repository

**DO NOT COMPLETE THIS UNLESS YOU HAVE SUBMITTED A PULL REQUEST.** Assess if there will be merge conflicts before pushing to the master branch. 

Push the commit in your branch to your new GitHub repository. 

```
git push origin master	# pushes changes in local repo up to master branch
```



## Pull latest changes on GitHub back to your Computer

**Git Pull** is used to retrieve the newest set of updates on the remote repository.

In order to get the most recent changes that you or others have merged on GitHub, execute the following:

```
git pull origin master     # when working on the master branch
git pull				   # entire remote repository
git log					   # see all the new commits
```



## Downloading Github File from MobaXterm Command Line

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



## Opening Files from MobaXterm Command Line
You must be on a localnode terminal to open files. 

**In MobaXterm:** `open <filename>` 

Examples: 

```
open 'README.md'
open 'User_Pull_Directions.md'
```

### Typora

If Typora is set as the default markdown editor, then in cmd.exe, input `.md` file path directly would open target markdown file. Click [here](https://www.typora.io/) to download Typora. 

To set Typora as the default markdown editor you have to do following:

1. Select one of your markdown files

2. Open context menu and choose
   - *Properties* and then click on *Change* button, as shown in **Figure 1**
   - *Open with -> Choose another app*, as shown in **Figure 2**
   
3. Choose *Typora* or *Typora Launcher* in **How do you want to open this file?** and set a checkmark for *Always use this app to open .md files.*

   **Figure 1 - File properties window**
   
    <img src="https://support.typora.io/media/use-from-shell/Snip20180704_1.png" alt="Figure 1 - Open Properties of Markdown file" width=40% />
   
   **Figure 2 - Application chooser window**
   
   <img src="https://support.typora.io/media/use-from-shell/Snip20180704_2.png" alt="Figure 2 - Applicaiton chooser" width=40% />



### Github Pictures

To be able to display the pictures on your Typora markdown files on the github site, you need to create a link for the pictures saved on your computer drive.

 

To create a link for the pictures, first you need to go to the [github website](https://github.com/intel/FPGA-Devcloud), and click on "issues" tab. 

<img src="https://user-images.githubusercontent.com/59750149/78585828-5bd81b80-77ef-11ea-872f-c2032ac59f79.png" width=70% />

Second, click on <img src="https://user-images.githubusercontent.com/59750149/78585998-9d68c680-77ef-11ea-8583-b88239521262.png" alt="img-newissue" width=16% />to create a new issue. Then, drag&drop or paste the picture in the 'Leave a comment' section; this will automatically create a github link. 

<img src="https://user-images.githubusercontent.com/59750149/78586141-da34bd80-77ef-11ea-933f-aa9f57401cbb.png" alt="comment-sec" width=75% />

Lastly, copy that link and paste it into the .md file you are writing. Note once the link has been copied the issue is not needed anymore, thus you can submit then delete the issue or simply close the internet tab without submitting the issue.

### Adding contributors 

See: https://opensource.intel.com/how-to/otc-infrastructure/github

