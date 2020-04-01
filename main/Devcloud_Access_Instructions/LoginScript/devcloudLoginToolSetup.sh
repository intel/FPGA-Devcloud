
#############################
#                           #
#   Latest Edit             #
#                           #
# -Mar 31 2020              #
#                           #
#                           #
#                           #
#                           #
#############################



#global variables
red=$'\e[1;31m'
blu=$'\e[1;34m'
end=$'\e[0m'
noHardwareNodes=("s001-n039" "s001-n040" "s001-n041" "s001-n042" "s001-n043" "s001-n044" "s001-n045")
arria10Nodes=("s005-n001" "s005-n002" "s005-n003" "s005-n004" "s005-n005" "s005-n006" "s005-n007" "s001-n137" "s001-n138" "s001-n139")
arria10_oneAPI_Nodes=("s001-n081" "s001-n082" "s001-n083" "s001-n084" "s001-n085" "s001-n086" "s001-n087" "s001-n088" "s001-n089" "s001-n090" "s001-n091" "s001-n092")
# 1 more stratix10Nodes expected date TBD
stratix10Nodes=("s005-n008" "s001-n189")
allNodes=( "${noHardwareNodes[@]}" "${arria10Nodes[@]}" "${arria10_oneAPI_Nodes[@]}" "${stratix10Nodes[@]}" )



