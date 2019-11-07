
login()
{
        red=$'\e[1;31m'
        blu=$'\e[1;34m'
        end=$'\e[0m'
        echo
        echo "                               Showing available nodes below:                          "
        echo --------------------------------------------------------------------------------------
        printf "%s\n" "${blu}Nodes with no attached hardware:${end}          "
        pbsnodes |grep -B 1 "state = free"| grep -T '13[0-9]' | grep -o '...$'
        echo
        echo --------------------------------------------------------------------------------------
        printf "%s\n" "${blu}Nodes 137-139 Arria 10 Cards... Node 189 Stratix 10${end}         "
        pbsnodes -s v-qsvr-fpga | grep -B 1 "state = free"| grep -B 1 '13[0-9]' | grep -o '...$'
        pbsnodes -s v-qsvr-fpga | grep -B 1 "state = free"| grep -B 1 '189' | grep -o '...$'

        echo --------------------------------------------------------------------------------------
        echo
        echo What node would you like to use? Insert \#130-139, or 189
        read node
        echo
        echo --------------------------------------------------------------------------------------
        printf "%s\n" "${blu}Please copy and paste the following text in a new mobaxterm terminal: ${end} "
        echo
        printf  "%s\n" "${blu}ssh -L 4002:s001-n"$node":22 colfax-intel${end} "
        echo
        echo --------------------------------------------------------------------------------------
        echo
        if [ "$node" -le 136 ]; then
                qsub -I -l nodes=s001-n"$node":ppn=2
        else
                qsub -q batch@v-qsvr-fpga -I -l nodes=s001-n"$node":ppn=2
        fi
}

