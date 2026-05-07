#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

if [ -z "$1" ] ; then 
	echo " usage: $0 <target_ip>"
	exit 1
fi

target="$1"

LOGFILE="/var/log/port_scan.log"
echo "=== Port scan started: $(date) | Target: $target ===" >> "$LOGFILE"


ports=( 80 22 3000 3306 8080 9100 )

for i in "${ports[@]}"; do 
	nc -zv  $target $i  &>/dev/null
        if [ $? -eq 0 ]; then 
		
	        echo -e " port $i is ${GREEN}OPEN${NC}"
                echo " port $i is OPEN" >> "$LOGFILE"

	else
		echo -e " port $i is ${RED}CLOSED${NC}"
                echo " port $i is CLOSED" >> "$LOGFILE"
	fi
done

echo "=== Scan completed: $(date) ===" >> "$LOGFILE"
