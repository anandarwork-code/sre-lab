#!/bin/bash

threshold=80
log_file=/var/log/disk_alert.log
timestamp=$(date +"%Y_%m_%d-%H_%M_%S")

df --output=source,pcent | tail -n +2 | while read source pcent; do 
usage=${pcent%\%}
if [ "$usage" -ge "$threshold" ]; then
	echo "$timestamp: $source storage is full!! " | sudo tee -a $log_file
fi
done
