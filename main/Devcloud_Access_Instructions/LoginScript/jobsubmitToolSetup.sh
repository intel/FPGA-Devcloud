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
