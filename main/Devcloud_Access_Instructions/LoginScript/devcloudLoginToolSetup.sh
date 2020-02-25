
#############################
#                           #
#   Latest Edit             #
#                           #
# -Feb 25 2020              # 
#                           #
#                           #
#                           #
#                           #
#############################

devcloud_login()
{
    red=$'\e[1;31m'
    blu=$'\e[1;34m'
    end=$'\e[0m'

    noHardwareNodes=("s001-n043" "s001-n044") 
    arria10Nodes=("s005-n005" "s005-n006" "s005-n007" "s001-n137" "s001-n138" "s001-n139")
    stratix10Nodes=("s001-n189")
    allNodes=( "${noHardwareNodes[@]}" "${arria10Nodes[@]}" "${stratix10Nodes[@]}" )
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

    IFS="|"
    currentNode="$(echo $HOSTNAME | grep -o -E "${allNodes[*]}")"
    unset IFS

    if [ $number -eq 1  ]; 
    then
        if [ -z $currentNode ]; #if current node is empty
        then
            #pbsnodes -s v-qsvr-fpga | grep -B 4 'arria10' | grep -B 1 "state = free"| grep -B 1 '13[0-9]' | grep -o '...$' > ~/nodes.txt
            #node=$(head -n 1 nodes.txt)
            IFS="|"
            readarray availableNodes < <(pbsnodes -s v-qsvr-fpga | grep -B 4 'arria10' | grep -B 1 "state = free"| grep -o -E "${arria10Nodes[*]}")
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
                qsub -q batch@v-qsvr-fpga -I -l nodes="$node":ppn=2
            fi
        else
            printf "%s\n" "${red}You are currently on a node. Please exit the current node and try again.${end}"
        fi
    elif [ $number -eq 2 ]; 
    then
        if [ -z $currentNode ]; 
        then
            IFS="|"
            readarray availableNodes < <(pbsnodes -s v-qsvr-fpga | grep -B 4 'darby' | grep -B 1 "state = free"  | grep -o -E "${stratix10Nodes[*]}")
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
                qsub -q batch@v-qsvr-fpga -I -l nodes="$node":ppn=2
            fi
        else
            printf "%s\n" "${red}You are currently on a node. Please exit the current node and try again.${end}"
        fi
    elif [ $number -eq 3 ]; 
    then
        if [ -z $currentNode ]; 
        then
            IFS="|"
            # readarray availableNodes < <(pbsnodes | grep -B 1 "state = free"| grep -T '13[0-6]' | grep -o '...$')
            readarray availableNodes < <(pbsnodes | grep -B 1 "state = free"| grep -o -E "${noHardwareNodes[*]}")
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
                qsub -I -l nodes="$node":ppn=2
            fi
        else
            printf "%s\n" "${red}You are currently on a node. Please exit the current node and try again.${end}"
        fi
    elif [ $number -eq 4 ];
    then
        if [ -z $currentNode ]; 
        then
            IFS="|"
            readarray availableNodesNohardware < <(pbsnodes | grep -B 1 "state = free" | grep -o -E "${noHardwareNodes[*]}")
            readarray availableNodesArria < <(pbsnodes -s v-qsvr-fpga | grep -B 4 'arria10' | grep -B 1 "state = free"| grep -o -E "${arria10Nodes[*]}")
            readarray availableNodesStratix < <(pbsnodes -s v-qsvr-fpga | grep -B 4 'darby' | grep -B 1 "state = free"  | grep -o -E "${stratix10Nodes[*]}")
            unset IFS
            # availableNodes=() #initialize the empty array
            # availableNodes+=($availableNodesNohardware) #append an
            # availableNodes+=($availableNodesArria)
            # availableNodes+=($availableNodesStratix)
            # echo ${availableNodes}
            availableNodes=( "${availableNodesNohardware[@]}" "${availableNodesArria[@]}" "${availableNodesStratix[@]}" )
            #echo ${availableNodes[@]}
            #echo ${availableNodes[2]}
            if [ ${#availableNodes[@]} == 0  ];
            then
                echo
                echo
                printf "%s\n" "${red}--------------------------------------------------------------- ${end} "
                printf "%s\n" "${red}No available nodes. Try again later. ${end} "
                printf "%s\n" "${red}--------------------------------------------------------------- ${end} "
            else
                echo "                               Showing available nodes below:                          "
                echo --------------------------------------------------------------------------------------
                printf "%s\n" "${blu}Nodes with no attached hardware:${end}          "
                IFS="|"
                # pbsnodes | grep -B 1 "state = free"| grep -T '13[0-6]' | grep -o '...$'
                pbsnodes | grep -B 1 "state = free" | grep -o -E "${noHardwareNodes[*]}"
                unset IFS
                echo --------------------------------------------------------------------------------------
                printf "%s\n" "${blu}Nodes with Arria 10${end}         "
                IFS="|"
                pbsnodes -s v-qsvr-fpga | grep -B 4 'arria10' | grep -B 1 "state = free"| grep -o -E "${arria10Nodes[*]}"
                printf "%s\n" "${blu}Nodes with Stratix 10${end}         "
                pbsnodes -s v-qsvr-fpga | grep -B 4 'darby' | grep -B 1 "state = free"  | grep -o -E "${stratix10Nodes[*]}"
                unset IFS
                echo --------------------------------------------------------------------------------------
                echo
                echo What node would you like to use?
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
                #nodeNumber="$(echo $node | grep -o '...$')"
                #find out if the nodeNumber is on the fpga queue to know which qsub command to call
                is_in_fpga_queue="$(pbsnodes -s v-qsvr-fpga | grep -B 4 fpga | grep -o $node )"
                if [ -z is_in_fpga_queue ]; #if is_in_fpga_queue is empty then it is not on the fpga queue
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
    red=$'\e[1;31m'
    blu=$'\e[1;34m'
    end=$'\e[0m'

    noHardwareNodes=("s001-n043" "s001-n044") #"s001-n130" "s001-n131" "s001-n132" "s001-n133" "s001-n134" "s001-n135" "s001-n136")
    arria10Nodes=("s005-n005" "s005-n006" "s005-n007" "s001-n137" "s001-n138" "s001-n139")
    stratix10Nodes=("s001-n189")
    allNodes=( "${noHardwareNodes[@]}" "${arria10Nodes[@]}" "${stratix10Nodes[@]}" )

    QUARTUS_LITE_VERSIONS=("18.1")
    QUARTUS_STANDARD_VERSIONS=("18.1")
    QUARTUS_PRO_VERSIONS=("17.1" "18.1" "19.2" "19.3")

    #defined paths
    GLOB_INTELFPGA_PRO="/glob/development-tools/versions/intelFPGA_pro"
    GLOB_INTELFPGA_LITE="/glob/development-tools/versions/intelFPGA_lite"
    GLOB_INTELFPGA_STANDARD="/glob/development-tools/versions/intelFPGA"
    QUARTUS_PATHS=($GLOB_INTELFPGA_LITE $GLOB_INTELFPGA_STANDARD $GLOB_INTELFPGA_PRO)
    OPT_INTEL="/opt/intel"
    OPT_INTEL_2="/opt/intel/2.0.1"
    GLOB_FPGASUPPORTSTACK="/glob/development-tools/versions/fpgasupportstack"

    echo
    printf "%s\n" "${blu}Which tool would you like to source? Please select a number from the list below: ${end}"
    echo
    echo "1) Quartus Prime Lite"
    echo "2) Quartus Prime Standard"
    echo "3) Quartus Prime Pro"
    echo "4) HLS"
    echo "5) Arria 10 Development Stack (only if on n137, n138, n139), OpenCL on all nodes"
    echo "6) Stratix 10 Development Stack (only if on n189), OpenCL on all nodes"
    echo
    echo -n "Number: "  
    read -e number

    until [ "$number" -lt 10 ] && [ "$number" -gt 0 ]
    do
        printf "%s\n" "${red}Invalid Entry. Please input a correct number from the list above. ${end} "
        echo -n "Number: "
        read -e number
    done


    if [ $number -eq 1  ]; 
    then
        len=${#QUARTUS_LITE_VERSIONS[@]}
        if [ $len -eq 0 ];
        then
            echo "${red}Something went wrong, does not support any quartus Lite versions ${end}"
        elif [ $len -eq 1 ];
        then
            #source the one version
            echo "sourcing $GLOB_INTELFPGA_LITE/${QUARTUS_LITE_VERSIONS[0]}/init_quartus.sh"
            source $GLOB_INTELFPGA_LITE/${QUARTUS_LITE_VERSIONS[0]}/init_quartus.sh
            echo
        elif [ $len -gt 1 ];
        then
            echo "${blu}which quartus Lite version would you like to source?${end}"
            # let i=1
            # for version in $QUARTUS_LITE_VERSIONS
            for (( i=0; i<${len}; i++ ));
            do
                # echo "${i} ) ${version}"
                echo "${i} ) ${QUARTUS_LITE_VERSIONS[$i]}"
                # let i++
            done
            echo
            echo -n "2nd Number: "  
            read -e second_number
            until [ $len -gt $second_number ];
            do
                printf "%s\n" "${red}Invalid Entry. Please input a correct number from the list above. ${end} "
                echo -n "2nd Number: "
                read -e second_number
            done
            echo "sourcing $GLOB_INTELFPGA_LITE/${QUARTUS_LITE_VERSIONS[$second_number]}/init_quartus.sh"
            #source depending on what second_number they chose
            source $GLOB_INTELFPGA_LITE/${QUARTUS_LITE_VERSIONS[$second_number]}/init_quartus.sh
            echo
        else
            echo "${red}Something went wrong sourcing the lite version ${end}"
        fi

    elif [ $number -eq 2 ];
    then
        len=${#QUARTUS_STANDARD_VERSIONS[@]}
        if [ $len -eq 0 ];
        then
            echo "${red}Something went wrong, does not support any quartus standard versions ${end}"
        elif [ $len -eq 1 ];
        then
            echo "sourcing $GLOB_INTELFPGA_STANDARD/${QUARTUS_STANDARD_VERSIONS[0]}/init_quartus.sh"
            #source the one version
            source $GLOB_INTELFPGA_STANDARD/${QUARTUS_STANDARD_VERSIONS[0]}/init_quartus.sh
            echo
        elif [ $len -gt 1 ];
        then
            echo "${blu}which quartus standard version would you like to source?${end}"
            # let i=1
            # for version in $QUARTUS_LITE_VERSIONS
            for (( i=0; i<${len}; i++ ));
            do
                # echo "${i} ) ${version}"
                echo "${i} ) ${QUARTUS_STANDARD_VERSIONS[$i]}"
                # let i++
            done
            echo
            echo -n "2nd Number: "  
            read -e second_number
            until [ $len -gt $second_number ];
            do
                printf "%s\n" "${red}Invalid Entry. Please input a correct number from the list above. ${end} "
                echo -n "2nd Number: "
                read -e second_number
            done
            echo "sourcing $GLOB_INTELFPGA_STANDARD/${QUARTUS_STANDARD_VERSIONS[$second_number]}/init_quartus.sh"
            #source depending on what second_number they chose
            source $GLOB_INTELFPGA_STANDARD/${QUARTUS_STANDARD_VERSIONS[$second_number]}/init_quartus.sh
            echo
        else
            echo "${red}Something went wrong sourcing the standard version ${end}"
        fi

    elif [ $number -eq 3 ];
    then
        len=${#QUARTUS_PRO_VERSIONS[@]}
        if [ $len -eq 0 ];
        then
            echo "${red}Something went wrong, does not support any quartus pro versions ${end}"
        elif [ $len -eq 1 ];
        then
            echo "sourcing $GLOB_INTELFPGA_PRO/${QUARTUS_PRO_VERSIONS[0]}/init_quartus.sh"
            #source the one version
            source $GLOB_INTELFPGA_PRO/${QUARTUS_PRO_VERSIONS[0]}/init_quartus.sh
            echo
        elif [ $len -gt 1 ];
        then
            echo "${blu}which quartus pro version would you like to source?${end}"
            # let i=1
            # for version in $QUARTUS_LITE_VERSIONS
            for (( i=0; i<${len}; i++ ));
            do
                # echo "${i} ) ${version}"
                echo "${i} ) ${QUARTUS_PRO_VERSIONS[$i]}"
                # let i++
            done
            echo
            #echo "length of array is ${len}"
            echo -n "2nd Number: "  
            read -e second_number
            until [ $len -gt $second_number ];
            do
                printf "%s\n" "${red}Invalid Entry. Please input a correct number from the list above. ${end} "
                echo -n "2nd Number: "
                read -e second_number
            done
            echo "sourcing $GLOB_INTELFPGA_PRO/${QUARTUS_PRO_VERSIONS[$second_number]}/init_quartus.sh"
            #source depending on what second_number they chose
            source $GLOB_INTELFPGA_PRO/${QUARTUS_PRO_VERSIONS[$second_number]}/init_quartus.sh
            echo
        else
            echo "${red}Something went wrong sourcing the pro version ${end}"
        fi
    elif [ $number -eq 4 ]; #case for HLS
    then
        
        #ask which quartus version
        echo "${blu}which quartus version would you like?${end}"
        echo "1) Quartus Prime Standard"
        echo "2) Quartus Prime Lite"
        echo "3) Quartus Prime Pro"
        echo
        #echo "length of array is ${len}"
        echo -n "Number: "  
        read -e qnumber
        until [ "$qnumber" -lt 4 ] && [ "$number" -gt 0 ]
        do
            printf "%s\n" "${red}Invalid Entry. Please input a correct number from the list above. ${end} "
            echo -n "Number: "
            read -e qnumber
        done

        if [ $qnumber -eq 1 ]; #case for quartus STANDARD
        then
            len=${#QUARTUS_STANDARD_VERSIONS[@]}
            if [ $len -eq 0 ];
            then
                echo "${red}Something went wrong, does not support any quartus standard versions ${end}"
            elif [ $len -eq 1 ];
            then
                export INTELFPGAOCLSDKROOT=$GLOB_INTELFPGA_STANDARD/${QUARTUS_STANDARD_VERSIONS[0]}/hls

                #source the one version of quartus
                echo "sourcing $GLOB_INTELFPGA_STANDARD/${QUARTUS_STANDARD_VERSIONS[0]}/init_quartus.sh"
                source $GLOB_INTELFPGA_STANDARD/${QUARTUS_STANDARD_VERSIONS[0]}/init_quartus.sh

                #source the one version of OpenCL
                echo "sourcing $GLOB_INTELFPGA_STANDARD/${QUARTUS_STANDARD_VERSIONS[0]}/hls/init_hls.sh"
                source $GLOB_INTELFPGA_STANDARD/${QUARTUS_STANDARD_VERSIONS[0]}/hls/init_hls.sh

                echo
            elif [ $len -gt 1 ];
            then
                #ask which verison of openCL
                echo "${blu}which openCL version would you like to source?${end}"
                for (( i=0; i<${len}; i++ ));
                do
                    echo "${i} ) ${QUARTUS_LITE_VERSIONS[$i]}"
                done
                echo
                #echo "length of array is ${len}"
                echo -n "2nd Number: "  
                read -e second_number
                until [ $len -gt $second_number ];
                do
                    printf "%s\n" "${red}Invalid Entry. Please input a correct number from the list above. ${end} "
                    echo -n "2nd Number: "
                    read -e second_number
                done

                export INTELFPGAOCLSDKROOT=$GLOB_INTELFPGA_LITE/${QUARTUS_LITE_VERSIONS[$second_number]}/hls

                #source quartus
                echo "sourcing $INTELFPGAOCLSDKROOT/../init_quartus.sh"
                source $INTELFPGAOCLSDKROOT/../init_quartus.sh

                #source opencl
                echo "sourcing $INTELFPGAOCLSDKROOT/init_hls.sh"
                source $INTELFPGAOCLSDKROOT/init_hls.sh
            
            else
                echo "something went wrong with sourcing hls for quartus lite"
            fi
        elif [ $qnumber -eq 2 ]; #case for quartus LITE
        then
            len=${#QUARTUS_LITE_VERSIONS[@]}
            if [ $len -eq 0 ];
            then
                echo "${red}Something went wrong, does not support any quartus lite versions ${end}"
            elif [ $len -eq 1 ];
            then
                export INTELFPGAOCLSDKROOT=$GLOB_INTELFPGA_LITE/${QUARTUS_LITE_VERSIONS[0]}/hls

                #source the one version of quartus
                echo "sourcing $GLOB_INTELFPGA_LITE/${QUARTUS_LITE_VERSIONS[0]}/init_quartus.sh"
                source $GLOB_INTELFPGA_LITE/${QUARTUS_PRO_VERSIONS[0]}/init_quartus.sh

                #source the one version of OpenCL
                echo "sourcing $GLOB_INTELFPGA_LITE/${QUARTUS_LITE_VERSIONS[0]}/hls/init_hls.sh"
                source $GLOB_INTELFPGA_LITE/${QUARTUS_LITE_VERSIONS[0]}/hls/init_hls.sh

                echo
            elif [ $len -gt 1 ];
            then
                #ask which verison of openCL
                echo "${blu}which openCL version would you like to source?${end}"
                for (( i=0; i<${len}; i++ ));
                do
                    echo "${i} ) ${QUARTUS_LITE_VERSIONS[$i]}"
                done
                echo
                #echo "length of array is ${len}"
                echo -n "2nd Number: "  
                read -e second_number
                until [ $len -gt $second_number ];
                do
                    printf "%s\n" "${red}Invalid Entry. Please input a correct number from the list above. ${end} "
                    echo -n "2nd Number: "
                    read -e second_number
                done

                export INTELFPGAOCLSDKROOT=$GLOB_INTELFPGA_LITE/${QUARTUS_LITE_VERSIONS[$second_number]}/hls

                #source quartus
                echo "sourcing $INTELFPGAOCLSDKROOT/../init_quartus.sh"
                source $INTELFPGAOCLSDKROOT/../init_quartus.sh

                #source opencl
                echo "sourcing $INTELFPGAOCLSDKROOT/init_hls.sh"
                source $INTELFPGAOCLSDKROOT/init_hls.sh
            
            else
                echo "something went wrong with sourcing hls for quartus lite"
            fi
        elif [ $qnumber -eq 3 ]; #case for quartus PRO
        then
            len=${#QUARTUS_PRO_VERSIONS[@]}
            if [ $len -eq 0 ];
            then
                echo "${red}Something went wrong, does not support any quartus pro versions ${end}"
            elif [ $len -eq 1 ];
            then
                export INTELFPGAOCLSDKROOT=$GLOB_INTELFPGA_PRO/${QUARTUS_PRO_VERSIONS[0]}/hls

                #source the one version of quartus
                echo "sourcing $GLOB_INTELFPGA_PRO/${QUARTUS_PRO_VERSIONS[0]}/init_quartus.sh"
                source $GLOB_INTELFPGA_PRO/${QUARTUS_PRO_VERSIONS[0]}/init_quartus.sh

                #source the one version of OpenCL
                echo "sourcing $GLOB_INTELFPGA_PRO/${QUARTUS_PRO_VERSIONS[0]}/hls/init_hls.sh"
                source $GLOB_INTELFPGA_PRO/${QUARTUS_PRO_VERSIONS[0]}/hls/init_hls.sh

                echo
            elif [ $len -gt 1 ];
            then
                #ask which verison of openCL
                echo "${blu}which openCL version would you like to source?${end}"
                for (( i=0; i<${len}; i++ ));
                do
                    echo "${i} ) ${QUARTUS_PRO_VERSIONS[$i]}"
                done
                echo
                #echo "length of array is ${len}"
                echo -n "2nd Number: "  
                read -e second_number
                until [ $len -gt $second_number ];
                do
                    printf "%s\n" "${red}Invalid Entry. Please input a correct number from the list above. ${end} "
                    echo -n "2nd Number: "
                    read -e second_number
                done

                export INTELFPGAOCLSDKROOT=$GLOB_INTELFPGA_PRO/${QUARTUS_PRO_VERSIONS[$second_number]}/hls

                #source quartus
                echo "sourcing $INTELFPGAOCLSDKROOT/../init_quartus.sh"
                source $INTELFPGAOCLSDKROOT/../init_quartus.sh

                #source opencl
                echo "sourcing $INTELFPGAOCLSDKROOT/init_hls.sh"
                source $INTELFPGAOCLSDKROOT/init_hls.sh
                export PATH=/glob/intel-python/python2/bin:${PATH}
            else
                echo "something went wrong with sourcing hls for quartus pro"
            fi
        else
            echo "something went wrong with case statements for hls"
        fi

    elif [ $number -eq 5 ]; #case for arria 10 development stack
    then
        #need to check if on correct node only on 137,138,139
        IFS="|"
        temp_string="$(echo $HOSTNAME | grep -o -E "${arria10Nodes[*]}")"
        unset IFS
        if [[ ${arria10Nodes[@]} =~ ${temp_string} && ${#temp_string} -eq 9 ]]; #this checks that user input is an available node and node has length of 9
        then
            echo "sourcing $GLOB_FPGASUPPORTSTACK/a10/1.2/inteldevstack/init_env.sh"
            source $GLOB_FPGASUPPORTSTACK/a10/1.2/inteldevstack/init_env.sh
            echo
            echo "sourcing $GLOB_FPGASUPPORTSTACK/a10/1.2/inteldevstack/intelFPGA_pro/hld/init_opencl.sh"
            source $GLOB_FPGASUPPORTSTACK/a10/1.2/inteldevstack/intelFPGA_pro/hld/init_opencl.sh
            echo
            echo "Putting python2 in the search path - required for Arria 10 development stack"
            export PATH=/glob/intel-python/python2/bin:${PATH}
        else
            echo "Not on an Arria10 node. You need to be on an Arria10 node to run Arria Development Stack"
        fi
    elif [ $number -eq 6 ]; #case for stratix 10 development stack
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
