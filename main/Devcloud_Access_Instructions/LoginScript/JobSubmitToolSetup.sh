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




######################################################################################################
#					#
#	Revised April 16, 2020		#
#########################################

Reserch: 
qsub .... "hob.sh>logfile" as opposed to each line showing > result or >> result


Status: 
qstat -s batch@v-qsvr-fpga


qsub -q batch@v-qsvr-fpga job.sh
qsub -l nodes=1:fpga_compile:ppn=2 -d . job.sh
qsub -l nodes=1:fpga:ppn=2 -d . job.sh (goes to OAPI node -> s001-n081)
qsub -l nodes=fpga:fpga:ppn=2 -d . job.sh (also goes to same OAPI)

qsub -q batch@v-qsvr-fpga -l nodes=s001-n139:ppn=2 -d . job.sh



Output:
cat result
tail -n 1000 -f result


Make .sh > exe Process:
chmod 775 hob.sh
./hob.sh
cat result


pbsnodes > foo