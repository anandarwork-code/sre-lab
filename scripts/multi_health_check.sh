#!/bin/bash
# multi_health_check.sh
# SSHes into sre-vm1, sre-db, and sre-mon and checks the status of 5
# services (nginx, sreapp, mysqld, prometheus, gitea) via
# `systemctl is-active`, color-coded OK/FAIL output.
#
# Usage:   bash multi_health_check.sh   (not yet chmod +x)
# Flags:   none
# Requires: passwordless SSH (key auth) as $ssh_user to all 3 targets
# Output:  stdout only
# Exit:    0 always
# Cron:    runs every 15 min
# Note:    Gitea check included here predates Gitea's retirement as a
#          workflow target (S48) — service still runs, check still valid

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