devcloud_login()
{
    # initial check to see if user is logged into a node already
    if [ $HOSTNAME != "login-2" ];
    then
        echo "Your hostname is not login-2. You are probably already logged into a node. Exit node in order to log into another node."
        return 1
    fi

    echo
    printf "%s\n" "${blu}What are you trying to use the Devcloud for? ${end}"
    echo
    echo "1) Arria 10 PAC Card Programming"
    echo "2) Arria 10 OneAPI"
    echo "3) Stratix 10 PAC Card Programming"
    echo "4) Compilation Only"
    echo "5) Enter Specific Node Number"
    echo
    echo -n "Number: "
    read -e number

    until [ "$number" -eq 1 ] || [ "$number" -eq 2 ] || [ "$number" -eq 3 ] || [ "$number" -eq 4 ] || [ "$number" -eq 5 ];
    do
        printf "%s\n" "${red}Invalid Entry. Please input a correct number from the list above. ${end} "
        echo -n "Number: "
        read -e number
    done

    IFS="|"
    currentNode="$(echo $HOSTNAME | grep -o -E "${allNodes[*]}")"
    unset IFS

    if [ $number -eq 1 ];
    then
        if [ -z $currentNode ]; #if current node is empty
        then
            #pbsnodes -s v-qsvr-fpga | grep -B 4 'arria10' | grep -B 1 "state = free"| grep -B 1 '13[0-9]' | grep -o '...$' > ~/nodes.txt
            #node=$(head -n 1 nodes.txt)
            IFS="|"
            readarray availableNodes < <(pbsnodes -s v-qsvr-fpga | grep -B 4 'arria10' | grep -B 1 "state = free" | grep -o -E "${arria10Nodes[*]}")
            readarray availableNodes_on_temp_server < <(pbsnodes | grep -B 4 'arria10' | grep -B 1 "state = free" | grep -o -E "${arria10Nodes[*]}")
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
            else
                node=(${availableNodes[0]})
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
                echo "running: qsub -q batch@v-qsvr-fpga -I -l nodes="$node":ppn=2"
                qsub -q batch@v-qsvr-fpga -I -l nodes="$node":ppn=2
            fi
        else
            printf "%s\n" "${red}You are currently on a node. Please exit the current node and try again.${end}"
        fi
    elif [ $number -eq 2 ];
    then
        if [ -z $currentNode ]; #if current node is empty
        then
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
            else
                node=(${availableNodes[0]})
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
                echo "running: qsub -I -l nodes="$node":ppn=2"
                qsub -I -l nodes="$node":ppn=2
            fi
        else
            printf "%s\n" "${red}You are currently on a node. Please exit the current node and try again.${end}"
        fi
    elif [ $number -eq 3 ];
    then
        if [ -z $currentNode ];
        then
            IFS="|"
            readarray availableNodes < <(pbsnodes -s v-qsvr-fpga | grep -B 4 'darby' | grep -B 1 "state = free" | grep -o -E "${stratix10Nodes[*]}")
            readarray availableNodes_on_temp_server < <(pbsnodes | grep -B 4 'darby' | grep -B 1 "state = free" | grep -o -E "${stratix10Nodes[*]}")
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
            else
                node=(${availableNodes[0]})
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
                echo "running: qsub -q batch@v-qsvr-fpga -I -l nodes="$node":ppn=2"
                qsub -q batch@v-qsvr-fpga -I -l nodes="$node":ppn=2
            fi
        else
            printf "%s\n" "${red}You are currently on a node. Please exit the current node and try again.${end}"
        fi
    elif [ $number -eq 4 ];
    then
        if [ -z $currentNode ];
        then
            IFS="|"
            # readarray availableNodes < <(pbsnodes | grep -B 1 "state = free"| grep -T '13[0-6]' | grep -o '...$')
            readarray availableNodes < <(pbsnodes -s v-qsvr-fpga | grep -B 1 "state = free" | grep -o -E "${noHardwareNodes[*]}")
            readarray availableNodes_on_temp_server < <(pbsnodes | grep -B 1 "state = free" | grep -o -E "${noHardwareNodes[*]}")
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
            else
                node=(${availableNodes[0]})
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
                echo "running: qsub -I -l nodes="$node":ppn=2"
                qsub -I -l nodes="$node":ppn=2
            fi
        else
            printf "%s\n" "${red}You are currently on a node. Please exit the current node and try again.${end}"
        fi
    elif [ $number -eq 5 ];
    then
        if [ -z $currentNode ];
        then
            IFS="|"
            readarray availableNodesNohardware < <(pbsnodes -s v-qsvr-fpga | grep -B 1 "state = free" | grep -o -E "${noHardwareNodes[*]}")
            readarray availableNodesNohardware_on_temp_server < <(pbsnodes | grep -B 1 "state = free" | grep -o -E "${noHardwareNodes[*]}")
            readarray availableNodesArria < <(pbsnodes -s v-qsvr-fpga | grep -B 4 'arria10' | grep -B 1 "state = free" | grep -o -E "${arria10Nodes[*]}")
            readarray availableNodesArria_on_temp_server < <(pbsnodes | grep -B 4 'arria10' | grep -B 1 "state = free" | grep -o -E "${arria10Nodes[*]}")
            readarray availableNodesArria10_oneAPI_Nodes < <(pbsnodes -s v-qsvr-fpga | grep -B 4 'arria10' | grep -B 4 'fpga_runtime' | grep -B 1 "state = free" | grep -o -E "${arria10_oneAPI_Nodes[*]}")
            readarray availableNodesArria10_oneAPI_Nodes_on_temp_server < <(pbsnodes | grep -B 4 'arria10' | grep -B 4 'fpga_runtime' | grep -B 1 "state = free" | grep -o -E "${arria10_oneAPI_Nodes[*]}")
            readarray availableNodesStratix < <(pbsnodes -s v-qsvr-fpga | grep -B 4 'darby' | grep -B 1 "state = free"  | grep -o -E "${stratix10Nodes[*]}")
            readarray availableNodesStratix_on_temp_server < <(pbsnodes | grep -B 4 'darby' | grep -B 1 "state = free"  | grep -o -E "${stratix10Nodes[*]}")
            unset IFS
            let number_of_available_no_hardware_nodes=${#availableNodesNohardware[@]}+${#availableNodesNohardware_on_temp_server[@]}
            let number_of_available_arria10_nodes=${#availableNodesArria[@]}+${#availableNodesArria_on_temp_server[@]}
            let number_of_available_arria10_oneAPI_nodes=${#availableNodesArria10_oneAPI_Nodes[@]}+${#availableNodesArria10_oneAPI_Nodes_on_temp_server[@]}
            let number_of_available_stratix10_nodes=${#availableNodesStratix[@]}+${#availableNodesStratix_on_temp_server[@]}
            # availableNodes=() #initialize the empty array
            # availableNodes+=($availableNodesNohardware) #append an
            # availableNodes+=($availableNodesArria)
            # availableNodes+=($availableNodesStratix)
            # echo ${availableNodes}
            availableNodes=( "${availableNodesNohardware[@]}" "${availableNodesArria[@]}" "${availableNodesStratix[@]}" \
                "${availableNodesNohardware_on_temp_server[@]}" "${availableNodesArria_on_temp_server[@]}" "${availableNodesStratix_on_temp_server[@]}" \
                "${availableNodesArria10_oneAPI_Nodes[@]}" "${availableNodesArria10_oneAPI_Nodes_on_temp_server[@]}")
            #echo ${availableNodes[@]}
            #echo ${availableNodes[2]}
            if [ ${#availableNodes[@]} == 0 ];
            then
                echo
                echo
                printf "%s\n" "${red}--------------------------------------------------------------- ${end} "
                printf "%s\n" "${red}No available nodes. Try again later. ${end} "
                printf "%s\n" "${red}--------------------------------------------------------------- ${end} "
            else
                echo "Showing available nodes below: (${#availableNodes[@]} available/${#allNodes[@]} total)       "
                echo --------------------------------------------------------------------------------------
                printf "%s\n" "${blu}Nodes with no attached hardware:${end} (${number_of_available_no_hardware_nodes} available/${#noHardwareNodes[@]} total)           "
                node_no_hardware_str=$(echo ${availableNodesNohardware[@]} ${availableNodesNohardware_on_temp_server[@]})
                printf "${red}$node_no_hardware_str${end}"
                echo 
                echo --------------------------------------------------------------------------------------
                printf "%s\n" "${blu}Nodes with Arria 10 OneAPI:${end} (${number_of_available_arria10_oneAPI_nodes} available/${#arria10_oneAPI_Nodes[@]} total)         "
                node_arria10_oneAPI_str=$(echo ${availableNodesArria10_oneAPI_Nodes[@]} ${availableNodesArria10_oneAPI_Nodes_on_temp_server[@]})
                printf "${red}$node_arria10_oneAPI_str${end}"
                echo 
                echo --------------------------------------------------------------------------------------
                printf "%s\n" "${blu}Nodes with Arria 10:${end} (${number_of_available_arria10_nodes} available/${#arria10Nodes[@]} total)         "
                node_arria10_str=$(echo ${availableNodesArria[@]} ${availableNodesArria_on_temp_server[@]})
                printf "${red}$node_arria10_str${end}"
                echo
                echo --------------------------------------------------------------------------------------
                printf "%s\n" "${blu}Nodes with Stratix 10:${end} (${number_of_available_stratix10_nodes} available/${#stratix10Nodes[@]} total)          "
                node_stratix_str=$(echo ${availableNodesStratix[@]} ${availableNodesStratix_on_temp_server[@]})
                printf "${red}$node_stratix_str${end}"
                echo
                echo --------------------------------------------------------------------------------------
                echo
                echo "What node would you like to use?"
                echo
                echo -n "Node: "
                read -e node

                #until  [ $node -lt 140 ] && [ $node -gt 129 ]  ||  [ "$node" == 189 ]
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
                    echo "running: qsub -I -l nodes="$node":ppn=2"
                    qsub -I -l nodes="$node":ppn=2
                else
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
                    echo "running: qsub -q batch@v-qsvr-fpga -I -l nodes="$node":ppn=2"
                    qsub -q batch@v-qsvr-fpga -I -l nodes="$node":ppn=2
                fi
            fi
        else
            printf "%s\n" "${red}You are currently on a node. Please exit the current node and try again.${end}"
        fi
    fi
}


tools_setup()
{
    QUARTUS_LITE_RELEASE=("18.1")
    QUARTUS_STANDARD_RELEASE=("18.1")
    QUARTUS_PRO_RELEASE=("17.1" "18.1" "19.2" "19.3")

    #defined paths
    GLOB_INTELFPGA_PRO="/glob/development-tools/versions/intelFPGA_pro"
    GLOB_INTELFPGA_LITE="/glob/development-tools/versions/intelFPGA_lite"
    GLOB_INTELFPGA_STANDARD="/glob/development-tools/versions/intelFPGA"
    QUARTUS_PATHS=($GLOB_INTELFPGA_LITE $GLOB_INTELFPGA_STANDARD $GLOB_INTELFPGA_PRO)
    OPT_INTEL="/opt/intel"
    OPT_INTEL_2="/opt/intel/2.0.1"
    GLOB_FPGASUPPORTSTACK="/glob/development-tools/versions/fpgasupportstack"
    GLOB_ONEAPI="/glob/development-tools/versions/oneapi"

    ARRIA10DEVSTACK_RELEASE=("1.2" "1.2.1")

    echo
    printf "%s\n" "${blu}Which tool would you like to source?${end}"
    echo
    echo "1) Quartus Prime Lite"
    echo "2) Quartus Prime Standard"
    echo "3) Quartus Prime Pro"
    echo "4) HLS"
    echo "5) Arria 10 Development Stack + OpenCL"
    echo "6) Arria 10 OneAPI"
    echo "7) Stratix 10 Development Stack + OpenCL"
    echo
    echo -n "Number: "
    read -e number

    until [ "$number" -lt 10 ] && [ "$number" -gt 0 ]
    do
        printf "%s\n" "${red}Invalid Entry. Please input a correct number from the list above. ${end} "
        echo -n "Number: "
        read -e number
    done


    if [ $number -eq 1 ];
    then
        len=${#QUARTUS_LITE_RELEASE[@]}
        if [ $len -eq 0 ];
        then
            echo "${red}Something went wrong, does not support any quartus Lite releases ${end}"
        elif [ $len -eq 1 ];
        then
            # source the one release
            echo "sourcing $GLOB_INTELFPGA_LITE/${QUARTUS_LITE_RELEASE[0]}/init_quartus.sh"
            source $GLOB_INTELFPGA_LITE/${QUARTUS_LITE_RELEASE[0]}/init_quartus.sh
            echo
        elif [ $len -gt 1 ];
        then
            echo "${blu}Which Quartus Prime Lite release would you like to source?${end}"
            for (( i=0; i<${len}; i++ ));
            do
                echo "${i}) ${QUARTUS_LITE_RELEASE[$i]}"
            done
            echo
            echo -n "Number: "
            read -e second_number
            until [ $len -gt $second_number ];
            do
                printf "%s\n" "${red}Invalid Entry. Please input a correct number from the list above. ${end} "
                echo -n "Number: "
                read -e second_number
            done
            echo "sourcing $GLOB_INTELFPGA_LITE/${QUARTUS_LITE_RELEASE[$second_number]}/init_quartus.sh"
            # source depending on what second_number they chose
            source $GLOB_INTELFPGA_LITE/${QUARTUS_LITE_RELEASE[$second_number]}/init_quartus.sh
            echo
        else
            echo "${red}Something went wrong sourcing the lite release ${end}"
        fi

    elif [ $number -eq 2 ];
    then
        len=${#QUARTUS_STANDARD_RELEASE[@]}
        if [ $len -eq 0 ];
        then
            echo "${red}Something went wrong, does not support any quartus standard releases ${end}"
        elif [ $len -eq 1 ];
        then
            echo "sourcing $GLOB_INTELFPGA_STANDARD/${QUARTUS_STANDARD_RELEASE[0]}/init_quartus.sh"
            #source the one release
            source $GLOB_INTELFPGA_STANDARD/${QUARTUS_STANDARD_RELEASE[0]}/init_quartus.sh
            echo
        elif [ $len -gt 1 ];
        then
            echo "${blu}Which Quartus Prime Standard release would you like to source?${end}"
            for (( i=0; i<${len}; i++ ));
            do
                echo "${i}) ${QUARTUS_STANDARD_RELEASE[$i]}"
            done
            echo
            echo -n "Number: "
            read -e second_number
            until [ $len -gt $second_number ];
            do
                printf "%s\n" "${red}Invalid Entry. Please input a correct number from the list above. ${end} "
                echo -n "Number: "
                read -e second_number
            done
            echo "sourcing $GLOB_INTELFPGA_STANDARD/${QUARTUS_STANDARD_RELEASE[$second_number]}/init_quartus.sh"
            #source depending on what second_number they chose
            source $GLOB_INTELFPGA_STANDARD/${QUARTUS_STANDARD_RELEASE[$second_number]}/init_quartus.sh
            echo
        else
            echo "${red}Something went wrong sourcing the standard release ${end}"
        fi

    elif [ $number -eq 3 ];
    then
        len=${#QUARTUS_PRO_RELEASE[@]}
        if [ $len -eq 0 ];
        then
            echo "${red}Something went wrong, does not support any quartus pro releases ${end}"
        elif [ $len -eq 1 ];
        then
            echo "sourcing $GLOB_INTELFPGA_PRO/${QUARTUS_PRO_RELEASE[0]}/init_quartus.sh"
            # source the one release
            source $GLOB_INTELFPGA_PRO/${QUARTUS_PRO_RELEASE[0]}/init_quartus.sh
            echo
        elif [ $len -gt 1 ];
        then
            echo "${blu}Which Quartus Prime Pro release would you like to source?${end}"
            for (( i=0; i<${len}; i++ ));
            do
                echo "${i} ) ${QUARTUS_PRO_RELEASE[$i]}"
            done
            echo
            echo -n "Number: "
            read -e second_number
            until [ $len -gt $second_number ];
            do
                printf "%s\n" "${red}Invalid Entry. Please input a correct number from the list above. ${end} "
                echo -n "Number: "
                read -e second_number
            done
            echo "sourcing $GLOB_INTELFPGA_PRO/${QUARTUS_PRO_RELEASE[$second_number]}/init_quartus.sh"
            # source depending on what second_number they chose
            source $GLOB_INTELFPGA_PRO/${QUARTUS_PRO_RELEASE[$second_number]}/init_quartus.sh
            echo
        else
            echo "${red}Something went wrong sourcing the pro release ${end}"
        fi
    elif [ $number -eq 4 ];  # case for HLS
    then

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
            printf "%s\n" "${red}Invalid Entry. Please input a correct number from the list above. ${end} "
            echo -n "Number: "
            read -e qnumber
        done

        if [ $qnumber -eq 1 ];  # case for quartus STANDARD
        then
            len=${#QUARTUS_STANDARD_RELEASE[@]}
            if [ $len -eq 0 ];
            then
                echo "${red}Something went wrong, does not support any quartus standard releases ${end}"
            elif [ $len -eq 1 ];
            then
                export INTELFPGAOCLSDKROOT=$GLOB_INTELFPGA_STANDARD/${QUARTUS_STANDARD_RELEASE[0]}/hls

                # source the one release of quartus
                echo "sourcing $GLOB_INTELFPGA_STANDARD/${QUARTUS_STANDARD_RELEASE[0]}/init_quartus.sh"
                source $GLOB_INTELFPGA_STANDARD/${QUARTUS_STANDARD_RELEASE[0]}/init_quartus.sh

                # source the one release of OpenCL
                echo "sourcing $GLOB_INTELFPGA_STANDARD/${QUARTUS_STANDARD_RELEASE[0]}/hls/init_hls.sh"
                source $GLOB_INTELFPGA_STANDARD/${QUARTUS_STANDARD_RELEASE[0]}/hls/init_hls.sh

                echo
            elif [ $len -gt 1 ];
            then
                # ask which verison of openCL
                echo "${blu}Which Quartus release would you like to source?${end}"
                for (( i=0; i<${len}; i++ ));
                do
                    echo "${i}) ${QUARTUS_STANDARD_RELEASE[$i]}"
                done
                echo
                echo -n "Number: "
                read -e second_number
                until [ $len -gt $second_number ];
                do
                    printf "%s\n" "${red}Invalid Entry. Please input a correct number from the list above. ${end} "
                    echo -n "Number: "
                    read -e second_number
                done

                export INTELFPGAOCLSDKROOT=$GLOB_INTELFPGA_LITE/${QUARTUS_LITE_RELEASE[$second_number]}/hls

                # source quartus
                echo "sourcing $INTELFPGAOCLSDKROOT/../init_quartus.sh"
                source $INTELFPGAOCLSDKROOT/../init_quartus.sh

                # source opencl
                echo "sourcing $INTELFPGAOCLSDKROOT/init_hls.sh"
                source $INTELFPGAOCLSDKROOT/init_hls.sh

            else
                echo "${red}Something went wrong with sourcing hls for quartus lite ${end}"
            fi
        elif [ $qnumber -eq 2 ];  # case for quartus LITE
        then
            len=${#QUARTUS_LITE_RELEASE[@]}
            if [ $len -eq 0 ];
            then
                echo "${red}Something went wrong, does not support any quartus lite releases ${end}"
            elif [ $len -eq 1 ];
            then
                export INTELFPGAOCLSDKROOT=$GLOB_INTELFPGA_LITE/${QUARTUS_LITE_RELEASE[0]}/hls

                # source the one release of quartus
                echo "sourcing $GLOB_INTELFPGA_LITE/${QUARTUS_LITE_RELEASE[0]}/init_quartus.sh"
                source $GLOB_INTELFPGA_LITE/${QUARTUS_PRO_RELEASE[0]}/init_quartus.sh

                # source the one release of OpenCL
                echo "sourcing $GLOB_INTELFPGA_LITE/${QUARTUS_LITE_RELEASE[0]}/hls/init_hls.sh"
                source $GLOB_INTELFPGA_LITE/${QUARTUS_LITE_RELEASE[0]}/hls/init_hls.sh

                echo
            elif [ $len -gt 1 ];
            then
                # ask which verison of openCL
                echo "${blu}Which Quartus release would you like to source?${end}"
                for (( i=0; i<${len}; i++ ));
                do
                    echo "${i}) ${QUARTUS_LITE_RELEASE[$i]}"
                done
                echo
                # echo "length of array is ${len}"
                echo -n "Number: "
                read -e second_number
                until [ $len -gt $second_number ];
                do
                    printf "%s\n" "${red}Invalid Entry. Please input a correct number from the list above. ${end} "
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

            else
                echo "${red}Something went wrong with sourcing HLS for Quartus Prime Lite ${end}"
            fi
        elif [ $qnumber -eq 3 ];  # case for quartus PRO
        then
            len=${#QUARTUS_PRO_RELEASE[@]}
            if [ $len -eq 0 ];
            then
                echo "${red}Something went wrong, does not support any quartus pro releases ${end}"
            elif [ $len -eq 1 ];
            then
                export INTELFPGAOCLSDKROOT=$GLOB_INTELFPGA_PRO/${QUARTUS_PRO_RELEASE[0]}/hls

                # source the one release of quartus
                echo "sourcing $GLOB_INTELFPGA_PRO/${QUARTUS_PRO_RELEASE[0]}/init_quartus.sh"
                source $GLOB_INTELFPGA_PRO/${QUARTUS_PRO_RELEASE[0]}/init_quartus.sh

                # source the one release of OpenCL
                echo "sourcing $GLOB_INTELFPGA_PRO/${QUARTUS_PRO_RELEASE[0]}/hls/init_hls.sh"
                source $GLOB_INTELFPGA_PRO/${QUARTUS_PRO_RELEASE[0]}/hls/init_hls.sh

                echo
            elif [ $len -gt 1 ];
            then
                # ask which verison of openCL
                echo "${blu}Which Quartus release would you like to source?${end}"
                for (( i=0; i<${len}; i++ ));
                do
                    echo "${i}) ${QUARTUS_PRO_RELEASE[$i]}"
                done
                echo
                echo -n "Number: "
                read -e second_number
                until [ $len -gt $second_number ];
                do
                    printf "%s\n" "${red}Invalid Entry. Please input a correct number from the list above. ${end} "
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
            else
                echo "${red}Something went wrong with sourcing HLS for Quartus Prime Pro ${end}"
            fi
        else
            echo "${red}Something went wrong with case statements for HLS ${end}"
        fi

    elif [ $number -eq 5 ]; #case for arria 10 development stack
    then
        #need to check if on correct node
        IFS="|"
        temp_string="$(echo $HOSTNAME | grep -o -E "${arria10Nodes[*]}")"
        unset IFS
        if [[ ${arria10Nodes[@]} =~ ${temp_string} && ${#temp_string} -eq 9 ]];  # this checks that user is currently on correct node and node name has length of 9
        then
            # ask which version of a10 devstack
            echo "${blu}Which Arria 10 Development Stack + OpenCL release would you like to source?${end}"
            for (( i=0; i<${#ARRIA10DEVSTACK_RELEASE[@]}; i++));
            do
                echo "${i}) ${ARRIA10DEVSTACK_RELEASE[$i]}"
            done
            echo
            echo -n "Number: "
            read -e second_number
            until [ ${#ARRIA10DEVSTACK_RELEASE[@]} -gt $second_number ];
            do
                printf "%s\n" "${red}Invalid Entry. Please input a correct number from the list above. ${end} "
                echo -n "Number: "
                read -e second_number
            done
            echo "sourcing $GLOB_FPGASUPPORTSTACK/a10/${ARRIA10DEVSTACK_RELEASE[$second_number]}/inteldevstack/init_env.sh"
            source $GLOB_FPGASUPPORTSTACK/a10/${ARRIA10DEVSTACK_RELEASE[$second_number]}/inteldevstack/init_env.sh
            echo
            if [ $second_number -eq 0 ];
            then
                echo "sourcing $GLOB_FPGASUPPORTSTACK/a10/${ARRIA10DEVSTACK_RELEASE[$second_number]}/inteldevstack/intelFPGA_pro/hld/init_opencl.sh"
                source $GLOB_FPGASUPPORTSTACK/a10/${ARRIA10DEVSTACK_RELEASE[$second_number]}/inteldevstack/intelFPGA_pro/hld/init_opencl.sh
                echo
            fi
            if [ $second_number -eq 1 ];
            then
                echo "sourcing $GLOB_FPGASUPPORTSTACK/a10/${ARRIA10DEVSTACK_RELEASE[$second_number]}/intelFPGA_pro/hld/init_opencl.sh"
                source $GLOB_FPGASUPPORTSTACK/a10/${ARRIA10DEVSTACK_RELEASE[$second_number]}/intelFPGA_pro/hld/init_opencl.sh
                echo
            fi

            echo "Putting python2 in the search path - required for Arria 10 development stack"
            export PATH=/glob/intel-python/python2/bin:${PATH}
        else
            echo "Not on an Arria10 node. You need to be on an Arria10 node to run Arria Development Stack"
        fi
    elif [ $number -eq 6 ];  #case for Arria 10 OneAPI
    then
        IFS="|"
        temp_string="$(echo $HOSTNAME | grep -o -E "${arria10_oneAPI_Nodes[*]}")"
        unset IFS
        if [[ ${arria10_oneAPI_Nodes[@]} =~ ${temp_string} && ${#temp_string} -eq 9 ]];  # this checks that user is currently on correct node and node name has length of 9
        then
            echo "sourcing $GLOB_ONEAPI/beta05/inteloneapi/setvars.sh"
            source $GLOB_ONEAPI/beta05/inteloneapi/setvars.sh
        else
            echo "Not on an Arria 10 OneAPI node. You need to be on an Arria 10 OneAPI node."
        fi
    elif [ $number -eq 7 ];  # case for Stratix 10 Development Stack
    then
        IFS="|"
        temp_string="$(echo $HOSTNAME | grep -o -E "${stratix10Nodes[*]}")"
        unset IFS
        if [[ ${stratix10Nodes[@]} =~ ${temp_string} && ${#temp_string} -eq 9 ]];
        then
            echo "sourcing $GLOB_FPGASUPPORTSTACK/d5005/2.0.1/inteldevstack/init_env.sh"
            source $GLOB_FPGASUPPORTSTACK/d5005/2.0.1/inteldevstack/init_env.sh
            echo
            echo "sourcing $GLOB_FPGASUPPORTSTACK/d5005/2.0.1/inteldevstack/hld/init_opencl.sh"
            source $GLOB_FPGASUPPORTSTACK/d5005/2.0.1/inteldevstack/hld/init_opencl.sh
            echo "Putting python2 in the search path - required for Stratix 10 development stack"
            export PATH=/glob/intel-python/python2/bin:${PATH}
        else
            echo "Not on a stratix10 node. You need to be on a stratix 10 node to run Stratix 10 Development Stack"
        fi
    else
        echo "printing else statement for sourcing cases"
    fi

}

