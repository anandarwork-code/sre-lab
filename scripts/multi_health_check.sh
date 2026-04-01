#!/bin/bash

sre_vm1=192.168.122.152
sre_db=192.168.122.127
sre_mon=192.168.122.218
ssh_user=anand

green='\033[0;32m'
red='\033[0;31m'
nc='\033[0m'   # NC = No Color — resets back to normal

check_service() {

local label=$1
local ip=$2
local service=$3

echo  "[$label] $service "
result=$(ssh $ssh_user@$ip "systemctl is-active $service")
if [ "$result" == "active" ]; then
        echo -e "${green}OK${nc} "
else
        echo -e "${red}FAIL${nc} "
fi 
}

echo "------------------------------------------------------------------"
echo "$(date)"
echo "------------------------------------------------------------------"
check_service "sre-vm1" "$sre_vm1" "nginx"
check_service "sre-vm1" "$sre_vm1" "sreapp"
check_service "sre-db" "$sre_db" "mysqld"
check_service "sre-mon" "$sre_mon" "prometheus"
check_service "sre-vm1" "$sre_vm1" "gitea"
echo "------------------------------------------------------------------"
