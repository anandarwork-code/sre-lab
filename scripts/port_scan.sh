#!/bin/bash
# port_scan.sh
# Scans a target IP for 6 common lab ports (80, 22, 3000, 3306, 8080,
# 9100) using nc, color-coded OPEN/CLOSED output.
#
# Usage:   ./port_scan.sh <target_ip>
# Flags:   none (positional arg only)
# Output:  stdout + appended to /var/log/port_scan.log
# Exit:    1 if no target given, 0 otherwise (does not reflect scan
#          results in exit code)
set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

if which nc &>/dev/null ; then 
	echo " ------------------Initiating port scan---------------------"
else 
	echo "Netcat doesnot exist kindly install using ( sudo dnf/apt install netcat ) and proceed"
	exit 1
fi 


if [ "$#" -eq 0  ] ; then 
	echo " usage: $0 <target_ip>"
	exit 1
fi

target="$1"

LOGFILE="/var/log/port_scan.log"
echo "=== Port scan started: $(date) | Target: $target ===" >> "$LOGFILE"


ports=( 80 22 3000 3306 8080 9100 )

for i in "${ports[@]}"; do 
        if nc -zv "$target" "$i" &>/dev/null; then 
		
	        echo -e " port $i is ${GREEN}OPEN${NC}"
                echo " port $i is OPEN" >> "$LOGFILE"

	else
		echo -e " port $i is ${RED}CLOSED${NC}"
                echo " port $i is CLOSED" >> "$LOGFILE"
	fi
done

echo "=== Scan completed: $(date) ===" >> "$LOGFILE"
