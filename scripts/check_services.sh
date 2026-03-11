#!/bin/bash

LOGFILE="$HOME/service_check.log"
echo "===== Check run at $(date) ======" >> $LOGFILE

for p in httpd libvirtd sshd ; do 
	if systemctl is-active --quiet "$p"; then 
	echo " ok $p is running" | tee -a $LOGFILE
	else 
	echo " FAIL $p is not running " | tee -a $LOGFILE
	fi 
done


