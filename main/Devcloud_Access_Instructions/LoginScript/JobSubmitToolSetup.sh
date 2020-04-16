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


job_submit()
{
    # initial check to see if user is logged into a node already
    if [ $HOSTNAME != "login-2" ];
    then
	echo -e "${red}Your hostname is not login-2. You are probably already logged into a node.${end}"
	return 1
    fi

    echo -e "${blu}How many hours do you need to compile?${end}"
    read -r walltime

    # Only integers accepted; maximum number is 48
    while ! [[ "$walltime" =~ ^[0-9]+$ ]] || [ $walltime -ge 48 ]; do
        echo -e "${red}Invalid Entry. Please input an integer. ${end} "
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
    # Delete latest job submitted to be compiled if no argument exists
	qdel $latest
	echo "Job: " +  $latest + " deleted."
}
