**Login Script**

Below are the instructions to the Devcloud login script. The picture below shows what the current script appears as. When you type the command “login”, the following output is shown. It separates the available nodes into 130-136, and 137-139, as well as stating what the nodes have.

![](LoginScriptGif.gif)

![LoginScript](https://user-images.githubusercontent.com/55601103/68438972-cae71080-017a-11ea-98b3-e9d3e8c1b4dc.png)               

Figure 1: Login Script Running

The script is located inside the .bashrc, and looks as follows:

![bashrc](https://user-images.githubusercontent.com/55601103/68438976-ce7a9780-017a-11ea-98ff-b71a0fa6f5e3.png)

Figure 2: Login Script inside .bashrc

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

Below is the script, which you can copy and paste into the .bashrc.

Before pasting though, you must run the command “:set paste” and then paste. If not it will auto-indent and change the formatting of the script. 

 

```
devcloud_login()
{
                                red=$'\e[1;31m'
                                blu=$'\e[1;34m'
                                end=$'\e[0m'
                                
                                ps -auxw | grep 'qsub -q batch@v-qsvr-fpga -I -l nodes=' | awk '{print $16}' | grep ^node | sed 's-nodes=s001\---' | sed 's-:ppn=2--' | uniq > nodecheck.txt
                                nodecheck=$(head -n 1 nodecheck.txt)
                                
                                echo
                                printf "%s\n" "${blu}What are you trying to use the Devcloud for? Please select a number from the list below: ${end}"
                                echo
                                echo "1) Arria 10 PAC Card Programming"
                                echo "2) Stratix 10 PAC Card Programming"
                                echo "3) Compilation Only"
                                echo "4) Enter Specific Node Number"
                                echo
                                echo -n "Number: "  
                                read -e number
                
                                until [ "$number" -eq 1 ] || [ "$number" -eq 2 ] || [ "$number" -eq 3 ] || [ "$number" -eq 4 ]
               do
                       printf "%s\n" "${red}Invalid Entry. Please input a correct number from the list above. ${end} "
                       echo -n "Number: "
                                                read -e number
               done
                
                
                                if [ $number -eq 1  ]; then
                                                if [ -z $nodecheck ]; then
                                                                pbsnodes -s v-qsvr-fpga | grep -B 4 'arria10' | grep -B 1 "state = free"| grep -B 1 '13[0-9]' | grep -o '...$' > ~/nodes.txt
                                                                node=$(head -n 1 nodes.txt)
                                               if [ -z $node ]; then
                                                                                echo
                                                                                echo
                                                                                printf "%s\n" "${red}--------------------------------------------------------------- ${end} "
                                                                                printf "%s\n" "${red}No available nodes for this hardware. Please select a new node. ${end} "
                                                                                printf "%s\n" "${red}--------------------------------------------------------------- ${end} "
                                                                                devcloud_login
                                                                else        
                                                                                echo
                                                               echo --------------------------------------------------------------------------------------
                                                               printf "%s\n" "${blu}Please copy and paste the following text in a new mobaxterm terminal: ${end} "
                                                               echo
                                                               printf  "%s\n" "${blu}ssh -L 4002:s001-n"$node":22 colfax-intel${end} "
                                                               echo
                                                               echo --------------------------------------------------------------------------------------
                                                               echo
                                                                                qsub -q batch@v-qsvr-fpga -I -l nodes=s001-n"$node":ppn=2
                                                                fi
                                                else
                                                                printf "%s\n" "${red}You are currently on a node. Please exit the current node and try again.${end}"
                                                fi             
                                elif [ $number -eq 2 ]; then
                                                if [ -z $nodecheck ]; then
                                                                pbsnodes -s v-qsvr-fpga | grep -B 4 'darby' | grep -B 1 "state = free"  | grep -B 1 '189' | grep -o '...$' > ~/nodes.txt
                                                                node=$(head -n 1 nodes.txt)
                                               if [ -z $node ]; then
                                                                                echo
                                                                                echo
                                                                                printf "%s\n" "${red}--------------------------------------------------------------- ${end} "
                                      printf "%s\n" "${red}No available nodes for this hardware. Please select a new node. ${end} "
                                      printf "%s\n" "${red}--------------------------------------------------------------- ${end} "
                                                                                devcloud_login
                                                                else        
                                                                                echo
                                                               echo --------------------------------------------------------------------------------------
                                                               printf "%s\n" "${blu}Please copy and paste the following text in a new mobaxterm terminal: ${end} "
                                                               echo
                                                               printf  "%s\n" "${blu}ssh -L 4002:s001-n"$node":22 colfax-intel${end} "
                                                               echo
                                                               echo --------------------------------------------------------------------------------------
                                                               echo
                                                                                qsub -q batch@v-qsvr-fpga -I -l nodes=s001-n"$node":ppn=2
                                                                fi
                                                else
                                                                printf "%s\n" "${red}You are currently on a node. Please exit the current node and try again.${end}"
                                                fi             
                                elif [ $number -eq 3 ]; then
                                                pbsnodes | grep -B 1 "state = free"| grep -T '13[0-6]' | grep -o '...$' > ~/nodes.txt
                                                node=$(head -n 1 nodes.txt)
                               if [ -z $node ]; then
                                                                echo
                                                                echo
                                                                printf "%s\n" "${red}--------------------------------------------------------------- ${end} "
                               printf "%s\n" "${red}No available nodes for this hardware. Please select a new node. ${end} "
                               printf "%s\n" "${red}--------------------------------------------------------------- ${end} "
                                                                devcloud_login
                                                else        
                                                                echo
                                               echo --------------------------------------------------------------------------------------
                                               printf "%s\n" "${blu}Please copy and paste the following text in a new mobaxterm terminal: ${end} "
                                               echo
                                               printf  "%s\n" "${blu}ssh -L 4002:s001-n"$node":22 colfax-intel${end} "
                                               echo
                                               echo --------------------------------------------------------------------------------------
                                               echo
                                                                qsub -I -l nodes=s001-n"$node":ppn=2
                                                fi             
                
                                else
                                                echo "                               Showing available nodes below:                          "
                               echo --------------------------------------------------------------------------------------
                               printf "%s\n" "${blu}Nodes with no attached hardware:${end}          "
                               pbsnodes |grep -B 1 "state = free"| grep -T '13[0-6]' | grep -o '...$'
                               echo
                               echo --------------------------------------------------------------------------------------
                               printf "%s\n" "${blu}Nodes with Arria 10${end}         "
                               pbsnodes -s v-qsvr-fpga | grep -B 4 'arria10' | grep -B 1 "state = free"| grep -B 1 '13[0-9]' | grep -o '...$'
                               printf "%s\n" "${blu}Nodes with Stratix 10${end}         "
                               pbsnodes -s v-qsvr-fpga | grep -B 4 'darby' | grep -B 1 "state = free"  | grep -B 1 '189' | grep -o '...$'
                               echo --------------------------------------------------------------------------------------
                               echo
                               echo What node would you like to use?
                               echo
                                                echo -n "Node: "
                                                read -e node
                               until  [ $node -lt 140 ] && [ $node -gt 129 ]  ||  [ "$node" == 189 ]
                               do
                                              printf "%s\n" "${red}Please input an available node number: ${end}"
                                                                echo -n "Node: "
                                                                read -e node
                               done
                  
                               if [ "$node" -le 136 ]; then
                                              echo
                             echo --------------------------------------------------------------------------------------
                             printf "%s\n" "${blu}Please copy and paste the following text in a new mobaxterm terminal: ${end} "
                             echo
                             printf  "%s\n" "${blu}ssh -L 4002:s001-n"$node":22 colfax-intel${end} "
                             echo
                             echo --------------------------------------------------------------------------------------
                             echo
                                                                qsub -I -l nodes=s001-n"$node":ppn=2
                               else
                                              if [ -z $nodecheck ]; then              
                                                                                echo
                                             echo --------------------------------------------------------------------------------------
                                             printf "%s\n" "${blu}Please copy and paste the following text in a new mobaxterm terminal: ${end} "
                                             echo
                                             printf  "%s\n" "${blu}ssh -L 4002:s001-n"$node":22 colfax-intel${end} "
                                             echo
                                             echo --------------------------------------------------------------------------------------
                                             echo
                                                                                qsub -q batch@v-qsvr-fpga -I -l nodes=s001-n"$node":ppn=2
                                                                else
                                                                                printf "%s\n" "${red}You are currently on a node. Please exit the current node and try again.${end}"
                                                                fi             
                               fi
                
                
                                fi
                                
                
}

```



 

 

 

 

 

 

 

 

 

 

 

 

 

Once you select a node, it will also output the command required to set up the x2go window. Just copy and paste into a new mobaxterm terminal. 

 

   ![x2go](https://user-images.githubusercontent.com/55601103/68438979-d20e1e80-017a-11ea-8fd6-db5919524051.png)

Figure 3: x2go Command

 

 