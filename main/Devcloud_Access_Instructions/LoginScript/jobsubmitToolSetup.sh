NOCOLOR='\033[0m'
RED='\033[0;31m'
LIGHTBLUE='\033[1;34m'


job_submit()
{
    # initial check to see if user is logged into a node already
    if [ $HOSTNAME != "login-2" ];
    then
	echo -e "${RED}Your hostname is not login-2. You are probably already logged into a node.${NOCOLOR}"
	return 1
    fi

    echo -e "${LIGHTBLUE}How many hours do you need to compile?${NOCOLOR}"
    read -r walltime

    # Only integers accepted; maximum number is 48
    while ! [[ "$walltime" =~ ^[0-9]+$ ]] || [ $walltime -ge 48 ]; do
        echo -e "${RED}Invalid Entry. Please input an integer. ${NOCOLOR} "
        echo 
        echo "Number of hours needed: "
        read walltime
    done

    latest=`qsub -l walltime=$walltime:00:00 $1`
    echo $latest
}


job_status()
{
    # Latest job submitted status
    qstat -s $latest
}


job_delete()
{
    # Delete submitted job with argument name
    if ! [ -z "$1" ]
    then
	qdel $1
	echo "Job: " +  $1 + " deleted."
    else
    # Delete latest job submitted to be compiled if no argument exists
	qdel $latest
	echo "Job: " +  $latest + " deleted."
    fi
}





########################################################################################################
#   Latest Edit             #
#   -Mar 27 2020            #
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
allNodes=( "${noHardwareNodes[@]}" "${arria10Nodes[@]}" "${stratix10Nodes[@]}" )


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

    ARRIA10DEVSTACK_RELEASE=("1.2" "1.2.1")
    if [ argv=1 ]
    then
    echo
    printf "%s\n" "${blu}Which tool would you like to source?${end}"
    echo
    echo "1) Quartus Prime Lite"
    echo "2) Quartus Prime Standard"
    echo "3) Quartus Prime Pro"
    echo "4) HLS"
    echo "5) Arria 10 Development Stack + OpenCL"
    echo "6) Stratix 10 Development Stack + OpenCL"
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
        #need to check if on correct node only on 137,138,139
        IFS="|"
        temp_string="$(echo $HOSTNAME | grep -o -E "${arria10Nodes[*]}")"
        unset IFS
        if [[ ${arria10Nodes[@]} =~ ${temp_string} && ${#temp_string} -eq 9 ]]; #this checks that user input is an available node and node has length of 9
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
