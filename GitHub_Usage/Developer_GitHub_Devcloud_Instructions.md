# GitHub Devcloud Developer Instructions 

**Git** is the open source distributed version control system that facilitates GitHub activities on your laptop or desktop. This mark down summarizes commonly used Git command line instructions for quick reference to use on the Devcloud GitHub repository. 

**If you are not familiar with Git or GitHub yet, complete this tutorial from HubSpot:**

https://product.hubspot.com/blog/git-and-github-tutorial-for-beginners

**If you don't know what the GitHub Flow is**, click this link: https://guides.github.com/introduction/flow/

- [GitHub Devcloud Instructions](#github-devcloud-instructions)
  - [General GitHub Devcloud Rules](#general-github-devcloud-rules)
  - [Installing GitBash Linux](#installing-gitbash-linux)
  - [Installing GitHub Desktop GUI](#installing-github-desktop-gui)
  - [Logging-in to Devcloud Repository in Terminal](#logging-in-to-devcloud-repository-in-terminal)
  - [Logging-in to Devcloud Repository through GitHub Desktop](#logging-in-to-devcloud-repository-through-github-desktop)
  - [Generating a new SSH Key in MobaXterm](#generating-a-new-ssh-key-in-mobaxterm)
  - [Adding a File to a Repository](#adding-a-file-to-a-repository)
  - [Creating a New Branch](#creating-a-new-branch)
  - [Moving from Branch to Branch](#moving-from-branch-to-branch)
  - [Pushing a Branch to Master GitHub Repository](#pushing-a-branch-to-master-github-repository)
  - [Get latest changes on GitHub back to your Computer](#get-latest-changes-on-github-back-to-your-computer)

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

**Git Clone** is used to retrieve a remote repository copy. **Git Pull**, which is mentioned [here](#Pull-latest-changes-on-GitHub-back-to-your-Computer), is used to retrieve the newest set of updates on the remote repository. Git clone is used for just downloading exactly what is currently working on the remote server repository and saving it in your machine's folder where that project is placed. 



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
git push 						# pushes changes in local repo up to remote repo branch
git status						# check status after push
```

See the following link for more information: https://help.github.com/en/articles/adding-a-file-to-a-repository-using-the-command-line



## Creating a New Branch

Branches allow you to move back and forth between different states of a project. 

To create a new branch from an existing branch in a local repository execute the following:

```
git checkout -b new-branch			# move to new branch
git branch							# lists all local branches in the current repo
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



## Opening Files from MobaXterm Command Line

**In MobaXterm:** `open <filename>` 

Examples: 

```
open 'README.md'
open 'User_Pull_Directions.md'
```

### Typora

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

