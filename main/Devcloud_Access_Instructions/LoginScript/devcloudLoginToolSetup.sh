
#############################
#                           #
#   Latest Edit             #
#                           #
# -Apr 1 2021 Version 1     #
# Change A10 v1.2 to v1.2.1 #
#                           #
#                           #
#                           #
#############################



#global variables
red=$'\e[1;31m'
blu=$'\e[1;34m'
end=$'\e[0m'
ARRIA10DEVSTACK_RELEASE=("1.2" "1.2.1")
#noHardwareNodes=("s001-n039" "s001-n040" "s001-n041" "s001-n042" "s001-n043" "s001-n044" "s001-n045")
#Replaced with fpga_compile
noHardwareNodes=("s001-n045" "s001-n046" "s001-n047" "s001-n048" "s001-n049" "s001-n050" "s001-n051" "s001-n052" "s001-n053" "s001-n054" "s001-n055" "s001-n056" "s001-n057" "s001-n058" "s001-n059" "s001-n060" "s001-n061" "s001-n062" "s001-n063" "s001-n064" "s001-n065" "s001-n066" "s001-n067" "s001-n068" "s001-n069" "s001-n070" "s001-n072" "s001-n073" "s001-n074" "s001-n075" "s001-n076" "s001-n077" "s001-n078" "s001-n079" "s001-n080")
arria10Nodes=("s005-n001" "s005-n002" "s005-n003" "s005-n004" "s005-n007" "s001-n137" "s001-n138" "s001-n139")
arria10Nodes12=()
arria10Nodes121=("s001-n137" "s001-n138" "s001-n139" "s005-n001" "s005-n002" "s005-n003" "s005-n004" "s005-n007")
arria10_oneAPI_Nodes=("s001-n081" "s001-n082" "s001-n083" "s001-n084" "s001-n085" "s001-n086" "s001-n087" "s001-n088" "s001-n089" "s001-n090" "s001-n091" "s001-n092")
stratix10Nodes=("s005-n005" "s005-n006" "s005-n008" "s005-n009" "s001-n189")
stratix10_oneAPI_Nodes=("s001-n142" "s001-n143" "s001-n144")
allNodes=( "${noHardwareNodes[@]}" "${arria10Nodes[@]}" "${arria10_oneAPI_Nodes[@]}" "${stratix10Nodes[@]}" "${stratix10_oneAPI_Nodes[@]}" )

x2goNodes=("s001-n137" "s001-n138" "s001-n139" "s005-n002" "s005-n003" "s005-n004" "s005-n005" "s005-n006" "s005-n007" "s005-n008")


