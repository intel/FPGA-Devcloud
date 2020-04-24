**Login Script**

Below are the instructions to the Devcloud login script. The picture below shows what the current script appears as. When you type the command “devcloud_login”, the following output is shown. It separates the available nodes and what machines are capable of running.

![](LoginScriptGif.gif)

​        

 <img src="https://user-images.githubusercontent.com/59750149/80254531-3725d580-8630-11ea-8f25-9987132616c6.png" alt="LoginScript" width=67% />

Figure 1&2: Login Script Running




Source the script in your ~/.bashrc by including these two lines inside the .bashrc:
```
if [ -f /data/intel_fpga/devcloudLoginToolSetup.sh ]; then
    source /data/intel_fpga/devcloudLoginToolSetup.sh
fi
```

 

Once you select a node to start an interactive login, it will also output the command required to set up the x2go window. Just copy and paste into a new mobaxterm terminal. 

 <img src="https://user-images.githubusercontent.com/59750149/80255690-4b6ad200-8632-11ea-83ea-39df83ab5852.png" alt="x2go" width=70% />

Figure 3: x2go Command



Other features to the Devcloud login script are the ability to submit batch jobs from the home node as well as to speed the user's interaction when wanting to log into a compute node interactively.

Instead of the user answering "What are you trying to use the Devcloud for? ..." every time to login to a node interactively,  

For more information, try "devcloud_login --help" on the MobaXterm terminal.

![dev_help](https://user-images.githubusercontent.com/59750149/80256309-668a1180-8633-11ea-8b32-555a0c4bcc8c.png)

Figure 4: Login Script Help



____

Refer to this<>