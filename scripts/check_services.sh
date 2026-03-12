#!/bin/bash 

echo "====================== services  check=============================="

total=0
running=0

for p in sshd httpd libvirtd ; do 
	((total++))
	if systemctl is-active "$p" --quiet ; then 
		((running++))
	  echo "Ok $p is running "
        else 
	  echo " FAIL $p is not running"

	fi 
done
	echo "number of services running : $running/$total "
