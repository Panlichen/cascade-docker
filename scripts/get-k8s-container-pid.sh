#!/bin/bash

# case insensitive for string comparison
shopt -s nocasematch

colorful_print() {
    color_prefix="0;30"
    case $1 in
        "red")
            color_prefix="0;31"
            ;;
        "green")
            color_prefix="0;32"
            ;;
        "orange")
            color_prefix="0;33"
            ;;
        "blue")
            color_prefix="0;34"
            ;;
        "purple")
            color_prefix="0;35"
            ;;
        "cyan")
            color_prefix="0;36"
            ;;
        "lightgray")
            color_prefix="0;37"
            ;;
        "darkgray")
            color_prefix="1;30"
            ;;
        "lightred")
            color_prefix="1;31"
            ;;
        "lightgreen")
            color_prefix="1;32"
            ;;
        "yellow")
            color_prefix="1;33"
            ;;
        "lightblue")
            color_prefix="1;34"
            ;;
        "lightpurple")
            color_prefix="1;35"
            ;;
        "lightcyan")
            color_prefix="1;36"
            ;;
        "white")
            color_prefix="1;37"
            ;;
    esac;
    echo -e "\e[${color_prefix}m $2 $3 $4 $5 $6 $7 $8 $9 \e[0m"
}

if [[ $# -lt 1 ]]; then
    colorful_print blue "You can also specify a prefix: $0 <prefix>"
    colorful_print blue "example: $0 cascade-gpu"
    colorful_print green "Now retrieve all containers"
    sudo docker container ls > info.txt
else
    prefix=$1
    sudo docker container ls | grep $prefix > info.txt
fi

IDs=`awk 'NR>2{print $1}' info.txt`

ID_ARRAY=()
NAME_ARRAY=()
PID_ARRAY=()
CMD_ARRAY=()
OOMKilled_ARRAY=()
Memory_ARRAY=()

idx=0
for ID in ${IDs}
do
    ID_ARRAY[${idx}]=$ID
    PID_ARRAY[${idx}]=`sudo docker inspect -f '{{.State.Pid}}' $ID`
    NAME_ARRAY[${idx}]=`sudo docker inspect -f '{{.Name}}' $ID`
    CMD_ARRAY[${idx}]=`sudo docker inspect -f '{{.Path}}' $ID`
    OOMKilled_ARRAY[${idx}]=`sudo docker inspect -f '{{.State.OOMKilled}}' $ID`
    Memory_ARRAY[${idx}]=`sudo docker inspect -f '{{.HostConfig.Memory}}' $ID`
    idx=$[idx+1]
done

echo "NAME CMD PID Memory OOMKilled CONTAIER_ID" > container_pid.txt
for (( idx=0; idx<${#ID_ARRAY[*]}; idx++ )); do
    echo "${NAME_ARRAY[${idx}]} ${CMD_ARRAY[${idx}]} ${PID_ARRAY[${idx}]} ${Memory_ARRAY[${idx}]} ${OOMKilled_ARRAY[${idx}]} ${ID_ARRAY[${idx}]}" >> container_pid.txt
done

column -t container_pid.txt | cat

rm info.txt container_pid.txt