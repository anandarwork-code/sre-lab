#!/bin/bash
echo "====================Sreapp-Health-Check================================"

total=0
running=0
response=$(curl -s http://192.168.122.152/health)
((total++))
if echo "$response" | grep -q "OK" ; then 
	echo "MySQL-DB is reachable"
	((running++))
else 
	echo "MySQL-DB is down"
fi
for p in  nginx sreapp; do
	((total++))

        if sudo systemctl is-active --quiet "$p";then
                echo " $p     is active $(date)" | tee -a ~/sreapp_log.txt
		((running++))
        else
                echo " $p     is not active $(date)"  | tee -a ~/sreapp_log.txt
        fi
done
	echo " totally $running out of $total services are running"


echo "============================Completed=================================="