devcloud_login()
{
    interactive_nodeusage=`ps -auwx | grep "qsub.*-I" | grep -v "grep" | wc -l`
    name_node=`ps -auwx | grep "qsub.*-I" | awk '{print $16}'`
 
    if [[ $1 =~ "-h" ]]; then
	# display Help
	dev_Help
	return 0
    elif [[ $1 == "-l" && -z $2 ]]; then
	argv1="SNN"
	unset argv2 argv3 argv4
    elif [ $HOSTNAME != "login-2" ]; then
	# check to see if user is logged into a compute node already
	echo "Your hostname is not login-2. You are probably already logged into a compute node. Exit node in order to log into headnode."
        return 1
    elif [ $interactive_nodeusage -ne 0 ]; then
	# check to see if user is already logged into a compute node and is currently at the headnode
	echo "You are already logged into node ${name_node:6:10} interactively."
	return 1
    elif [[ $1 == "-I" && -n $2 ]]; then
	argv1="$2"
	argv2="$3"
	unset argv3 argv4
    elif [[ $1 == "-b" && -n $2 ]]; then
	argv1="$2"
	argv2="$3"
	argv3="$4"
	argv4="$5"
    elif [ -z $1 ]; then
        unset argv1 argv2 argv3 argv4
    else
        echo "${red}Invalid Argument. Try 'devcloud_login --help' for more information.${end}"
        return 0
    fi

    if [ -z $argv1 ]; then
	echo
	printf "%s\n%s\n" "You are selecting an interactive compute server sesssion. Please consider using batch mode submission using" "devcloud_login -b to not tie up compute servers with idle sessions."
	echo "See the help menu using devcloud_login -h for more details."
	echo
	printf "%s\n" "${blu}What are you trying to use the Devcloud for? ${end}"
	echo
	echo "1) Arria 10 PAC Compilation and Programming - RTL AFU, OpenCL"
	echo "2) Arria 10 - OneAPI, OpenVINO"
	echo "3) Stratix 10 PAC Compilation and Programming - RTL AFU, OpenCL"
	echo "4) Stratix 10 - OneAPI, OpenVINO"
	echo "5) Compilation (Command Line) Only"
	echo "6) Enter Specific Node Number"
	echo
	echo -n "Number: "
	read -e number
	until [ "$number" -eq 1 ] || [ "$number" -eq 2 ] || [ "$number" -eq 3 ] || [ "$number" -eq 4 ] || [ "$number" -eq 5 ] || [ "$number" -eq 6 ];
	do
	    printf "%s\n" "${red}Invalid Entry. Please input a correct number from the list above. ${end} "
	    echo -n "Number: "
	    read -e number
	done
    fi

    IFS="|"
    currentNode="$(echo $HOSTNAME | grep -o -E "${allNodes[*]}")"
    unset IFS

    if [[ $number -eq 1 || ( -n $argv1 && $argv1 == "A10PAC" ) ]]; then
        if [ -z $currentNode ]; then  #if current node is empty
            #pbsnodes -s v-qsvr-fpga | grep -B 4 'arria10' | grep -B 1 "state = free"| grep -B 1 '13[0-9]' | grep -o '...$' > ~/nodes.txt
            #node=$(head -n 1 nodes.txt)
	    if [ -z "$argv1" ]; then
            	# ask which version of a10 devstack
            	echo "${blu}Which Arria 10 PAC Development Stack release would you like to source?${end}"
            	for (( i=0; i<${#ARRIA10DEVSTACK_RELEASE[@]}; i++)); do
                    echo "${i}) ${ARRIA10DEVSTACK_RELEASE[$i]}"
            	done
            	echo
            	echo -n "Number: "
            	read -e second_number
            	until [ ${#ARRIA10DEVSTACK_RELEASE[@]} -gt $second_number ]; do
                    printf "%s\n" "${red}Invalid Entry. Please input a correct number from the list above. ${end}"
                    echo -n "Number: "
                    read -e second_number
            	done
	    elif [[ -n "$argv2" && ${ARRIA10DEVSTACK_RELEASE[0]} =~ "$argv2" ]]; then
		second_number=0
	    elif [[ -n "$argv2" && ${ARRIA10DEVSTACK_RELEASE[1]} =~ "$argv2" ]]; then
		second_number=1
	    else
                printf "%s\n%s\n" "${red}Invalid Entry. Valid development stack options are: ${ARRIA10DEVSTACK_RELEASE[*]}" "eg: devcloud_login -I A10PAC ${ARRIA10DEVSTACK_RELEASE[0]} ${end}"
		return 0
	    fi

	    if [ $second_number -eq 0 ]; then
            	IFS="|"
            	readarray availableNodes < <(pbsnodes -s v-qsvr-fpga | grep -B 4 'arria10' | grep -B 1 "state = free" | grep -o -E "${arria10Nodes12[*]}")
            	readarray availableNodes_on_temp_server < <(pbsnodes | grep -B 4 'arria10' | grep -B 1 "state = free" | grep -o -E "${arria10Nodes12[*]}")
           	availableNodes=( "${availableNodes[@]}" "${availableNodes_on_temp_server[@]}" )
            	unset IFS
	    else
            	IFS="|"
            	readarray availableNodes < <(pbsnodes -s v-qsvr-fpga | grep -B 4 'arria10' | grep -B 1 "state = free" | grep -o -E "${arria10Nodes121[*]}")
            	readarray availableNodes_on_temp_server < <(pbsnodes | grep -B 4 'arria10' | grep -B 1 "state = free" | grep -o -E "${arria10Nodes121[*]}")
           	availableNodes=( "${availableNodes[@]}" "${availableNodes_on_temp_server[@]}" )
            	unset IFS
	    fi

            if [ ${#availableNodes[@]} == 0 ]; then #if length of availableNodes is empty then no nodes are available
                echo
                printf "%s\n" "${red}--------------------------------------------------------------- ${end} "
                printf "%s\n" "${red}No available nodes for this hardware. Please select a new node. ${end} "
                printf "%s\n" "${red}--------------------------------------------------------------- ${end} "
                devcloud_login
	    elif [[ -n "$argv3" && $argv3 =~ ".sh" ]]; then
		node=(${availableNodes[0]})
		qsub -q batch@v-qsvr-fpga -l nodes="$node":ppn=2 $argv3
	    elif [[ -n "$argv3" && $argv3 =~ "walltime=" && $argv4 =~ ".sh" ]]; then
		node=(${availableNodes[0]})
		qsub -q batch@v-qsvr-fpga -l nodes="$node":ppn=2 -l $argv3 $argv4
	    else
                node=(${availableNodes[-1]})
		if [[ ${x2goNodes[*]} =~ "$node" ]]; then
                    echo
                    echo --------------------------------------------------------------------------------------
		    printf "%s\n" "${blu}For X2GO tunneling access. For users connected to intel firewall, copy and paste the following text in a new mobaxterm terminal: ${end} "
                    echo
                    printf  "%s\n" "${blu}ssh -L 4002:"$node":22 colfax-intel${end} "
                    echo
                    printf "%s\n" "${blu}For X2GO tunneling access. For users NOT connected to intel firewall, copy and paste the following text in a new mobaxterm terminal: ${end} "
                    echo
                    printf  "%s\n" "${blu}ssh -L 4002:"$node":22 devcloud${end} "
                    echo
                    echo --------------------------------------------------------------------------------------
                    echo
		fi
                echo "running: qsub -q batch@v-qsvr-fpga -I -l nodes="$node":ppn=2"
                qsub -q batch@v-qsvr-fpga -I -l nodes="$node":ppn=2
            fi
        else
            printf "%s\n" "${red}You are currently on a compute node. Please exit node and try again.${end}"
        fi
    elif [[ $number -eq 2 || ( -n $argv1 && $argv1 == "A10OAPI" ) ]]; then
        if [ -z $currentNode ]; then  #if current node is empty
            IFS="|"
            readarray availableNodes < <(pbsnodes -s v-qsvr-fpga | grep -B 4 'arria10' | grep -B 4 'fpga_runtime' | grep -B 1 "state = free" | grep -o -E "${arria10_oneAPI_Nodes[*]}")
            readarray availableNodes_on_temp_server < <(pbsnodes | grep -B 4 'arria10' | grep -B 4 'fpga_runtime' | grep -B 1 "state = free" | grep -o -E "${arria10_oneAPI_Nodes[*]}")
            availableNodes=( "${availableNodes[@]}" "${availableNodes_on_temp_server[@]}" )
            unset IFS
            if [ ${#availableNodes[@]} == 0 ]; #if length of availableNodes is empty then no nodes are available
            then
                echo
                echo
                printf "%s\n" "${red}--------------------------------------------------------------- ${end} "
                printf "%s\n" "${red}No available nodes for this hardware. Please select a new node. ${end} "
                printf "%s\n" "${red}--------------------------------------------------------------- ${end} "
                devcloud_login
	    elif [[ -n "$argv2" && $argv2 =~ ".sh" ]]; then
		node=(${availableNodes[0]})
		qsub -l nodes="$node":ppn=2 $argv2
	    elif [[ -n "$argv2" && $argv2 =~ "walltime=" && $argv3 =~ ".sh" ]]; then
		node=(${availableNodes[0]})
		qsub -l nodes="$node":ppn=2 -l $argv2 $argv3
            else
                node=(${availableNodes[0]})
		if [[ ${x2goNodes[*]} =~ "$node" ]]; then
                    echo
                    echo --------------------------------------------------------------------------------------
                    printf "%s\n" "${blu}For X2GO tunneling access. For users connected to intel firewall, copy and paste the following text in a new mobaxterm terminal: ${end} "
                    echo
                    printf  "%s\n" "${blu}ssh -L 4002:"$node":22 colfax-intel${end} "
                    echo
                    printf "%s\n" "${blu}For X2GO tunneling access. For users NOT connected to intel firewall, copy and paste the following text in a new mobaxterm terminal: ${end} "
                    echo
                    printf  "%s\n" "${blu}ssh -L 4002:"$node":22 devcloud${end} "
                    echo
                    echo --------------------------------------------------------------------------------------
                    echo
		fi
                echo "running: qsub -I -l nodes="$node":ppn=2"
                qsub -I -l nodes="$node":ppn=2
            fi
        else
            printf "%s\n" "${red}You are currently on a compute node. Please exit node and try again.${end}"
        fi
    elif [[ $number -eq 3 || ( -n $argv1 && $argv1 == "S10PAC" ) ]]; then
        if [ -z $currentNode ]; then
            IFS="|"
            #readarray availableNodes < <(pbsnodes -s v-qsvr-fpga | grep -B 4 'darby' | grep -B 1 "state = free" | grep -o -E "${stratix10Nodes[*]}")
            readarray availableNodes_no_darby_tag < <(pbsnodes -s v-qsvr-fpga | grep -B 1 "state = free" | grep -o -E "${stratix10Nodes[*]}")
            readarray availableNodes_on_temp_server < <(pbsnodes | grep -B 4 'darby' | grep -B 1 "state = free" | grep -o -E "${stratix10Nodes[*]}")
            #availableNodes=( "${availableNodes[@]}" "${availableNodes_on_temp_server[@]}" )
            availableNodes=( "${availableNodes_on_temp_server[@]}" "${availableNodes_no_darby_tag[@]}" )
            unset IFS
            if [ ${#availableNodes[@]} == 0 ]; #if length of availableNodes is empty then no nodes are available
            then
                echo
                echo
                printf "%s\n" "${red}--------------------------------------------------------------- ${end} "
                printf "%s\n" "${red}No available nodes for this hardware. Please select a new node. ${end} "
                printf "%s\n" "${red}--------------------------------------------------------------- ${end} "
                devcloud_login
	    elif [[ -n "$argv2" && $argv2 =~ ".sh" ]]; then
		node=(${availableNodes[0]})
		qsub -q batch@v-qsvr-fpga -l nodes="$node":ppn=2 $argv2
	    elif [[ -n "$argv2" && $argv2 =~ "walltime=" && $argv3 =~ ".sh" ]]; then
		node=(${availableNodes[0]})
		qsub -q batch@v-qsvr-fpga -l nodes="$node":ppn=2 -l $argv2 $argv3
            else
                node=(${availableNodes[0]})
		if [[ ${x2goNodes[*]} =~ "$node" ]]; then
                    echo
                    echo --------------------------------------------------------------------------------------
		    printf "%s\n" "${blu}For X2GO tunneling access. If connected to intel firewall, copy and paste the following text in a new mobaxterm terminal: ${end} "
                    echo
                    printf  "%s\n" "${blu}ssh -L 4002:"$node":22 colfax-intel${end} "
                    echo
                    printf "%s\n" "${blu}For X2GO tunneling access. For users NOT connected to intel firewall, copy and paste the following text in a new mobaxterm terminal: ${end} "
                    echo
                    printf  "%s\n" "${blu}ssh -L 4002:"$node":22 devcloud${end} "
                    echo --------------------------------------------------------------------------------------
                    echo
		fi
                echo "running: qsub -q batch@v-qsvr-fpga -I -l nodes="$node":ppn=2"
                qsub -q batch@v-qsvr-fpga -I -l nodes="$node":ppn=2
            fi
        else
            printf "%s\n" "${red}You are currently on a node. Please exit the current node and try again.${end}"
        fi
    elif [[ $number -eq 4 || ( -n $argv1 && $argv1 == "S10OAPI" ) ]]; then
        if [ -z $currentNode ]; then  #if current node is empty
            IFS="|"
            readarray availableNodes < <(pbsnodes -s v-qsvr-fpga | grep -B 4 'stratix10' | grep -B 4 'fpga_runtime' | grep -B 1 "state = free" | grep -o -E "${stratix10_oneAPI_Nodes[*]}")
            readarray availableNodes_on_temp_server < <(pbsnodes | grep -B 4 'stratix10' | grep -B 4 'fpga_runtime' | grep -B 1 "state = free" | grep -o -E "${stratix10_oneAPI_Nodes[*]}")
            availableNodes=( "${availableNodes[@]}" "${availableNodes_on_temp_server[@]}" )
            unset IFS
            if [ ${#availableNodes[@]} == 0 ]; #if length of availableNodes is empty then no nodes are available
            then
                echo
                echo
                printf "%s\n" "${red}--------------------------------------------------------------- ${end} "
                printf "%s\n" "${red}No available nodes for this hardware. Please select a new node. ${end} "
                printf "%s\n" "${red}--------------------------------------------------------------- ${end} "
                devcloud_login
	    elif [[ -n "$argv2" && $argv2 =~ ".sh" ]]; then
		node=(${availableNodes[0]})
		qsub -l nodes="$node":ppn=2 $argv2
	    elif [[ -n "$argv2" && $argv2 =~ "walltime=" && $argv3 =~ ".sh" ]]; then
		node=(${availableNodes[0]})
		qsub -l nodes="$node":ppn=2 -l $argv2 $argv3
            else
                node=(${availableNodes[0]})
		if [[ ${x2goNodes[*]} =~ "$node" ]]; then
                    echo
                    echo --------------------------------------------------------------------------------------
                    printf "%s\n" "${blu}For X2GO tunneling access. For users connected to intel firewall, copy and paste the following text in a new mobaxterm terminal: ${end} "
                    echo
                    printf  "%s\n" "${blu}ssh -L 4002:"$node":22 colfax-intel${end} "
                    echo
                    printf "%s\n" "${blu}For X2GO tunneling access. For users NOT connected to intel firewall, copy and paste the following text in a new mobaxterm terminal: ${end} "
                    echo
                    printf  "%s\n" "${blu}ssh -L 4002:"$node":22 devcloud${end} "
                    echo
                    echo --------------------------------------------------------------------------------------
                    echo
		fi
                echo "running: qsub -I -l nodes="$node":ppn=2"
                qsub -I -l nodes="$node":ppn=2
            fi
        else
            printf "%s\n" "${red}You are currently on a compute node. Please exit node and try again.${end}"
        fi
    elif [[ $number -eq 5 || ( -n $argv1 && $argv1 == "CO" ) ]]; then
        if [ -z $currentNode ]; then
            IFS="|"
            # readarray availableNodes < <(pbsnodes -s v-qsvr-fpga | grep -B 1 "state = free" | grep -o -E "${noHardwareNodes[*]}")
            # readarray availableNodes_on_temp_server < <(pbsnodes | grep -B 1 "state = free" | grep -o -E "${noHardwareNodes[*]}")
            # availableNodes=( "${availableNodes[@]}" "${availableNodes_on_temp_server[@]}" )
            readarray availableNodes < <(pbsnodes -a | grep -B 4 'fpga_compile' | grep -B 1 "state = free" | grep -o -E "${noHardwareNodes[*]}")
            unset IFS
            if [ ${#availableNodes[@]} == 0 ]; then #if length of availableNodes is empty then no nodes are available
                echo
                echo
                printf "%s\n" "${red}--------------------------------------------------------------- ${end} "
                printf "%s\n" "${red}No available nodes for this hardware. Please select a new node. ${end} "
                printf "%s\n" "${red}--------------------------------------------------------------- ${end} "
                devcloud_login
	    elif [[ -n "$argv2" && $argv2 =~ ".sh" ]]; then
		node=(${availableNodes[0]})
		qsub -l nodes="$node":ppn=2 $argv2
	    elif [[ -n "$argv2" && $argv2 =~ "walltime=" && $argv3 =~ ".sh" ]]; then
		node=(${availableNodes[0]})
		qsub -l nodes="$node":ppn=2 -l $argv2 $argv3
            else
                node=(${availableNodes[0]})
		if [[ ${x2goNodes[*]} =~ "$node" ]]; then
                    echo
                    echo --------------------------------------------------------------------------------------
                    printf "%s\n" "${blu}For X2GO tunneling access. If connected to intel firewall, copy and paste the following text in a new mobaxterm terminal: ${end} "
                    echo
                    printf  "%s\n" "${blu}ssh -L 4002:"$node":22 colfax-intel${end} "
                    echo
                    printf "%s\n" "${blu}For X2GO tunneling access. For users NOT connected to intel firewall, copy and paste the following text in a new mobaxterm terminal: ${end} "
                    echo
                    printf  "%s\n" "${blu}ssh -L 4002:"$node":22 devcloud${end} "
                    echo --------------------------------------------------------------------------------------
                    echo
		fi
                echo "running: qsub -I -l nodes="$node":ppn=2"
                qsub -I -l nodes="$node":ppn=2
            fi
        else
            printf "%s\n" "${red}You are currently on a compute node. Please exit node and try again.${end}"
        fi
    elif [[ $number -eq 6 || ( -n $argv1 && $argv1 == "SNN" ) ]]; then
        if [ -z $currentNode ]; then
            IFS="|"
            readarray availableNodesNohardware < <(pbsnodes -a | grep -B 4 'fpga_compile' | grep -B 1 "state = free" | grep -o -E "${noHardwareNodes[*]}")
            readarray availableNodesArria < <(pbsnodes -s v-qsvr-fpga | grep -B 4 'arria10' | grep -B 1 "state = free" | grep -o -E "${arria10Nodes[*]}")
            readarray availableNodesArria_on_temp_server < <(pbsnodes | grep -B 4 'arria10' | grep -B 1 "state = free" | grep -o -E "${arria10Nodes[*]}")
            readarray availableNodesArria12 < <(pbsnodes -s v-qsvr-fpga | grep -B 4 'arria10' | grep -B 1 "state = free" | grep -o -E "${arria10Nodes12[*]}")
            readarray availableNodesArria12_on_temp_server < <(pbsnodes | grep -B 4 'arria10' | grep -B 1 "state = free" | grep -o -E "${arria10Nodes12[*]}")
            readarray availableNodesArria121 < <(pbsnodes -s v-qsvr-fpga | grep -B 4 'arria10' | grep -B 1 "state = free" | grep -o -E "${arria10Nodes121[*]}")
            readarray availableNodesArria121_on_temp_server < <(pbsnodes | grep -B 4 'arria10' | grep -B 1 "state = free" | grep -o -E "${arria10Nodes121[*]}")
            readarray availableNodesArria10_oneAPI_Nodes < <(pbsnodes -s v-qsvr-fpga | grep -B 4 'arria10' | grep -B 4 'fpga_runtime' | grep -B 1 "state = free" | grep -o -E "${arria10_oneAPI_Nodes[*]}")
            readarray availableNodesArria10_oneAPI_Nodes_on_temp_server < <(pbsnodes | grep -B 4 'arria10' | grep -B 4 'fpga_runtime' | grep -B 1 "state = free" | grep -o -E "${arria10_oneAPI_Nodes[*]}")
            #readarray availableNodesStratix < <(pbsnodes -s v-qsvr-fpga | grep -B 4 'darby' | grep -B 1 "state = free"  | grep -o -E "${stratix10Nodes[*]}")
            readarray availableNodes_no_darby_tag < <(pbsnodes -s v-qsvr-fpga | grep -B 1 "state = free" | grep -o -E "${stratix10Nodes[*]}")
            readarray availableNodesStratix_on_temp_server < <(pbsnodes | grep -B 4 'darby' | grep -B 1 "state = free"  | grep -o -E "${stratix10Nodes[*]}")
            readarray availableNodesStratix10_oneAPI_Nodes < <(pbsnodes -s v-qsvr-fpga | grep -B 4 'stratix10' | grep -B 4 'fpga_runtime' | grep -B 1 "state = free" | grep -o -E "${stratix10_oneAPI_Nodes[*]}")
            readarray availableNodesStratix10_oneAPI_Nodes_on_temp_server < <(pbsnodes | grep -B 4 'stratix10' | grep -B 4 'fpga_runtime' | grep -B 1 "state = free" | grep -o -E "${stratix10_oneAPI_Nodes[*]}")
            unset IFS
            let number_of_available_no_hardware_nodes=${#availableNodesNohardware[@]}
            let number_of_available_arria10_nodes=${#availableNodesArria[@]}+${#availableNodesArria_on_temp_server[@]}
            let number_of_available_arria10_oneAPI_nodes=${#availableNodesArria10_oneAPI_Nodes[@]}+${#availableNodesArria10_oneAPI_Nodes_on_temp_server[@]}
            #let number_of_available_stratix10_nodes=${#availableNodesStratix[@]}+${#availableNodesStratix_on_temp_server[@]}
            let number_of_available_stratix10_nodes=${#availableNodesStratix_on_temp_server[@]}+${#availableNodes_no_darby_tag[@]}
            let number_of_available_stratix10_oneAPI_nodes=${#availableNodesStratix10_oneAPI_Nodes[@]}+${#availableNodesStratix10_oneAPI_Nodes_on_temp_server[@]}

            availableNodes=( "${availableNodesNohardware[@]}" "${availableNodesArria[@]}" \ #"${availableNodesStratix[@]}" \
                "${availableNodesArria_on_temp_server[@]}" "${availableNodesStratix_on_temp_server[@]}" "${availableNodesArria10_oneAPI_Nodes[@]}" \
		"${availableNodesArria10_oneAPI_Nodes_on_temp_server[@]}" "${availableNodes_no_darby_tag[@]}" "${availableNodesStratix10_oneAPI_Nodes[@]}" \
		"${availableNodesStratix10_oneAPI_Nodes_on_temp_server[@]}" )

            if [ ${#availableNodes[@]} == 0 ]; then
                echo
                echo
                printf "%s\n" "${red}--------------------------------------------------------------- ${end} "
                printf "%s\n" "${red}No available nodes. Try again later. ${end} "
                printf "%s\n" "${red}--------------------------------------------------------------- ${end} "
	    elif [[ -n "$argv2" && ${availableNodes[*]} =~ "$argv2" ]]; then
		node="$argv2"
                # find out if the nodeNumber is on the fpga queue to know which qsub command to call
                is_in_fpga_queue="$(pbsnodes -s v-qsvr-fpga | grep -B 4 fpga | grep -o $node )"
                if [ -z $is_in_fpga_queue ]; then  # if is_in_fpga_queue is empty then it is not on the fpga queue
		    if [[ -n "$argv3" && $argv3 =~ ".sh" ]]; then
			qsub -l nodes="$node":ppn=2 $argv3
	    	    elif [[ -n "$argv3" && $argv3 =~ "walltime=" && $argv4 =~ ".sh" ]]; then
			qsub -l nodes="$node":ppn=2 -l $argv3 $argv4
		    else
			if [[ ${x2goNodes[*]} =~ "$node" ]]; then
                            echo
                            echo --------------------------------------------------------------------------------------
                            printf "%s\n" "${blu}For X2GO tunneling access. If connected to intel firewall, copy and paste the following text in a new mobaxterm terminal: ${end} "
                            echo
                            printf  "%s\n" "${blu}ssh -L 4002:"$node":22 colfax-intel${end} "
                            echo
                            printf "%s\n" "${blu}For X2GO tunneling access. For users NOT connected to intel firewall, copy and paste the following text in a new mobaxterm terminal: ${end} "
                            echo
                            printf  "%s\n" "${blu}ssh -L 4002:"$node":22 devcloud${end} "
                            echo --------------------------------------------------------------------------------------
                            echo
			fi
                        echo "running: qsub -I -l nodes="$node":ppn=2"
                        qsub -I -l nodes="$node":ppn=2
		    fi
                else
		    if [[ -n "$argv3" && $argv3 =~ ".sh" ]]; then
			qsub -q batch@v-qsvr-fpga -l nodes="$node":ppn=2 $argv3
	    	    elif [[ -n "$argv3" && $argv3 =~ "walltime=" && $argv4 =~ ".sh" ]]; then
			qsub -l nodes="$node":ppn=2 -l $argv3 $argv4
		    else
			if [[ ${x2goNodes[*]} =~ "$node" ]]; then
                            echo
                            echo --------------------------------------------------------------------------------------
                            printf "%s\n" "${blu}For X2GO tunneling access. If connected to intel firewall, copy and paste the following text in a new mobaxterm terminal: ${end} "
                            echo
                            printf  "%s\n" "${blu}ssh -L 4002:"$node":22 colfax-intel${end} "
                            echo
                            printf "%s\n" "${blu}For X2GO tunneling access. For users NOT connected to intel firewall, copy and paste the following text in a new mobaxterm terminal: ${end} "
                            echo
                            printf  "%s\n" "${blu}ssh -L 4002:"$node":22 devcloud${end} "
                            echo --------------------------------------------------------------------------------------
                            echo
			fi
                        echo "running: qsub -q batch@v-qsvr-fpga -I -l nodes="$node":ppn=2"
                        qsub -q batch@v-qsvr-fpga -I -l nodes="$node":ppn=2
		    fi
                fi
	    elif [[ -n "$argv2" ]]; then
		printf "%s\n%s\n" "${red}Invalid Entry. Available nodes are: ${availableNodes[*]}" "eg: devcloud_login -b SNN ${availableNodes[0]}${end}"
	    elif [[ -n "$argv1" && -z "$argv2" ]]; then
                echo "Showing available nodes below: (${#availableNodes[@]} available/${#allNodes[@]} total)"
                echo --------------------------------------------------------------------------------------
                printf "%s\n" "${blu}Nodes with no attached hardware:${end} (${number_of_available_no_hardware_nodes} available/${#noHardwareNodes[@]} total)"
                node_no_hardware_str=$(echo ${availableNodesNohardware[@]})
                printf "${red}$node_no_hardware_str${end}"
                echo 
                echo --------------------------------------------------------------------------------------
                printf "%s\n" "${blu}Nodes with Arria 10:${end} (${number_of_available_arria10_nodes} available/${#arria10Nodes[@]} total)"
		#node_arria10_str=$(echo ${availableNodesArria[@]} ${availableNodesArria_on_temp_server[@]})
                #printf "${red}$node_arria10_str${end}"
                echo "Release 1.2:"
		node_arria10_12str=$(echo ${availableNodesArria12[@]} ${availableNodesArria12_on_temp_server[@]})
                printf "${red}$node_arria10_12str${end}"
                echo
                echo "Release 1.2.1:"
		node_arria10_121str=$(echo ${availableNodesArria121[@]} ${availableNodesArria121_on_temp_server[@]})
                printf "${red}$node_arria10_121str${end}"
                echo
                echo --------------------------------------------------------------------------------------
                printf "%s\n" "${blu}Nodes with Arria 10 OneAPI:${end} (${number_of_available_arria10_oneAPI_nodes} available/${#arria10_oneAPI_Nodes[@]} total)"
                node_arria10_oneAPI_str=$(echo ${availableNodesArria10_oneAPI_Nodes[@]} ${availableNodesArria10_oneAPI_Nodes_on_temp_server[@]})
                printf "${red}$node_arria10_oneAPI_str${end}"
                echo 
                echo --------------------------------------------------------------------------------------
                printf "%s\n" "${blu}Nodes with Stratix 10:${end} (${number_of_available_stratix10_nodes} available/${#stratix10Nodes[@]} total)"
                #node_stratix_str=$(echo ${availableNodesStratix[@]} ${availableNodesStratix_on_temp_server[@]})
                node_stratix_str=$(echo ${availableNodesStratix_on_temp_server[@]} ${availableNodes_no_darby_tag[@]})
                printf "${red}$node_stratix_str${end}"
                echo
                echo --------------------------------------------------------------------------------------
                printf "%s\n" "${blu}Nodes with Stratix 10 OneAPI:${end} (${number_of_available_stratix10_oneAPI_nodes} available/${#stratix10_oneAPI_Nodes[@]} total)"
                node_stratix10_oneAPI_str=$(echo ${availableNodesStratix10_oneAPI_Nodes[@]} ${availableNodesStratix10_oneAPI_Nodes_on_temp_server[@]})
                printf "${red}$node_stratix10_oneAPI_str${end}"
                echo 
                echo --------------------------------------------------------------------------------------
            else
                echo "Showing available nodes below: (${#availableNodes[@]} available/${#allNodes[@]} total)"
                echo --------------------------------------------------------------------------------------
                printf "%s\n" "${blu}Nodes with no attached hardware:${end} (${number_of_available_no_hardware_nodes} available/${#noHardwareNodes[@]} total)"
                #node_no_hardware_str=$(echo ${availableNodesNohardware[@]} ${availableNodesNohardware_on_temp_server[@]})
                node_no_hardware_str=$(echo ${availableNodesNohardware[@]})
                printf "${red}$node_no_hardware_str${end}"
                echo 
                echo --------------------------------------------------------------------------------------
                printf "%s\n" "${blu}Nodes with Arria 10:${end} (${number_of_available_arria10_nodes} available/${#arria10Nodes[@]} total)"
		#node_arria10_str=$(echo ${availableNodesArria[@]} ${availableNodesArria_on_temp_server[@]})
                #printf "${red}$node_arria10_str${end}"
                echo "Release 1.2:"
		node_arria10_12str=$(echo ${availableNodesArria12[@]} ${availableNodesArria12_on_temp_server[@]})
                printf "${red}$node_arria10_12str${end}"
                echo
                echo "Release 1.2.1:"
		node_arria10_121str=$(echo ${availableNodesArria121[@]} ${availableNodesArria121_on_temp_server[@]})
                printf "${red}$node_arria10_121str${end}"
                echo
                echo --------------------------------------------------------------------------------------
                printf "%s\n" "${blu}Nodes with Arria 10 OneAPI:${end} (${number_of_available_arria10_oneAPI_nodes} available/${#arria10_oneAPI_Nodes[@]} total)"
                node_arria10_oneAPI_str=$(echo ${availableNodesArria10_oneAPI_Nodes[@]} ${availableNodesArria10_oneAPI_Nodes_on_temp_server[@]})
                printf "${red}$node_arria10_oneAPI_str${end}"
                echo 
                echo --------------------------------------------------------------------------------------
                printf "%s\n" "${blu}Nodes with Stratix 10:${end} (${number_of_available_stratix10_nodes} available/${#stratix10Nodes[@]} total)"
                #node_stratix_str=$(echo ${availableNodesStratix[@]} ${availableNodesStratix_on_temp_server[@]})
                node_stratix_str=$(echo ${availableNodesStratix_on_temp_server[@]} ${availableNodes_no_darby_tag[@]})
                printf "${red}$node_stratix_str${end}"
                echo
                echo --------------------------------------------------------------------------------------
                printf "%s\n" "${blu}Nodes with Stratix 10 OneAPI:${end} (${number_of_available_stratix10_oneAPI_nodes} available/${#stratix10_oneAPI_Nodes[@]} total)"
                node_stratix10_oneAPI_str=$(echo ${availableNodesStratix10_oneAPI_Nodes[@]} ${availableNodesStratix10_oneAPI_Nodes_on_temp_server[@]})
                printf "${red}$node_stratix10_oneAPI_str${end}"
                echo 
                echo --------------------------------------------------------------------------------------
                echo
                echo "What node would you like to use?"
                echo
                echo -n "Node: "
                read -e node
                until  [[ ${availableNodes[@]} =~ ${node} && ${#node} -eq 9 ]] #this checks that user input is an available node and node has length of 9
                do
                    printf "%s\n" "${red}Please input an available node number: ${end}"
                    echo -n "Node: "
                    read -e node
                done

                # find out if the nodeNumber is on the fpga queue to know which qsub command to call
                is_in_fpga_queue="$(pbsnodes -s v-qsvr-fpga | grep -B 4 fpga | grep -o $node )"
                if [ -z $is_in_fpga_queue ];  # if is_in_fpga_queue is empty then it is not on the fpga queue
                then
		    if [[ ${x2goNodes[*]} =~ "$node" ]]; then
                    	echo
                    	echo --------------------------------------------------------------------------------------
                    	printf "%s\n" "${blu}For X2GO tunneling access. If connected to intel firewall, copy and paste the following text in a new mobaxterm terminal: ${end} "
                    	echo
                    	printf  "%s\n" "${blu}ssh -L 4002:"$node":22 colfax-intel${end} "
                    	echo
                    	printf "%s\n" "${blu}For X2GO tunneling access. For users NOT connected to intel firewall, copy and paste the following text in a new mobaxterm terminal: ${end} "
                    	echo
                    	printf  "%s\n" "${blu}ssh -L 4002:"$node":22 devcloud${end} "
                    	echo --------------------------------------------------------------------------------------
                    	echo
		    fi
                    echo "running: qsub -I -l nodes="$node":ppn=2"
                    qsub -I -l nodes="$node":ppn=2
                else		
		    if [[ ${x2goNodes[*]} =~ "$node" ]]; then
                    	echo
                    	echo --------------------------------------------------------------------------------------
                    	printf "%s\n" "${blu}For X2GO tunneling access. If connected to intel firewall, copy and paste the following text in a new mobaxterm terminal: ${end} "
                    	echo
                    	printf  "%s\n" "${blu}ssh -L 4002:"$node":22 colfax-intel${end} "
                    	echo
                    	printf "%s\n" "${blu}For X2GO tunneling access. For users NOT connected to intel firewall, copy and paste the following text in a new mobaxterm terminal: ${end} "
                    	echo
                    	printf  "%s\n" "${blu}ssh -L 4002:"$node":22 devcloud${end} "
                    	echo --------------------------------------------------------------------------------------
                    	echo
		    fi
                    echo "running: qsub -q batch@v-qsvr-fpga -I -l nodes="$node":ppn=2"
                    qsub -q batch@v-qsvr-fpga -I -l nodes="$node":ppn=2
                fi
            fi
        else
            printf "%s\n" "${red}You are currently on a compute node. Please exit node and try again from headnode.${end}"
        fi
    fi
}


qstatus()	
{	
    #display the status of all jobs currently running and queued	
    qstat -s batch@v-qsvr-fpga
    qstat -s
}


error_check()
{
    if [ $? -ne 0 ]; then
	echo failed
	exit
    else
	:  #do nothing
    fi
}


tools_setup()
{
    QUARTUS_LITE_RELEASE=("18.1")
    QUARTUS_STANDARD_RELEASE=("18.1")
    QUARTUS_PRO_RELEASE=("17.1" "18.1" "19.2" "19.3" "20.1")
    #ARRIA10DEVSTACK_RELEASE=("1.2" "1.2.1")

    #defined paths
    GLOB_INTELFPGA_PRO="/glob/development-tools/versions/intelFPGA_pro"
    GLOB_INTELFPGA_LITE="/glob/development-tools/versions/intelFPGA_lite"
    GLOB_INTELFPGA_STANDARD="/glob/development-tools/versions/intelFPGA"
    QUARTUS_PATHS=($GLOB_INTELFPGA_LITE $GLOB_INTELFPGA_STANDARD $GLOB_INTELFPGA_PRO)
    OPT_INTEL="/opt/intel"
    OPT_INTEL_2="/opt/intel/2.0.1"
    GLOB_FPGASUPPORTSTACK="/glob/development-tools/versions/fpgasupportstack"
    #GLOB_ONEAPI="/glob/development-tools/versions/oneapi"


    if [[ $1 =~ "-h" ]]; then
	# display Help
	tool_Help ${QUARTUS_LITE_RELEASE[@]} ${QUARTUS_STANDARD_RELEASE[@]} ${QUARTUS_PRO_RELEASE[@]}
	return 0
    elif [ $HOSTNAME == "login-2" ]; then
	# check to see if user is logged into headnode
	echo "Your hostname is login-2. Please login to a compute node to be able to use 'tools_setup' command"
        return 1
    elif [[ $1 == "-t" && -n $2 ]]; then
	argv1="$2"
	argv2="$3"
	argv3="$4"
    elif [ -z $1 ]; then
        unset argv1 argv2 argv3
    else
        echo "${red}Invalid Argument. Try 'tools_setup --help' for more information.${end}"
        return 0
    fi

    if [ -z $argv1 ]; then
	echo
	printf "%s\n" "${blu}Which tool would you like to source?${end}"
	echo "1) Quartus Prime Lite"
	echo "2) Quartus Prime Standard"
	echo "3) Quartus Prime Pro"
	echo "4) HLS"
    	echo "5) Arria 10 PAC Compilation and Programming - RTL AFU, OpenCL"
    	echo "6) Arria 10 - OneAPI, OpenVINO"
    	echo "7) Stratix 10 PAC Compilation and Programming - RTL AFU, OpenCL"
    	echo "8) Stratix 10 - OneAPI, OpenVINO"
    	echo
    	echo -n "Number: "
    	read -e number
    	until [ "$number" -lt 10 ] && [ "$number" -gt 0 ]
    	do
            printf "%s\n" "${red}Invalid Entry. Please input a correct number from the list above.${end}"
            echo -n "Number: "
            read -e number
    	done
    fi

    if [[ $number -eq 1 || ( -n $argv1 && $argv1 == "QL" ) ]]; then
        len=${#QUARTUS_LITE_RELEASE[@]}
        if [ $len -eq 0 ]; then
            echo "${red}Sorry, No quartus lite releases are supported at this time.${end}"
        elif [ $len -eq 1 ]; then
            if [[ -z "$argv1" || ( -n $argv2 && ${QUARTUS_LITE_RELEASE[0]} =~ "$argv2" ) ]]; then
		# source the one release
                echo "sourcing $GLOB_INTELFPGA_LITE/${QUARTUS_LITE_RELEASE[0]}/init_quartus.sh"
                source $GLOB_INTELFPGA_LITE/${QUARTUS_LITE_RELEASE[0]}/init_quartus.sh
                echo
	    else
                printf "%s\n%s\n" "${red}Invalid Entry. Please input quartus lite version in this format:" "tools_setup -t QL ${QUARTUS_LITE_RELEASE[0]} ${end}"
	    fi
        elif [ $len -gt 1 ]; then
	    if [[ -n "$argv2" && ${QUARTUS_LITE_RELEASE[*]} =~ "$argv2" ]]; then
		echo "sourcing $GLOB_INTELFPGA_LITE/$argv2/init_quartus.sh"
            	# source depending on what argument was provided
            	source $GLOB_INTELFPGA_LITE/$argv2/init_quartus.sh
            	echo
	    elif [[ -n "$argv2" || ( -n "$argv1" && -z "$argv2" ) ]]; then
                printf "%s\n%s\n" "${red}Invalid Entry. Valid quartus lite options are: ${QUARTUS_LITE_RELEASE[*]}" "eg: tools_setup -t QL ${QUARTUS_LITE_RELEASE[0]} ${end}"
	    else
                echo "${blu}Which Quartus Prime Lite release would you like to source?${end}"
            	for (( i=0; i<${len}; i++ )); do
                    echo "${i}) ${QUARTUS_LITE_RELEASE[$i]}"
            	done
            	echo
            	echo -n "Number: "
            	read -e second_number
            	until [ $len -gt $second_number ]; do
                    printf "%s\n" "${red}Invalid Entry. Please input a correct number from the list above.${end}"
                    echo -n "Number: "
                    read -e second_number
            	done
            	echo "sourcing $GLOB_INTELFPGA_LITE/${QUARTUS_LITE_RELEASE[$second_number]}/init_quartus.sh"
            	# source depending on what second_number they chose
            	source $GLOB_INTELFPGA_LITE/${QUARTUS_LITE_RELEASE[$second_number]}/init_quartus.sh
            	echo
	    fi
        else
            echo "${red}Something went wrong sourcing the lite release ${end}"
        fi

    elif [[ $number -eq 2 || ( -n $argv1 && $argv1 == "QS" ) ]]; then
        len=${#QUARTUS_STANDARD_RELEASE[@]}
        if [ $len -eq 0 ]; then
            echo "${red}Sorry, No quartus standard releases are supported at this time.${end}"
        elif [ $len -eq 1 ]; then
            if [[ -z "$argv1" || ( -n $argv2 && ${QUARTUS_STANDARD_RELEASE[0]} =~ "$argv2" ) ]]; then
            	echo "sourcing $GLOB_INTELFPGA_STANDARD/${QUARTUS_STANDARD_RELEASE[0]}/init_quartus.sh"
            	# source the one release
            	source $GLOB_INTELFPGA_STANDARD/${QUARTUS_STANDARD_RELEASE[0]}/init_quartus.sh
            	echo
	    else
                printf "%s\n%s\n" "${red}Invalid Entry. Please input quartus standard version in this format:" "tools_setup -t QS ${QUARTUS_STANDARD_RELEASE[0]} ${end}"
	    fi
        elif [ $len -gt 1 ]; then
	    if [[ -n "$argv2" && ${QUARTUS_STANDARD_RELEASE[*]} =~ "$argv2" ]]; then
            	echo "sourcing $GLOB_INTELFPGA_STANDARD/$argv2/init_quartus.sh"
            	# source depending on what argument was provided
            	source $GLOB_INTELFPGA_STANDARD/$argv2/init_quartus.sh
            	echo
	    elif [[ -n "$argv2" || ( -n "$argv1" && -z "$argv2" ) ]]; then
                printf "%s\n%s\n" "${red}Invalid Entry. Valid quartus standard options are: ${QUARTUS_STANDARD_RELEASE[*]}" "eg: tools_setup -t QS ${QUARTUS_STANDARD_RELEASE[0]} ${end}"
	    else
            	echo "${blu}Which Quartus Prime Standard release would you like to source?${end}"
            	for (( i=0; i<${len}; i++ )); do
                    echo "${i}) ${QUARTUS_STANDARD_RELEASE[$i]}"
            	done
            	echo
            	echo -n "Number: "
            	read -e second_number
            	until [ $len -gt $second_number ]; do
                    printf "%s\n" "${red}Invalid Entry. Please input a correct number from the list above.${end}"
                    echo -n "Number: "
                    read -e second_number
            	done
            	echo "sourcing $GLOB_INTELFPGA_STANDARD/${QUARTUS_STANDARD_RELEASE[$second_number]}/init_quartus.sh"
            	# source depending on what second_number they chose
            	source $GLOB_INTELFPGA_STANDARD/${QUARTUS_STANDARD_RELEASE[$second_number]}/init_quartus.sh
            	echo
	    fi
        else
            echo "${red}Something went wrong sourcing the standard release ${end}"
        fi

    elif [[ $number -eq 3 || ( -n $argv1 && $argv1 == "QP" ) ]]; then
        len=${#QUARTUS_PRO_RELEASE[@]}
        if [ $len -eq 0 ]; then
            echo "${red}Sorry, No quartus pro releases are supported at this time.${end}"
        elif [ $len -eq 1 ]; then
            if [[ -z "$argv1" || ( -n $argv2 && ${QUARTUS_PRO_RELEASE[0]} =~ "$argv2" ) ]]; then
            	echo "sourcing $GLOB_INTELFPGA_PRO/${QUARTUS_PRO_RELEASE[0]}/init_quartus.sh"
           	# source the one release
            	source $GLOB_INTELFPGA_PRO/${QUARTUS_PRO_RELEASE[0]}/init_quartus.sh
            	echo
	    else
                printf "%s\n%s\n" "${red}Invalid Entry. Please input quartus pro version in this format:" "tools_setup -t QP ${QUARTUS_PRO_RELEASE[0]} ${end}"
	    fi
        elif [ $len -gt 1 ]; then
	    if [[ -n "$argv2" && ${QUARTUS_PRO_RELEASE[*]} =~ "$argv2" ]]; then
            	echo "sourcing $GLOB_INTELFPGA_PRO/$argv2/init_quartus.sh"
            	# source depending on what argument was provided
            	source $GLOB_INTELFPGA_PRO/$argv2/init_quartus.sh
            	echo
	    elif [[ -n "$argv2" || ( -n "$argv1" && -z "$argv2" ) ]]; then
                printf "%s\n%s\n" "${red}Invalid Entry. Valid quartus pro options are: ${QUARTUS_PRO_RELEASE[*]}" "eg: tools_setup -t QP ${QUARTUS_PRO_RELEASE[0]} ${end}"
	    else
            	echo "${blu}Which Quartus Prime Pro release would you like to source?${end}"
            	for (( i=0; i<${len}; i++ )); do
                    echo "${i} ) ${QUARTUS_PRO_RELEASE[$i]}"
            	done
            	echo
            	echo -n "Number: "
            	read -e second_number
            	until [ $len -gt $second_number ]; do
                    printf "%s\n" "${red}Invalid Entry. Please input a correct number from the list above.${end}"
                    echo -n "Number: "
                    read -e second_number
            	done
            	echo "sourcing $GLOB_INTELFPGA_PRO/${QUARTUS_PRO_RELEASE[$second_number]}/init_quartus.sh"
            	# source depending on what second_number they chose
            	source $GLOB_INTELFPGA_PRO/${QUARTUS_PRO_RELEASE[$second_number]}/init_quartus.sh
            	echo
	    fi
        else
            echo "${red}Something went wrong sourcing the pro release ${end}"
        fi

    elif [[ $number -eq 4 || ( -n $argv1 && $argv1 == "HLS" ) ]]; then  # case for HLS
	if [[ -z "$argv2" && -n "$argv1" ]]; then
	    echo "${red}Missing arguments. Please include Quartus edition. Valid Quartus Prime editions are: Standard | Lite | Pro"
	    echo "eg: tools_setup -t HLS QL ${QUARTUS_LITE_RELEASE[0]} ${end}"
	    return 0
	elif [ -n "$argv2" ]; then
	    :  # do nothing
	else
            #ask which quartus release
            echo "${blu}Which Quartus edition would you like?${end}"
            echo "1) Quartus Prime Standard"
            echo "2) Quartus Prime Lite"
            echo "3) Quartus Prime Pro"
            echo
            echo -n "Number: "
            read -e qnumber
            until [ "$qnumber" -lt 4 ] && [ "$number" -gt 0 ]
            do
            	printf "%s\n" "${red}Invalid Entry. Please input a correct number from the list above.${end}"
            	echo -n "Number: "
            	read -e qnumber
            done
    	fi

        if [[ $qnumber -eq 1 || ( -n $argv2 && $argv2 == "QS" ) ]]; then  # case for Quartus STANDARD
            len=${#QUARTUS_STANDARD_RELEASE[@]}
            if [ $len -eq 0 ]; then
		echo "${red}Sorry, No quartus standard releases are supported at this time.${end}"
            elif [ $len -eq 1 ]; then
            	if [[ -z "$argv2" || ( -n $argv3 && ${QUARTUS_STANDARD_RELEASE[0]} =~ "$argv3" ) ]]; then
                    export INTELFPGAOCLSDKROOT=$GLOB_INTELFPGA_STANDARD/${QUARTUS_STANDARD_RELEASE[0]}/hls
                    # source the one release of quartus
                    echo "sourcing $GLOB_INTELFPGA_STANDARD/${QUARTUS_STANDARD_RELEASE[0]}/init_quartus.sh"
                    source $GLOB_INTELFPGA_STANDARD/${QUARTUS_STANDARD_RELEASE[0]}/init_quartus.sh
                    # source the one release of OpenCL
                    echo "sourcing $GLOB_INTELFPGA_STANDARD/${QUARTUS_STANDARD_RELEASE[0]}/hls/init_hls.sh"
                    source $GLOB_INTELFPGA_STANDARD/${QUARTUS_STANDARD_RELEASE[0]}/hls/init_hls.sh
                    echo
	    	else
		    printf "%s\n%s\n" "${red}Invalid Entry. Please input quartus standard version in this format:" "tools_setup -t HLS QS ${QUARTUS_STANDARD_RELEASE[0]} ${end}"
	    	fi
            elif [ $len -gt 1 ]; then
		if [[ -n "$argv3" && ${QUARTUS_STANDARD_RELEASE[*]} =~ "$argv3" ]]; then
                    export INTELFPGAOCLSDKROOT=$GLOB_INTELFPGA_STANDARD/$argv3/hls
		    # source quartus
                    echo "sourcing $INTELFPGAOCLSDKROOT/../init_quartus.sh"
                    source $INTELFPGAOCLSDKROOT/../init_quartus.sh
                    # source opencl
                    echo "sourcing $INTELFPGAOCLSDKROOT/init_hls.sh"
                    source $INTELFPGAOCLSDKROOT/init_hls.sh
		elif [[ -n "$argv3" || ( -n "$argv2" && -z "$argv3" ) ]]; then
                    printf "%s\n%s\n" "${red}Invalid Entry. Valid quartus standard options are: ${QUARTUS_STANDARD_RELEASE[*]}" "eg: tools_setup -t HLS QS ${QUARTUS_STANDARD_RELEASE[0]} ${end}"
		else
                    # ask which verison of openCL
                    echo "${blu}Which Quartus release would you like to source?${end}"
                    for (( i=0; i<${len}; i++ )); do
                    	echo "${i}) ${QUARTUS_STANDARD_RELEASE[$i]}"
                    done
                    echo
                    echo -n "Number: "
                    read -e second_number
                    until [ $len -gt $second_number ]; do
                    	printf "%s\n" "${red}Invalid Entry. Please input a correct number from the list above.${end}"
                    	echo -n "Number: "
                    	read -e second_number
                    done

                    export INTELFPGAOCLSDKROOT=$GLOB_INTELFPGA_STANDARD/${QUARTUS_STANDARD_RELEASE[$second_number]}/hls
                    # source quartus
                    echo "sourcing $INTELFPGAOCLSDKROOT/../init_quartus.sh"
                    source $INTELFPGAOCLSDKROOT/../init_quartus.sh
                    # source opencl
                    echo "sourcing $INTELFPGAOCLSDKROOT/init_hls.sh"
                    source $INTELFPGAOCLSDKROOT/init_hls.sh
		fi
            else
                echo "${red}Something went wrong with sourcing hls for quartus standard ${end}"
            fi

        elif [[ $qnumber -eq 2 || ( -n $argv2 && $argv2 == "QL" ) ]]; then  # case for quartus LITE
            len=${#QUARTUS_LITE_RELEASE[@]}
            if [ $len -eq 0 ]; then
                echo "${red}Sorry, No quartus lite releases are supported at this time.${end}"
            elif [ $len -eq 1 ]; then
            	if [[ -z "$argv2" || ( -n $argv3 && ${QUARTUS_LITE_RELEASE[0]} =~ "$argv3" ) ]]; then
                    export INTELFPGAOCLSDKROOT=$GLOB_INTELFPGA_LITE/${QUARTUS_LITE_RELEASE[0]}/hls
                    # source the one release of quartus
                    echo "sourcing $GLOB_INTELFPGA_LITE/${QUARTUS_LITE_RELEASE[0]}/init_quartus.sh"
                    source $GLOB_INTELFPGA_LITE/${QUARTUS_LITE_RELEASE[0]}/init_quartus.sh
                    # source the one release of OpenCL
                    echo "sourcing $GLOB_INTELFPGA_LITE/${QUARTUS_LITE_RELEASE[0]}/hls/init_hls.sh"
                    source $GLOB_INTELFPGA_LITE/${QUARTUS_LITE_RELEASE[0]}/hls/init_hls.sh
                    echo
	    	else
                    printf "%s\n%s\n" "${red}Invalid Entry. Please input quartus lite version in this format:" "tools_setup -t HLS QL ${QUARTUS_LITE_RELEASE[0]} ${end}"
	    	fi
            elif [ $len -gt 1 ]; then
		if [[ -n "$argv3" && ${QUARTUS_LITE_RELEASE[*]} =~ "$argv3" ]]; then
                    export INTELFPGAOCLSDKROOT=$GLOB_INTELFPGA_LITE/$argv3/hls
                    #source quartus
                    echo "sourcing $INTELFPGAOCLSDKROOT/../init_quartus.sh"
                    source $INTELFPGAOCLSDKROOT/../init_quartus.sh
                    #source opencl
                    echo "sourcing $INTELFPGAOCLSDKROOT/init_hls.sh"
                    source $INTELFPGAOCLSDKROOT/init_hls.sh
		elif [[ -n "$argv3" || ( -n "$argv2" && -z "$argv3" ) ]]; then
                    printf "%s\n%s\n" "${red}Invalid Entry. Valid quartus lite options are: ${QUARTUS_LITE_RELEASE[*]}" "eg: tools_setup -t HLS QL ${QUARTUS_LITE_RELEASE[0]} ${end}"
		else
                    # ask which verison of openCL
                    echo "${blu}Which Quartus release would you like to source?${end}"
                    for (( i=0; i<${len}; i++ )); do
                    	echo "${i}) ${QUARTUS_LITE_RELEASE[$i]}"
                    done
                    echo
                    echo -n "Number: "
                    read -e second_number
                    until [ $len -gt $second_number ]; do
                    	printf "%s\n" "${red}Invalid Entry. Please input a correct number from the list above.${end}"
                    	echo -n "Number: "
                    	read -e second_number
                    done

                    export INTELFPGAOCLSDKROOT=$GLOB_INTELFPGA_LITE/${QUARTUS_LITE_RELEASE[$second_number]}/hls
                    #source quartus
                    echo "sourcing $INTELFPGAOCLSDKROOT/../init_quartus.sh"
                    source $INTELFPGAOCLSDKROOT/../init_quartus.sh
                    #source opencl
                    echo "sourcing $INTELFPGAOCLSDKROOT/init_hls.sh"
                    source $INTELFPGAOCLSDKROOT/init_hls.sh
		fi
            else
                echo "${red}Something went wrong with sourcing hls for quartus prime lite ${end}"
            fi

        elif [[ $qnumber -eq 3 || ( -n $argv2 && $argv2 == "QP" ) ]]; then  # case for quartus PRO
            len=${#QUARTUS_PRO_RELEASE[@]}
            if [ $len -eq 0 ]; then
                echo "${red}Sorry, No quartus pro releases are supported at this time.${end}"
            elif [ $len -eq 1 ]; then
            	if [[ -z "$argv2" || ( -n $argv3 && ${QUARTUS_PRO_RELEASE[0]} =~ "$argv3" ) ]]; then
                    export INTELFPGAOCLSDKROOT=$GLOB_INTELFPGA_PRO/${QUARTUS_PRO_RELEASE[0]}/hls
                    # source the one release of quartus
                    echo "sourcing $GLOB_INTELFPGA_PRO/${QUARTUS_PRO_RELEASE[0]}/init_quartus.sh"
                    source $GLOB_INTELFPGA_PRO/${QUARTUS_PRO_RELEASE[0]}/init_quartus.sh
                    # source the one release of OpenCL
                    echo "sourcing $GLOB_INTELFPGA_PRO/${QUARTUS_PRO_RELEASE[0]}/hls/init_hls.sh"
                    source $GLOB_INTELFPGA_PRO/${QUARTUS_PRO_RELEASE[0]}/hls/init_hls.sh
                    echo
	    	else
                    printf "%s\n%s\n" "${red}Invalid Entry. Please input quartus pro version in this format:" "tools_setup -t HLS QP ${QUARTUS_PRO_RELEASE[0]} ${end}"
	    	fi
            elif [ $len -gt 1 ]; then
		if [[ -n "$argv3" && ${QUARTUS_PRO_RELEASE[*]} =~ "$argv3" ]]; then
                    export INTELFPGAOCLSDKROOT=$GLOB_INTELFPGA_PRO/$argv3/hls
                    #source quartus
                    echo "sourcing $INTELFPGAOCLSDKROOT/../init_quartus.sh"
                    source $INTELFPGAOCLSDKROOT/../init_quartus.sh
                    #source opencl
                    echo "sourcing $INTELFPGAOCLSDKROOT/init_hls.sh"
                    source $INTELFPGAOCLSDKROOT/init_hls.sh
		elif [[ -n "$argv3" || ( -n "$argv2" && -z "$argv3" ) ]]; then
                    printf "%s\n%s\n" "${red}Invalid Entry. Valid quartus pro options are: ${QUARTUS_PRO_RELEASE[*]}" "eg: tools_setup -t HLS QP ${QUARTUS_PRO_RELEASE[0]} ${end}"
		else
                    # ask which verison of openCL
                    echo "${blu}Which Quartus release would you like to source?${end}"
                    for (( i=0; i<${len}; i++ )); do
                    	echo "${i}) ${QUARTUS_PRO_RELEASE[$i]}"
                    done
                    echo
                    echo -n "Number: "
                    read -e second_number
                    until [ $len -gt $second_number ]; do
                    	printf "%s\n" "${red}Invalid Entry. Please input a correct number from the list above.${end}"
                    	echo -n "Number: "
                    	read -e second_number
                    done

                    export INTELFPGAOCLSDKROOT=$GLOB_INTELFPGA_PRO/${QUARTUS_PRO_RELEASE[$second_number]}/hls
                    # source quartus
                    echo "sourcing $INTELFPGAOCLSDKROOT/../init_quartus.sh"
                    source $INTELFPGAOCLSDKROOT/../init_quartus.sh
                    # source opencl
                    echo "sourcing $INTELFPGAOCLSDKROOT/init_hls.sh"
                    source $INTELFPGAOCLSDKROOT/init_hls.sh
                    # add python to path
                    export PATH=/glob/intel-python/python2/bin:${PATH}
		fi
            else
                echo "${red}Something went wrong with sourcing hls for quartus prime pro ${end}"
            fi
        else
            echo "${red}Something went wrong with case statements for HLS ${end}"
        fi

    elif [[ $number -eq 5 || ( -n $argv1 && $argv1 == "A10DS" ) ]]; then  #case for arria 10 development stack
        #need to check if on correct node
        IFS="|"
        temp_string="$(echo $HOSTNAME | grep -o -E "${arria10Nodes[*]}")"
        unset IFS
        #if [[ ${arria10Nodes[@]} =~ ${temp_string} && ${#temp_string} -eq 9 ]]; then  # checks that user is currently on correct node and node name has length of 9
        if [[ ${arria10Nodes12[@]} =~ ${temp_string} && ${#temp_string} -eq 9 ]]; then  # checks that user is currently on correct node and node name has length of 9
            echo "sourcing $GLOB_FPGASUPPORTSTACK/a10/${ARRIA10DEVSTACK_RELEASE[0]}/inteldevstack/init_env.sh"
            source $GLOB_FPGASUPPORTSTACK/a10/${ARRIA10DEVSTACK_RELEASE[0]}/inteldevstack/init_env.sh
	    echo
            echo "sourcing $GLOB_FPGASUPPORTSTACK/a10/${ARRIA10DEVSTACK_RELEASE[0]}/inteldevstack/intelFPGA_pro/hld/init_opencl.sh"
            source $GLOB_FPGASUPPORTSTACK/a10/${ARRIA10DEVSTACK_RELEASE[0]}/inteldevstack/intelFPGA_pro/hld/init_opencl.sh
	    echo
            echo "exporting basic building blocks env-variable settings"
	    export FPGA_BBB_CCI_SRC=~/intel-fpga-bbb
            export LD_LIBRARY_PATH=:~/usr/local:$LD_LIBRARY_PATH
	    export LIBRARY_PATH=~/usr/local/lib:$LIBRARY_PATH
	    echo
            echo "Putting python2 in the search path - required for Arria 10 development stack"
            export PATH=/glob/intel-python/python2/bin:${PATH}
	elif [[ ${arria10Nodes121[@]} =~ ${temp_string} && ${#temp_string} -eq 9 ]]; then  # checks that user is currently on correct node and node name has length of 9
            echo "sourcing $GLOB_FPGASUPPORTSTACK/a10/${ARRIA10DEVSTACK_RELEASE[1]}/inteldevstack/init_env.sh"
            source $GLOB_FPGASUPPORTSTACK/a10/${ARRIA10DEVSTACK_RELEASE[1]}/inteldevstack/init_env.sh
	    echo
            echo "sourcing $GLOB_FPGASUPPORTSTACK/a10/${ARRIA10DEVSTACK_RELEASE[1]}/intelFPGA_pro/hld/init_opencl.sh"
            source $GLOB_FPGASUPPORTSTACK/a10/${ARRIA10DEVSTACK_RELEASE[1]}/intelFPGA_pro/hld/init_opencl.sh
	    echo
            echo "exporting basic building blocks env-variable settings"
	    #export FPGA_BBB_CCI_SRC=~/intel-fpga-bbb
            #export LD_LIBRARY_PATH=:~/usr/local:$LD_LIBRARY_PATH
	    #export LIBRARY_PATH=~/usr/local/lib:$LIBRARY_PATH
	    # BBB installed in s005-n004 & s005-n007 nodes only
	    export FPGA_BBB_CCI_SRC=/usr/local/intel-fpga-bbb
	    echo
            echo "Putting python2 in the search path - required for Arria 10 development stack"
            export PATH=/glob/intel-python/python2/bin:${PATH}
        else
            echo "Not on an Arria10 Development Stack node. You need to be on an Arria10 Development Stack node to run Arria Development Stack"
        fi

    elif [[ $number -eq 6 || ( -n $argv1 && $argv1 == "A10OAPI" ) ]]; then  # case for Arria 10 OneAPI
        #IFS="|"
        #temp_string="$(echo $HOSTNAME | grep -o -E "${arria10_oneAPI_Nodes[*]}")"
        #unset IFS
        #if [[ ${arria10_oneAPI_Nodes[@]} =~ ${temp_string} && ${#temp_string} -eq 9 ]]; then  # checks if user is currently on correct node and node name has length of 9
            #echo "sourcing $GLOB_ONEAPI/beta05/inteloneapi/setvars.sh"
            #source $GLOB_ONEAPI/beta05/inteloneapi/setvars.sh
            echo "sourcing /opt/intel/inteloneapi/setvars.sh"
	    source /opt/intel/inteloneapi/setvars.sh
	    ### OpenVINO Setup
	    export IE_INSTALL="/opt/intel/openvino/deployment_tools"
	    source $IE_INSTALL/../bin/setupvars.sh
	    alias mo="python3.5 $IE_INSTALL/model_optimizer/mo.py"
        #else
            #echo "Not on an Arria10 OneAPI node. You need to be on an Arria10 OneAPI node."
        #fi

    elif [[ $number -eq 7 || ( -n $argv1 && $argv1 == "S10DS" ) ]]; then  # case for Stratix 10 Development Stack
        #IFS="|"
        #temp_string="$(echo $HOSTNAME | grep -o -E "${stratix10Nodes[*]}")"
        #unset IFS
        #if [[ ${stratix10Nodes[@]} =~ ${temp_string} && ${#temp_string} -eq 9 ]]; then
            echo "sourcing $GLOB_FPGASUPPORTSTACK/d5005/2.0.1/inteldevstack/init_env.sh"
            source $GLOB_FPGASUPPORTSTACK/d5005/2.0.1/inteldevstack/init_env.sh
            echo
            echo "sourcing $GLOB_FPGASUPPORTSTACK/d5005/2.0.1/inteldevstack/hld/init_opencl.sh"
            source $GLOB_FPGASUPPORTSTACK/d5005/2.0.1/inteldevstack/hld/init_opencl.sh
	    echo
            echo "exporting basic building blocks env-variable settings"
	    #export FPGA_BBB_CCI_SRC=~/intel-fpga-bbb
            #export LD_LIBRARY_PATH=:~/usr/local:$LD_LIBRARY_PATH
	    #export LIBRARY_PATH=~/usr/local/lib:$LIBRARY_PATH
	    # BBB installed in s005-n008 node only
	    export FPGA_BBB_CCI_SRC=/usr/local/intel-fpga-bbb
	    echo
            echo "Putting python2 in the search path - required for Stratix 10 development stack"
            export PATH=/glob/intel-python/python2/bin:${PATH}
        #else
            #echo "Not on a stratix10 node. You need to be on a stratix 10 node to run Stratix 10 Development Stack"
        #fi

    elif [[ $number -eq 8 || ( -n $argv1 && $argv1 == "S10OAPI" ) ]]; then  # case for Stratix 10 OneAPI
        #IFS="|"
        #temp_string="$(echo $HOSTNAME | grep -o -E "${stratix10_oneAPI_Nodes[*]}")"
        #unset IFS
        #if [[ ${stratix10_oneAPI_Nodes[@]} =~ ${temp_string} && ${#temp_string} -eq 9 ]]; then  # checks if user is currently on correct node and node name has length of 9
            #echo "sourcing $GLOB_ONEAPI/beta05/inteloneapi/setvars.sh"
            #source $GLOB_ONEAPI/beta05/inteloneapi/setvars.sh
            echo "sourcing /opt/intel/inteloneapi/setvars.sh"
	    source /opt/intel/inteloneapi/setvars.sh
	    ### OpenVINO Setup
	    export IE_INSTALL="/opt/intel/openvino/deployment_tools"
	    source $IE_INSTALL/../bin/setupvars.sh
	    alias mo="python3.5 $IE_INSTALL/model_optimizer/mo.py"
        #else
            #echo "Not on an Stratix10 OneAPI node. You need to be on an Stratix10 OneAPI node."
        #fi

    else
	if [ -z "argv1" ]; then
	    echo "printing else statement for sourcing cases"
	else
	    echo "${red}Invalid argument. Try 'tools_setup --help' for more information.${end}"
	fi
    fi

}


dev_Help() {
    echo
    echo "Usage: "
    echo "------"
    echo
    echo "devcloud_login -h | --help"
    echo "devcloud_login -l"
    echo "devcloud_login -I <script args options>"
    echo "devcloud_login -b <script args options> [walltime=hh:mm:ss] <job.sh>"
    echo "devcloud_login "
    echo
    echo "Description: "
    echo "------------"
    echo
    echo "devcloud_login is a command to display available nodes, start an interactive login to a compute "
    echo "node, or submit a batch job to a compute node. "
    echo
    echo "Argument Options: "
    echo "-----------------"
    echo
    echo "A10PAC  (eg. devcloud_login -I A10PAC 1.2)         Arria 10 PAC; 1.2  1.2.1"
    echo "A10OAPI (eg. devcloud_login -I A10OAPI)            Arria 10 OneAPI, OpenVINO"
    echo "S10PAC  (eg. devcloud_login -I S10PAC)	           Stratix 10 PAC"
    echo "S10OAPI (eg. devcloud_login -I S10OAPI)            Stratix 10 OneAPI, OpenVINO"
    echo "CO      (eg. devcloud_login -I CO)                 Compilation Only"
    echo "SNN     (eg. devcloud_login -I SNN s001-n139)      Specific Node Name"
    echo
    echo "Batch Submissions: "
    echo "------------------"
    echo "Walltime is optional; use if batch job needs more than 6 hours. Maximum Walltime is 48 hours for machines running RTL AFU/OpenCL and 24 hours for machines running OneAPI."
    echo
    echo "A10PAC  (eg. devcloud_login -b A10PAC 1.2 [walltime=12:00:00] job.sh)      Arria 10 PAC; 1.2  1.2.1"
    echo "A10OAPI (eg. devcloud_login -b A10OAPI [walltime=12:00:00] job.sh)         Arria 10 OneAPI, OpenVINO"
    echo "S10PAC  (eg. devcloud_login -b S10PAC [walltime=12:00:00] job.sh)	   Stratix 10 PAC"
    echo "S10OAPI (eg. devcloud_login -b S10OAPI [walltime=12:00:00] job.sh)         Stratix 10 OneAPI, OpenVINO"
    echo "CO      (eg. devcloud_login -b CO [walltime=12:00:00] job.sh)              Compilation Only"
    echo "SNN     (eg. devcloud_login -b SNN s001-n139 [walltime=12:00:00] job.sh)   Specific Node Name"
    echo
    echo "See Also: "
    echo "---------"
    echo
    echo "qstatus		To see the status report of your jobs running on the DevCloud"
    echo "qdel		To terminate a job running on the DevCloud (eg. qdel XXXX.v-qsvr-fpga.aidevcloud)"
}


tool_Help() {
    echo
    echo "Usage: "
    echo "------"
    echo
    echo "tools_setup -h | --help"
    echo "tools_setup -t [<script args options>]"
    echo "tools_setup "
    echo
    echo "Description: "
    echo "------------"
    echo
    echo "tools_setup is a function aimed to help the user setup an environment variable in a devcloud node."
    echo "The tools_setup has a user interactive and non interactive mode. "
    echo
    echo "Argument Options: "
    echo "-----------------"
    echo
    echo "QL      (eg. tools_setup -t QL 18.1)          Quartus Lite; $1"
    echo "QS      (eg. tools_setup -t QS 18.1)	      Quartus Standard; $2"
    echo "QP      (eg. tools_setup -t QP 18.1)	      Quartus Pro; ${*:3}"
    echo "HLS     (eg. tools_setup -t HLS QL 18.1)      High-Level Synthesis"
    echo "A10DS   (eg. tools_setup -t A10DS 1.2)        Arria 10 Development Stack"
    echo "A10OAPI (eg. tools_setup -t A10OAPI)          Arria 10 OneAPI, OpenVINO"
    echo "S10DS   (eg. tools_setup -t S10DS)	      Stratix 10 Development Stack"
    echo "S10OAPI (eg. tools_setup -t S10OAPI)          Stratix 10 OneAPI, OpenVINO"
    echo
}
