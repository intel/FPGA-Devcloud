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



Help() {
    echo "-Description-"
    echo "The tools_setup is a function created to aid the setup their wanted environment in a devcloud node"
    echo "If you would like to see all options simply use tools_setup with no arguments. This is an user interactive mode."
    echo "to speed up the processs you can use the following options to speed up your tool setup"
    echo "Elimanating user interaction within function"
    echo
    echo
    echo ""
    echo "Options:"
    echo "QL		Quartus Lite"
    echo "QS		Quartus Standard"
    echo "QP		Quartus Pro"
    echo "HLS		High-Level Synthesis"
    echo "A10DS		Arria 10 Development Stack"
    echo "A10OAPI	Arria 10 One API"
    echo "S10DS		Stratix 10 Development Stack"
    echo
    echo
    echo "For all the Quartus editions available you must also include the quartus version you would like to use."
    echo "Example:"
    echo "tools_setup QL 18.1"
    echo
    echo "To setup the HLS tool, you also need to include the Quartus edition and version you would like to use."
    echo "Example:"
    echo "tools_setup HLS QL 18.1"
    echo ""
    echo ""

}



########################################################################################################
#   Latest Edit             #
#   -Mar 31 2020 Version2   #
#############################

tools_setups()
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
    argv1="$1"
    argv2="$2"
    argv3="$3"

    while getopts ":h" option; do
	case $option in
	    h)  # display Help
	    	Help
	    	break;;
	    \?) # incorrect option
            	echo "Error: Invalid option"
            	break;;
	esac
    done

    if [ -z $argv1 ];
    then
	echo
	printf "%s\n" "${blu}Which tool would you like to source?${end}"
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
    fi


    if [[ $number -eq 1 || ( -n $argv1 && $argv1 = "QL" ) ]];
    then
        len=${#QUARTUS_LITE_RELEASE[@]}
        if [ $len -eq 0 ];
        then
            echo "${red}Something went wrong, does not support any quartus Lite releases ${end}"
        elif [ $len -eq 1 ];
        then
            if [[ -z "$argv2" || ( -n $argv2 && ${QUARTUS_LITE_RELEASE[0]} =~ "$argv2" ) ]];
	    then
		# source the one release
            	echo "sourcing $GLOB_INTELFPGA_LITE/${QUARTUS_LITE_RELEASE[0]}/init_quartus.sh"
            	source $GLOB_INTELFPGA_LITE/${QUARTUS_LITE_RELEASE[0]}/init_quartus.sh
            	echo
	    else
                printf "%s\n" "${red}Invalid Entry. Please input a correct Quartus Lite version. ${end} "
	    fi
        elif [ $len -gt 1 ];
        then
	    if [[ -n "$argv2" && ${QUARTUS_LITE_RELEASE[*]} =~ (^|[[:space:]])"$argv2"($|[[:space:]]) ]];
	    then
		echo "sourcing $GLOB_INTELFPGA_LITE/$argv2/init_quartus.sh"
            	# source depending on what argument was provided
            	source $GLOB_INTELFPGA_LITE/$argv2/init_quartus.sh
            	echo
	    elif [[ -n "$argv2" || ( -n "$argv1" && -z "$argv2" ) ]];
	    then
                printf "%s\n" "${red}Invalid Entry. Please input a correct Quartus Lite version. ${end} "
	    else
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
	    fi
        else
            echo "${red}Something went wrong sourcing the lite release ${end}"
        fi

    elif [[ $number -eq 2 || ( -n $argv1 && $argv1 = "QS" ) ]];
    then
        len=${#QUARTUS_STANDARD_RELEASE[@]}
        if [ $len -eq 0 ];
        then
            echo "${red}Something went wrong, does not support any quartus standard releases ${end}"
        elif [ $len -eq 1 ];
        then
            if [[ -z "$argv2" || ( -n $argv2 && ${QUARTUS_STANDARD_RELEASE[0]} =~ "$argv2" ) ]];
	    then
            	echo "sourcing $GLOB_INTELFPGA_STANDARD/${QUARTUS_STANDARD_RELEASE[0]}/init_quartus.sh"
            	# source the one release
            	source $GLOB_INTELFPGA_STANDARD/${QUARTUS_STANDARD_RELEASE[0]}/init_quartus.sh
            	echo
	    else
                printf "%s\n" "${red}Invalid Entry. Please input a correct Quartus Standard version. ${end} "
	    fi
        elif [ $len -gt 1 ];
        then
	    if [[ -n "$argv2" && ${QUARTUS_STANDARD_RELEASE[*]} =~ (^|[[:space:]])"$argv2"($|[[:space:]]) ]];
	    then
            	echo "sourcing $GLOB_INTELFPGA_STANDARD/$argv2/init_quartus.sh"
            	# source depending on what argument was provided
            	source $GLOB_INTELFPGA_STANDARD/$argv2/init_quartus.sh
            	echo
	    elif [[ -n "$argv2" || ( -n "$argv1" && -z "$argv2" ) ]];
	    then
                printf "%s\n" "${red}Invalid Entry. Please input a correct Quartus Standard version. ${end} "
	    else
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
            	# source depending on what second_number they chose
            	source $GLOB_INTELFPGA_STANDARD/${QUARTUS_STANDARD_RELEASE[$second_number]}/init_quartus.sh
            	echo
	    fi
        else
            echo "${red}Something went wrong sourcing the standard release ${end}"
        fi

    elif [[ $number -eq 3 || ( -n $argv1 && $argv1 = "QP" ) ]];
    then
        len=${#QUARTUS_PRO_RELEASE[@]}
        if [ $len -eq 0 ];
        then
            echo "${red}Something went wrong, does not support any quartus pro releases ${end}"
        elif [ $len -eq 1 ];
        then
            if [[ -z "$argv2" || ( -n $argv2 && ${QUARTUS_PRO_RELEASE[0]} =~ "$argv2" ) ]];
	    then
            	echo "sourcing $GLOB_INTELFPGA_PRO/${QUARTUS_PRO_RELEASE[0]}/init_quartus.sh"
           	# source the one release
            	source $GLOB_INTELFPGA_PRO/${QUARTUS_PRO_RELEASE[0]}/init_quartus.sh
            	echo
	    else
                printf "%s\n" "${red}Invalid Entry. Please input a correct Quartus Pro version. ${end}"
	    fi
        elif [ $len -gt 1 ];
        then
	    if [[ -n "$argv2" && ${QUARTUS_PRO_RELEASE[*]} =~ (^|[[:space:]])"$argv2"($|[[:space:]]) ]];
	    then
            	echo "sourcing $GLOB_INTELFPGA_PRO/$argv2/init_quartus.sh"
            	# source depending on what argument was provided
            	source $GLOB_INTELFPGA_PRO/$argv2/init_quartus.sh
            	echo
	    elif [[ -n "$argv2" || ( -n "$argv1" && -z "$argv2" ) ]];
	    then
                printf "%s\n" "${red}Invalid Entry. Please input a correct Quartus Pro version. ${end} "
	    else
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
	    fi
        else
            echo "${red}Something went wrong sourcing the pro release ${end}"
        fi
    elif [[ $number -eq 4 || ( -n $argv1 && $argv1 = "HLS" ) ]];  # case for HLS
    then

	if [[ -z "$argv2" && -n "$argv1" ]];
	then
	    echo "${red}Invalid Entry. Please include a Quartus edition you would like. ${end}"
	    return
	elif [ -n "$argv2" ];
	then
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
            	printf "%s\n" "${red}Invalid Entry. Please input a correct number from the list above. ${end} "
            	echo -n "Number: "
            	read -e qnumber
            done
	fi

        if [[ $qnumber -eq 1 || ( -n $argv2 && $argv2 = "QS" ) ]];  # case for quartus STANDARD
        then
            len=${#QUARTUS_STANDARD_RELEASE[@]}
            if [ $len -eq 0 ];
            then
                echo "${red}Something went wrong, does not support any quartus standard releases ${end}"
            elif [ $len -eq 1 ];
            then
            	if [[ -z "$argv3" || ( -n $argv3 && ${QUARTUS_STANDARD_RELEASE[0]} =~ "$argv3" ) ]];
	    	then
                    export INTELFPGAOCLSDKROOT=$GLOB_INTELFPGA_STANDARD/${QUARTUS_STANDARD_RELEASE[0]}/hls

                    # source the one release of quartus
                    echo "sourcing $GLOB_INTELFPGA_STANDARD/${QUARTUS_STANDARD_RELEASE[0]}/init_quartus.sh"
                    source $GLOB_INTELFPGA_STANDARD/${QUARTUS_STANDARD_RELEASE[0]}/init_quartus.sh

                    # source the one release of OpenCL
                    echo "sourcing $GLOB_INTELFPGA_STANDARD/${QUARTUS_STANDARD_RELEASE[0]}/hls/init_hls.sh"
                    source $GLOB_INTELFPGA_STANDARD/${QUARTUS_STANDARD_RELEASE[0]}/hls/init_hls.sh
                    echo
	    	else
                    printf "%s\n" "${red}Invalid Entry. Please input a correct Quartus Standard version. ${end}"
	    	fi
            elif [ $len -gt 1 ];
            then
		if [[ -n "$argv3" && ${QUARTUS_STANDARD_RELEASE[*]} =~ (^|[[:space:]])"$argv3"($|[[:space:]]) ]];
		then
                    export INTELFPGAOCLSDKROOT=$GLOB_INTELFPGA_STANDARD/$argv3/hls

		    # source quartus
                    echo "sourcing $INTELFPGAOCLSDKROOT/../init_quartus.sh"
                    source $INTELFPGAOCLSDKROOT/../init_quartus.sh

                    # source opencl
                    echo "sourcing $INTELFPGAOCLSDKROOT/init_hls.sh"
                    source $INTELFPGAOCLSDKROOT/init_hls.sh
		elif [[ -n "$argv3" || ( -n "$argv2" && -z "$argv3" ) ]];
		then
		    printf "%s\n" "${red}Invalid Entry. Please input a correct Quartus Standard version. ${end}"
		else
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
        elif [[ $qnumber -eq 2 || ( -n $argv2 && $argv2 = "QL" ) ]];  # case for quartus LITE
        then
            len=${#QUARTUS_LITE_RELEASE[@]}
            if [ $len -eq 0 ];
            then
                echo "${red}Something went wrong, does not support any quartus lite releases ${end}"
            elif [ $len -eq 1 ];
            then
            	if [[ -z "$argv3" || ( -n $argv3 && ${QUARTUS_LITE_RELEASE[0]} =~ "$argv3" ) ]];
	    	then
                    export INTELFPGAOCLSDKROOT=$GLOB_INTELFPGA_LITE/${QUARTUS_LITE_RELEASE[0]}/hls

                    # source the one release of quartus
                    echo "sourcing $GLOB_INTELFPGA_LITE/${QUARTUS_LITE_RELEASE[0]}/init_quartus.sh"
                    source $GLOB_INTELFPGA_LITE/${QUARTUS_LITE_RELEASE[0]}/init_quartus.sh

                    # source the one release of OpenCL
                    echo "sourcing $GLOB_INTELFPGA_LITE/${QUARTUS_LITE_RELEASE[0]}/hls/init_hls.sh"
                    source $GLOB_INTELFPGA_LITE/${QUARTUS_LITE_RELEASE[0]}/hls/init_hls.sh
                    echo
	    	else
                    printf "%s\n" "${red}Invalid Entry. Please input a correct Quartus Lite version. ${end}"
	    	fi
            elif [ $len -gt 1 ];
            then
		if [[ -n "$argv3" && ${QUARTUS_LITE_RELEASE[*]} =~ (^|[[:space:]])"$argv3"($|[[:space:]]) ]];
		then
                    export INTELFPGAOCLSDKROOT=$GLOB_INTELFPGA_LITE/$argv3/hls

                    #source quartus
                    echo "sourcing $INTELFPGAOCLSDKROOT/../init_quartus.sh"
                    source $INTELFPGAOCLSDKROOT/../init_quartus.sh

                    #source opencl
                    echo "sourcing $INTELFPGAOCLSDKROOT/init_hls.sh"
                    source $INTELFPGAOCLSDKROOT/init_hls.sh
		elif [[ -n "$argv3" || ( -n "$argv2" && -z "$argv3" ) ]];
		then
		    printf "%s\n" "${red}Invalid Entry. Please input a correct Quartus Lite version. ${end}"
		else
                    # ask which verison of openCL
                    echo "${blu}Which Quartus release would you like to source?${end}"
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

                    export INTELFPGAOCLSDKROOT=$GLOB_INTELFPGA_LITE/${QUARTUS_LITE_RELEASE[$second_number]}/hls

                    #source quartus
                    echo "sourcing $INTELFPGAOCLSDKROOT/../init_quartus.sh"
                    source $INTELFPGAOCLSDKROOT/../init_quartus.sh

                    #source opencl
                    echo "sourcing $INTELFPGAOCLSDKROOT/init_hls.sh"
                    source $INTELFPGAOCLSDKROOT/init_hls.sh
		fi
            else
                echo "${red}Something went wrong with sourcing HLS for Quartus Prime Lite ${end}"
            fi
        elif [[ $qnumber -eq 3 || ( -n $argv2 && $argv2 = "QP" ) ]];  # case for quartus PRO
        then
            len=${#QUARTUS_PRO_RELEASE[@]}
            if [ $len -eq 0 ];
            then
                echo "${red}Something went wrong, does not support any quartus pro releases ${end}"
            elif [ $len -eq 1 ];
            then
            	if [[ -z "$argv3" || ( -n $argv3 && ${QUARTUS_PRO_RELEASE[0]} =~ "$argv3" ) ]];
	    	then
                    export INTELFPGAOCLSDKROOT=$GLOB_INTELFPGA_PRO/${QUARTUS_PRO_RELEASE[0]}/hls

                    # source the one release of quartus
                    echo "sourcing $GLOB_INTELFPGA_PRO/${QUARTUS_PRO_RELEASE[0]}/init_quartus.sh"
                    source $GLOB_INTELFPGA_PRO/${QUARTUS_PRO_RELEASE[0]}/init_quartus.sh

                    # source the one release of OpenCL
                    echo "sourcing $GLOB_INTELFPGA_PRO/${QUARTUS_PRO_RELEASE[0]}/hls/init_hls.sh"
                    source $GLOB_INTELFPGA_PRO/${QUARTUS_PRO_RELEASE[0]}/hls/init_hls.sh
                    echo
	    	else
                    printf "%s\n" "${red}Invalid Entry. Please input a correct Quartus Pro version. ${end}"
	    	fi
            elif [ $len -gt 1 ];
            then
		if [[ -n "$argv3" && ${QUARTUS_PRO_RELEASE[*]} =~ (^|[[:space:]])"$argv3"($|[[:space:]]) ]];
		then
                    export INTELFPGAOCLSDKROOT=$GLOB_INTELFPGA_PRO/$argv3/hls

                    #source quartus
                    echo "sourcing $INTELFPGAOCLSDKROOT/../init_quartus.sh"
                    source $INTELFPGAOCLSDKROOT/../init_quartus.sh

                    #source opencl
                    echo "sourcing $INTELFPGAOCLSDKROOT/init_hls.sh"
                    source $INTELFPGAOCLSDKROOT/init_hls.sh
		elif [[ -n "$argv3" || ( -n "$argv2" && -z "$argv3" ) ]];
		then
		    printf "%s\n" "${red}Invalid Entry. Please input a correct Quartus Pro version. ${end}"
		else
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
		fi
            else
                echo "${red}Something went wrong with sourcing HLS for Quartus Prime Pro ${end}"
            fi
        else
            echo "${red}Something went wrong with case statements for HLS ${end}"
        fi

    elif [[ $number -eq 5 || ( -n $argv1 && $argv1 = "A10DS" ) ]]; #case for arria 10 development stack
    then
        #need to check if on correct node
        IFS="|"
        temp_string="$(echo $HOSTNAME | grep -o -E "${arria10Nodes[*]}")"
        unset IFS
        if [[ ${arria10Nodes[@]} =~ ${temp_string} && ${#temp_string} -eq 9 ]];  # this checks that user is currently on correct node and node name has length of 9
        then
	    if [ -z "$argv2" ];
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
                    printf "%s\n" "${red}Invalid Entry. Please input a correct number from the list above. ${end}"
                    echo -n "Number: "
                    read -e second_number
            	done
	    fi

	    if [[ -n "$argv2" && ${ARRIA10DEVSTACK_RELEASE[*]} =~ (^|[[:space:]])"$argv2"($|[[:space:]]) ]];
	    then
            	echo "sourcing $GLOB_FPGASUPPORTSTACK/a10/$argv2/inteldevstack/init_env.sh"
            	source $GLOB_FPGASUPPORTSTACK/a10/$argv2/inteldevstack/init_env.sh
		echo
	    elif [ -n "$argv2" ];
	    then
		printf "%s\n" "${red}Invalid Entry. Pleasee input a correct development stack release. ${end}"
		return
	    else
            	echo "sourcing $GLOB_FPGASUPPORTSTACK/a10/${ARRIA10DEVSTACK_RELEASE[$second_number]}/inteldevstack/init_env.sh"
            	source $GLOB_FPGASUPPORTSTACK/a10/${ARRIA10DEVSTACK_RELEASE[$second_number]}/inteldevstack/init_env.sh
		echo
            fi

            if [[ $second_number -eq 0 || ${ARRIA10DEVSTACK_RELEASE[0]} =~ (^|[[:space:]])"$argv2"($|[[:space:]]) ]];
            then
                echo "sourcing $GLOB_FPGASUPPORTSTACK/a10/${ARRIA10DEVSTACK_RELEASE[0]}/inteldevstack/intelFPGA_pro/hld/init_opencl.sh"
                source $GLOB_FPGASUPPORTSTACK/a10/${ARRIA10DEVSTACK_RELEASE[0]}/inteldevstack/intelFPGA_pro/hld/init_opencl.sh
                echo
            fi
            if [[ $second_number -eq 1 || ${ARRIA10DEVSTACK_RELEASE[1]} =~ (^|[[:space:]])"$argv2"($|[[:space:]]) ]];
            then
                echo "sourcing $GLOB_FPGASUPPORTSTACK/a10/${ARRIA10DEVSTACK_RELEASE[1]}/intelFPGA_pro/hld/init_opencl.sh"
                source $GLOB_FPGASUPPORTSTACK/a10/${ARRIA10DEVSTACK_RELEASE[1]}/intelFPGA_pro/hld/init_opencl.sh
                echo
            fi

            echo "Putting python2 in the search path - required for Arria 10 development stack"
            export PATH=/glob/intel-python/python2/bin:${PATH}
        else
            echo "Not on an Arria10 Development Stack node. You need to be on an Arria10 Development Stack node to run Arria Development Stack"
        fi
    elif [[ $number -eq 6 || ( -n $argv1 && $argv1 = "A10OAPI" ) ]];  # case for Arria 10 OneAPI
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
    elif [[ $number -eq 7 || ( -n $argv1 && $argv1 = "S10DS" ) ]];  # case for Stratix 10 Development Stack
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
	if [ -z "argv1" ];
	then
	    echo "printing else statement for sourcing cases"
	else
	    echo "${red}Invalid argument. ${end}"
	fi
    fi

}
