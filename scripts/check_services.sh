#!/bin/bash

LOGFILE="$HOME/service_check.log"
echo "===== Check run at $(date) ======" >> $LOGFILE
total=0
running=0

for p in httpd libvirtd sshd ; do 
	((total++))
	if systemctl is-active --quiet "$p"; then 
		echo " ok $p is running"  | tee -a $LOGFILE
		((running++))
	else 
	echo " FAIL $p is not running " | tee -a $LOGFILE
	fi 
done

echo "summary :$running/$total services is running" | tee -a $LOGFILE

